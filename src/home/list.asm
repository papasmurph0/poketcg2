; Save a pointer to a list, given at de, to wListPointer
SetListPointer::
	push hl
	ld hl, wListPointer
SetListPointer_Common:
	ld [hl], e
	inc hl
	ld [hl], d
	pop hl
	ret

SetListPointer2::
	push hl
	ld hl, wListPointer2
	jr SetListPointer_Common

; Return the current element of the list at wListPointer,
; and advance the list to the next element
GetNextElementOfList:
	push hl
	push de
	ld hl, wListPointer
GetNextElementOfList_Common:
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, [de]
	inc de
;	fallthrough

SetListToNextPosition:
	ld [hl], d
	dec hl
	ld [hl], e
	pop de
	pop hl
	ret

GetNextElementOfList2:
	push hl
	push de
	ld hl, wListPointer2
	jr GetNextElementOfList_Common

; Set the current element of the list at wListPointer to a,
; and advance the list to the next element
SetNextElementOfList::
	push hl
	push de
	ld hl, wListPointer
SetNextElementOfList_Common:
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld [de], a
	inc de
	jr SetListToNextPosition

SetNextElementOfList2::
	push hl
	push de
	ld hl, wListPointer2
	jr SetNextElementOfList_Common

; Return the current 16-bit element of the list at wListPointer in de,
; and advance the list to the next element.
GetNextWordOfList:
	push hl
	push bc
	ld hl, wListPointer
.get_next_word
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	inc bc
.set_list_to_next_word
	ld [hl], b
	dec hl
	ld [hl], c
	pop bc
	pop hl
	ret

; Return the current 16-bit element of the list at wListPointer2 in de,
; and advance the list to the next element.
GetNextWordOfList2:
	push hl
	push bc
	ld hl, wListPointer2
	jr GetNextWordOfList.get_next_word

; Set the current 16-bit element of the list at wListPointer to de,
; and advance the list to the next element.
SetNextWordOfList:
	push hl
	push bc
	ld hl, wListPointer
.set_next_word
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld a, e
	ld [bc], a
	inc bc
	ld a, d
	ld [bc], a
	inc bc
	jr GetNextWordOfList.set_list_to_next_word

; Set the current 16-bit element of the list at wListPointer2 to de,
; and advance the list to the next element.
SetNextWordOfList2:: ; Func_0b99
	push hl
	push bc
	ld hl, wListPointer2
	jr SetNextWordOfList.set_next_word

; Advance wListPointer by a bytes.
AddAToListPointer:
	push hl
	ld hl, wListPointer
.add_a_to_list_pointer
	add [hl]
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hl], a
	pop hl
	ret

; Advance wListPointer2 by a bytes.
AddAToListPointer2:
	push hl
	ld hl, wListPointer2
	jr AddAToListPointer.add_a_to_list_pointer
