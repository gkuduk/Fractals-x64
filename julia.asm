	section	.data
WIDTH:	dq	512.0
HEIGHT:	dq	512.0
DF2:	dq	2.0
DF4:	dq	4.0
SCR:	db	32
SCG:	db	64
SCB:	db	16
Wint:	dq	512
Hint:	dq	512

	section	.text
	global  julia

julia:
; rdi - address of *tab
; rsi - maxIter
; xmm0 - Re value of constant C
; xmm1 - Im value of constant C
; xmm2 - Re left
; xmm3 - Re right
; xmm4 - Im bottom
; xmm5 - Im top

	push	rbp
	mov	rbp, rsp

	mov	rbx, 0

	mov	r8, 1			; pixel x
	mov	r9, 1			; pixel y

	vsubsd	xmm6, xmm3, xmm2	; xmm6 = right-left
	vsubsd	xmm7, xmm5, xmm4	; xmm7 = top - bottom

	divsd	xmm6, [WIDTH]		; xmm6 = (right-left)/width
	divsd	xmm7, [HEIGHT]		; xmm7 = (top - bottom)/height

iteratePixel:
	mov	r10b, 0			; r10b - no of current iteration

	cvtsi2sd xmm8, r8		; convert to double float
	cvtsi2sd xmm9, r9

	mulsd	xmm8, xmm6		; xmm8 = x*(r-l)/width
	mulsd	xmm9, xmm7		; xmm9 = y*(t-b)/height
	addsd	xmm8, xmm2		; xmm8 = x*(r-l)/width + l
	addsd	xmm9, xmm4		; xmm9 = y*(t-b)/height + b

jLoop:
	vmulsd	xmm10, xmm8, xmm9
	mulsd	xmm10, [DF2]		; xmm10 = 2ab

	mulsd	xmm8, xmm8		; xmm8 = a^2
	mulsd	xmm9, xmm9		; xmm9 = b^2

	subsd	xmm8, xmm9		; a = a^2 - b^2
	movsd	xmm9, xmm10		; b = 2ab

	addsd	xmm8, xmm0		; a = a + ca
	addsd	xmm9, xmm1		; b = b + cb

	; check if zn is out of range
	vmulsd	xmm10, xmm8, xmm8	; xmm10 = a^2
	vmulsd	xmm11, xmm9, xmm9	; xmm11 = b^2

	addsd	xmm10, xmm11		; xmm10 = a^2 + b^2

	ucomisd	xmm10, [DF4]		; check if |zn|<2
	ja	jLoopEnd

	inc	r10b			; if |zn|<2 do another iter
	cmp	r10b, sil
	jl	jLoop

jLoopEnd:
	; Colouring
compRed:
	xor	rax, rax
	mov	al, r10b
	mul	BYTE [SCR]
	mov	r11w, ax
modRed:
	cmp	r11w, 256
	jl	compGreen
	sub	r11w, 256
	jmp	modRed

compGreen:
	xor	rax, rax
	mov	BYTE [rdi+rbx], r11b

	mov	al, r10b
	mul	BYTE [SCG]
	mov	r11w, ax

modGreen:
	cmp	r11w, 256
	jl	compBlue
	sub	r11w, 256
	jmp	modGreen

compBlue:
	xor	rax, rax
	mov	BYTE [rdi+rbx+1], r11b

	mov	al, r10b
	mul	BYTE [SCB]
	mov	r11w, ax

modBlue:
	cmp	r11w, 256
	jl	nextPixel
	sub	r11w, 256
	jmp	modBlue

nextPixel:
	mov	BYTE [rdi+rbx+2], r11b
	add	rbx, 3

	; move to next pixel
	add	r8, 1
	cmp	r8, [Wint]
	jle	iteratePixel

	mov	r8, 1
	add	r9, 1
	cmp	r9, [Hint]
	jle	iteratePixel
end:
	mov	rsp, rbp
	pop	rbp
	ret
