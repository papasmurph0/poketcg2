; returns a *= 10
ATimes10::
	push de
	ld e, a
	add a
	add a
	add e
	add a
	pop de
	ret

; returns a /= 10
; returns carry if a % 10 >= 5
ADividedBy10::
	push de
	ld e, -1
.div_loop
	inc e
	sub 10
	jr nc, .div_loop
	add 5
	ld a, e
	pop de
	ret
