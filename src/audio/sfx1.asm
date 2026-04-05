SFX_PlaySFX:
	jp SFX_Play

SFX_UpdateSFX:
	jp SFX_Update

SFX_Play:
	ld hl, NumberOfSFX1
	cp [hl]
	jp nc, .invalidID
	ld c, a
	ld b, $0
	ld l, c
	ld h, b
	add hl, bc
	ld c, l
	ld b, h
	ld a, [wSFXIsPlaying]
	or a
	jr z, .load_sfx_data
	ld a, [wSFXChannelMask]
	rrca
	ld [wSFXChannelMask], a
	jr nc, .skip_ch1_init
	ld a, AUD1SWEEP_DOWN
	ldh [rAUD1SWEEP], a
	ldh [rAUD1ENV], a
	swap a ; AUD1HIGH_RESTART
	ldh [rAUD1HIGH], a
.skip_ch1_init
	ld a, [wSFXChannelMask]
	rrca
	ld [wSFXChannelMask], a
	jr nc, .skip_ch2_init
	ld a, AUD2ENV_UP
	ldh [rAUD2ENV], a
	swap a ; AUD2HIGH_RESTART
	ldh [rAUD2HIGH], a
.skip_ch2_init
	ld a, [wSFXChannelMask]
	rrca
	ld [wSFXChannelMask], a
	jr nc, .skip_ch3_init
	ld a, $0
	ldh [rAUD3LEVEL], a
.skip_ch3_init
	ld a, [wSFXChannelMask]
	rrca
	jr nc, .load_sfx_data
	ld a, AUD4ENV_UP
	ldh [rAUD4ENV], a
	swap a ; AUD4GO_RESTART
	ldh [rAUD4GO], a
.load_sfx_data
	ld a, $1
	ld [wSFXIsPlaying], a
	ld hl, SFXHeaderPointers1
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wCurSfxBank], a
	ld a, [hli]
	ld [wSFXChannelMask], a
	ld [wSFXChannelLoadMask], a
	ld de, wSFXChannelPointers
	ld c, $0
	ld b, $0
.load_channel_loop
	ld a, [wSFXChannelLoadMask]
	rrca
	ld [wSFXChannelLoadMask], a
	jr nc, .skip_channel_load
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	push hl
	ld a, c
	cp $0
	jr nz, .skip_sweep_init
	ld a, AUD1SWEEP_DOWN
	ldh [rAUD1SWEEP], a
.skip_sweep_init
	ld hl, wSFXChannelPitchOffset
	add hl, bc
	ld [hl], $0
	ld hl, wSFXChannelFrameDelay
	add hl, bc
	ld [hl], $1
	pop hl
	jr .next_channel
.skip_channel_load
	inc de
	inc de
.next_channel
	inc c
	ld a, $4
	cp c
	jr nz, .load_channel_loop
.invalidID
	ret

SFX_Update:
	ld a, [wCurSfxBank]
	ldh [hBankROM], a
	ld [rROMB], a
	ld a, [wSFXChannelMask]
	or a
	jr nz, .channels_active
	call StopSFXPlayback
	ret
.channels_active
	xor a
	ld b, a
	ld c, a
	ld a, [wSFXChannelMask]
	ld [wSFXChannelUpdateMask], a
.update_channel_loop
	ld hl, wSFXChannelUpdateMask
	ld a, [hl]
	rrca
	ld [hl], a
	jr nc, .next_channel
	ld hl, wSFXChannelFrameDelay
	add hl, bc
	ld a, [hl]
	dec a
	jr z, .frame_delay_expired
	ld [hl], a
	call ApplySFXChannelPitchOffset
	jr .next_channel
.frame_delay_expired
	ld hl, wSFXChannelPointers
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call ExecuteSFXCommand
.next_channel
	inc c
	ld a, c
	cp $4
	jr nz, .update_channel_loop
	ret

ExecuteSFXCommand: ; Func_fc094
	ld a, [hl]
	and $f0
	swap a
	add a
	ld e, a
	ld d, $0
	ld a, [hli]
	push hl
	and $f
	ld hl, SFX_CommandTable
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	jp hl

SFX_CommandTable:
	dw SFX_frequency
	dw SFX_envelope
	dw SFX_duty
	dw SFX_loop
	dw SFX_endloop
	dw SFX_pitch_offset
	dw SFX_wait
	dw SFX_wave
	dw SFX_pan
	dw SFX_sweep
	dw SFX_unused
	dw SFX_unused
	dw SFX_unused
	dw SFX_unused
	dw SFX_unused
	dw SFX_end

SFX_unused:
	jp ExecuteSFXCommand

SFX_frequency:
	ld d, a
	pop hl
	ld a, [hli]
	ld e, a
	push hl
	ld hl, wSFXChannelFrequency
	add hl, bc
	add hl, bc
	push bc
	ld b, [hl]
	ld [hl], e
	inc hl
	ld [hl], d
	ld a, c
	cp $3
	jr nz, .not_noise_channel
	ld a, b
	xor e
	and $8
	swap a
	ld d, a
.not_noise_channel
	pop bc
	ld hl, wSFXChannelRestartPending
	add hl, bc
	ld a, [hl]
	ld [hl], $0
	or d
	ld d, a
	ld hl, rAUD1LEN
	ld a, c
	add a
	add a
	add c
	add l
	ld l, a
	ld a, [hl]
	and $c0
	ld [hli], a
	inc hl
	ld a, e
	ld [hli], a
	ld [hl], d
	pop de
UpdateSFXChannelPointer: ; Func_fc105
	ld hl, wSFXChannelPointers
	add hl, bc
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], d
	ret

SFX_envelope:
	ld hl, wSFXChannelRestartPending
	add hl, bc
	ld a, $80
	ld [hl], a
	pop hl
	ld a, [hli]
	ld e, a
	push hl
	ld hl, rAUD1ENV
	ld a, c
	add a
	add a
	add c
	add l
	ld l, a
	ld [hl], e
	pop hl
	jp ExecuteSFXCommand

SFX_duty:
	swap a
	ld e, a
	ld hl, rAUD1LEN
	ld a, c
	add a
	add a
	add c
	add l
	ld l, a
	ld [hl], e
	pop hl
	jp ExecuteSFXCommand

SFX_loop:
	ld hl, wSFXChannelLoopPtr
	add hl, bc
	add hl, bc
	pop de
	ld a, [de]
	inc de
	ld [hl], e
	inc hl
	ld [hl], d
	ld hl, wSFXChannelLoopCount
	add hl, bc
	ld [hl], a
	ld l, e
	ld h, d
	jp ExecuteSFXCommand

SFX_endloop:
	ld hl, wSFXChannelLoopCount
	add hl, bc
	ld a, [hl]
	dec a
	jr z, .loop_done
	ld [hl], a
	ld hl, wSFXChannelLoopPtr
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	jp ExecuteSFXCommand
.loop_done
	pop hl
	jp ExecuteSFXCommand

SFX_pitch_offset:
	ld hl, wSFXChannelPitchOffset
	add hl, bc
	ld e, l
	ld d, h
	pop hl
	ld a, [hli]
	ld [de], a
	jp ExecuteSFXCommand

SFX_wait:
	ld a, c
	cp $3
	jr nz, .apply_tone_pitch_offset
	call ApplyNoiseChannelPitchOffset
	jr .set_frame_delay
.apply_tone_pitch_offset
	call ApplySFXChannelPitchOffset
.set_frame_delay
	ld hl, wSFXChannelFrameDelay
	add hl, bc
	ld e, l
	ld d, h
	pop hl
	ld a, [hli]
	ld [de], a
	ld e, l
	ld d, h
	jp UpdateSFXChannelPointer

ApplySFXChannelPitchOffset: ; Func_fc18d
	ld hl, wSFXChannelPitchOffset
	add hl, bc
	ld a, [hl]
	or a
	jr z, .done
	ld hl, wSFXChannelFrequency
	add hl, bc
	add hl, bc
	bit 7, a
	jr z, .freq_positive
	xor $ff
	inc a
	ld d, a
	ld a, [hl]
	sub d
	ld [hli], a
	ld e, a
	ld a, [hl]
	sbc b
	jr .update_freq_registers
.freq_positive
	ld d, a
	ld a, [hl]
	add d
	ld [hli], a
	ld e, a
	ld a, [hl]
	adc b
.update_freq_registers
	ld [hl], a
	ld hl, wSFXChannelRestartPending
	add hl, bc
	ld d, [hl]
	ld [hl], $0
	or d
	ld d, a
	ld hl, rAUD1LEN
	ld a, c
	add a
	add a
	add c
	add l
	ld l, a
	ld a, [hl]
	and $c0
	ld [hli], a
	inc hl
	ld a, e
	ld [hli], a
	ld [hl], d
.done
	ret

ApplyNoiseChannelPitchOffset: ; Func_fc1cd
	ld hl, wSFXNoisePitchOffset
	ld a, [hl]
	or a
	jr z, .done
	ld hl, wSFXNoiseFrequency
	bit 7, a
	jr z, .noise_freq_positive
	xor $ff
	inc a
	ld d, a
	ld e, [hl]
	ld a, e
	sub d
	ld [hl], a
	jr .write_noise_registers
.noise_freq_positive
	ld d, a
	ld e, [hl]
	ld a, e
	add d
	ld [hl], a
.write_noise_registers
	ld d, a
	xor e
	and $8
	swap a
	ld hl, wSFXNoiseRestartPending
	ld e, [hl]
	ld [hl], $0
	or e
	ld e, a
	ld hl, rAUD4LEN
	xor a
	ld [hli], a
	inc hl
	ld a, d
	ld [hli], a
	ld [hl], e
.done
	ret

SFX_wave:
	add a
	ld d, $0
	ld e, a
	ld hl, SFX_WaveInstruments1
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, AUD3ENA_OFF
	ldh [rAUD3ENA], a
	ld b, d
	ld de, _AUD3WAVERAM
.copy_wave_loop
	ld a, [hli]
	ld [de], a
	inc de
	inc b
	ld a, b
	cp AUD3WAVE_SIZE
	jr nz, .copy_wave_loop
	ld a, $1
	ld [wMusicWaveChange], a
	ld a, AUD3ENA_ON
	ldh [rAUD3ENA], a
	ld b, $0
	pop hl
	jp ExecuteSFXCommand

SFX_pan:
	pop hl
	ld a, [hli]
	push hl
	push bc
	inc c
	ld e, $ee
.shift_loop
	dec c
	jr z, .apply_pan
	rlca
	rlc e
	jr .shift_loop
.apply_pan
	ld d, a
	ld hl, wSFXStereoPanning
	ld a, [hl]
	and e
	or d
	ld [hl], a
	pop bc
	pop hl
	jp ExecuteSFXCommand

SFX_sweep:
	pop hl
	ld a, [hli]
	ldh [rAUD1SWEEP], a
	jp ExecuteSFXCommand

SFX_end:
	ld e, c
	inc e
	ld a, $7f
.build_channel_mask
	rlca
	dec e
	jr nz, .build_channel_mask
	ld e, a
	ld a, [wSFXChannelMask]
	and e
	ld [wSFXChannelMask], a
	ld a, c
	rlca
	rlca
	add c
	ld e, a
	ld d, b
	ld hl, rAUD1ENV
	add hl, de
	ld a, $8
	ld [hli], a
	inc hl
	swap a
	ld [hl], a
	pop hl
	ret

StopSFXPlayback: ; Func_fc26c
	xor a
	ld [wSFXIsPlaying], a
	ld [wSfxPriority], a
	ld [wAudio_d005], a
	ret

INCLUDE "audio/sfx1_headers.asm"

SFX_WaveInstruments1:
INCLUDE "audio/wave_instruments.asm"

INCLUDE "audio/sfx/sfx_placeholder_cursor.asm"

INCLUDE "audio/sfx/sfx_cursor.asm"
INCLUDE "audio/sfx/sfx_confirm.asm"
INCLUDE "audio/sfx/sfx_cancel.asm"
INCLUDE "audio/sfx/sfx_denied.asm"
INCLUDE "audio/sfx/sfx_jingle.asm"
INCLUDE "audio/sfx/sfx_06.asm"
INCLUDE "audio/sfx/sfx_card_shuffle.asm"
INCLUDE "audio/sfx/sfx_place_prize.asm"
INCLUDE "audio/sfx/sfx_09.asm"
INCLUDE "audio/sfx/sfx_0a.asm"
INCLUDE "audio/sfx/sfx_coin_toss.asm"
INCLUDE "audio/sfx/sfx_warp.asm"
INCLUDE "audio/sfx/sfx_0d.asm"
INCLUDE "audio/sfx/sfx_0e.asm"
INCLUDE "audio/sfx/sfx_doors.asm"
INCLUDE "audio/sfx/sfx_tcg1_legendary_cards.asm"
INCLUDE "audio/sfx/sfx_glow.asm"
INCLUDE "audio/sfx/sfx_paralysis.asm"
INCLUDE "audio/sfx/sfx_sleep.asm"
INCLUDE "audio/sfx/sfx_confusion.asm"
INCLUDE "audio/sfx/sfx_poison.asm"
INCLUDE "audio/sfx/sfx_small_hit.asm"
INCLUDE "audio/sfx/sfx_hit.asm"
INCLUDE "audio/sfx/sfx_thunder_shock.asm"
INCLUDE "audio/sfx/sfx_lightning.asm"
INCLUDE "audio/sfx/sfx_border_spark.asm"
INCLUDE "audio/sfx/sfx_big_lightning.asm"
INCLUDE "audio/sfx/sfx_small_flame.asm"
INCLUDE "audio/sfx/sfx_big_flame.asm"
INCLUDE "audio/sfx/sfx_fire_spin.asm"
INCLUDE "audio/sfx/sfx_dive_bomb.asm"
INCLUDE "audio/sfx/sfx_water_jets.asm"
INCLUDE "audio/sfx/sfx_water_gun.asm"
INCLUDE "audio/sfx/sfx_whirlpool.asm"
INCLUDE "audio/sfx/sfx_hydro_pump.asm"
INCLUDE "audio/sfx/sfx_blizzard.asm"
INCLUDE "audio/sfx/sfx_psychic.asm"
INCLUDE "audio/sfx/sfx_leer.asm"
INCLUDE "audio/sfx/sfx_beam.asm"
INCLUDE "audio/sfx/sfx_hyper_beam.asm"
INCLUDE "audio/sfx/sfx_avalanche.asm"
INCLUDE "audio/sfx/sfx_stone_barrage.asm"
INCLUDE "audio/sfx/sfx_punch.asm"
INCLUDE "audio/sfx/sfx_stretch_kick.asm"
INCLUDE "audio/sfx/sfx_slash.asm"
INCLUDE "audio/sfx/sfx_sonic_boom.asm"
INCLUDE "audio/sfx/sfx_fury_swipes.asm"
INCLUDE "audio/sfx/sfx_drill.asm"
INCLUDE "audio/sfx/sfx_pot_smash.asm"
INCLUDE "audio/sfx/sfx_bonemerang.asm"
INCLUDE "audio/sfx/sfx_seismic_toss.asm"
INCLUDE "audio/sfx/sfx_needles.asm"
INCLUDE "audio/sfx/sfx_white_gas.asm"
INCLUDE "audio/sfx/sfx_powder.asm"
INCLUDE "audio/sfx/sfx_goo.asm"
INCLUDE "audio/sfx/sfx_bubbles.asm"
INCLUDE "audio/sfx/sfx_string_shot.asm"
INCLUDE "audio/sfx/sfx_boyfriends.asm"
INCLUDE "audio/sfx/sfx_lure.asm"
INCLUDE "audio/sfx/sfx_toxic.asm"
INCLUDE "audio/sfx/sfx_confuse_ray.asm"
INCLUDE "audio/sfx/sfx_sing.asm"
INCLUDE "audio/sfx/sfx_supersonic.asm"
INCLUDE "audio/sfx/sfx_petal_dance.asm"
INCLUDE "audio/sfx/sfx_protect.asm"
INCLUDE "audio/sfx/sfx_barrier.asm"
INCLUDE "audio/sfx/sfx_speed.asm"
INCLUDE "audio/sfx/sfx_whirlwind.asm"
INCLUDE "audio/sfx/sfx_cry.asm"
INCLUDE "audio/sfx/sfx_question_mark.asm"
INCLUDE "audio/sfx/sfx_self_destruct.asm"
INCLUDE "audio/sfx/sfx_big_self_destruct.asm"
INCLUDE "audio/sfx/sfx_heal.asm"
INCLUDE "audio/sfx/sfx_drain.asm"
INCLUDE "audio/sfx/sfx_dark_gas.asm"
INCLUDE "audio/sfx/sfx_healing_wind.asm"
INCLUDE "audio/sfx/sfx_whirlwind_bench.asm"
INCLUDE "audio/sfx/sfx_expand.asm"
INCLUDE "audio/sfx/sfx_cat_punch.asm"
INCLUDE "audio/sfx/sfx_thunder_wave.asm"
INCLUDE "audio/sfx/sfx_firegiver.asm"
INCLUDE "audio/sfx/sfx_thunder_punch.asm"
INCLUDE "audio/sfx/sfx_fire_punch.asm"
INCLUDE "audio/sfx/sfx_coin_toss_positive.asm"
INCLUDE "audio/sfx/sfx_coin_toss_negative.asm"
INCLUDE "audio/sfx/sfx_save_game.asm"
INCLUDE "audio/sfx/sfx_player_walk_map.asm"
INCLUDE "audio/sfx/sfx_tcg1_intro_orb.asm"
INCLUDE "audio/sfx/sfx_tcg1_intro_orb_swoop.asm"
INCLUDE "audio/sfx/sfx_tcg1_intro_orb_title.asm"
INCLUDE "audio/sfx/sfx_tcg1_intro_orb_scatter.asm"
INCLUDE "audio/sfx/sfx_firegiver_start.asm"
INCLUDE "audio/sfx/sfx_receive_card_pop.asm"
INCLUDE "audio/sfx/sfx_pokemon_evolution.asm"
INCLUDE "audio/sfx/sfx_5f.asm"
