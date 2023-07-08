; RISC-V verification programme					JDG 30/8/22
; Far from rigorous but improving ...

mm_io		equ	0x2000_0000		; Memory-mapped IO
mm_ints		equ	4			; Offset

		org	0

		li	x28, 0			; Indicate test phase

		li	x1, 0x555		; Build some confidence in
		li	x2, -2			;  conditional branches
		beq	x1, x0, broken		; BEQ not taken
		bne	x0, x1, okay_1		; BNE taken
		beq	x0, x0, broken
okay_1		bne	x1, x1, broken		; BNE not taken
		beq	x1, x1, okay_2		; BEQ taken
		beq	x0, x0, broken
okay_2		blt	x1, x0, broken		; BLT not taken
		bge	x1, x0, okay_3		; BGE taken
		beq	x0, x0, broken
okay_3		bge	x0, x1, broken		; BGE not taken
		blt	x0, x1, okay_4		; BLT taken
		beq	x0, x0, broken
okay_4		blt	x1, x2, broken		; BLT not taken
		blt	x2, x1, okay_5		; BLT taken
		beq	x0, x0, broken
okay_5		bge	x2, x1, broken		; BGE not taken
		bge	x1, x2, okay_6		; BGE taken
		beq	x0, x0, broken
okay_6		blt	x2, x2, broken		; BLT not taken
		bge	x2, x2, okay_7		; BGE taken
		beq	x0, x0, broken
okay_7		bltu	x2, x1, broken		; BLTU not taken
		bltu	x1, x2, okay_8		; BLTU taken
		beq	x0, x0, broken
okay_8		bgeu	x1, x2, broken		; BGEU not taken
		bgeu	x2, x1, okay_9		; BGEU taken
		beq	x0, x0, broken
okay_9		bltu	x1, x1, broken		; BLTU not taken
		bgeu	x1, x1, okay_10		; BGEU taken
		beq	x0, x0, broken

okay_10		addi	x28, x28, 1		; Next phase

		jal	call_1	  		; Try out call and return
		j	over

call_2		nop				; Two nested routines
		jalr	x0, [x5]
		beq	x0, x0, broken

call_1		jal	x5, call_2
		ret
		beq	x0, x0, broken


over		call	call_1

		addi	x28, x28, 1		; Next phase
		call	simple_adds
		addi	x28, x28, 1		; Next phase
		call	more_alu
		addi	x28, x28, 1		; Next phase
		call	mem_ops
		addi	x28, x28, 1		; Next phase
		call	test_fwd
		addi	x28, x28, 1		; Next phase
		call	csr_test
		addi	x28, x28, 1		; Next phase
		call	mul_div
		addi	x28, x28, 1		; Next phase

; Set up for (un)privileged environment

		la	x20, trap_vector_m	; Trap/exception testing
		csrw	MTVEC, x20
		la	x20, trap_vector_s
		csrw	STVEC, x20
		la	x20, trap_vector_u
		csrw	UTVEC, x20

		li	x20, 0x5550_000A		; Set up user code entry
		csrw	MSTATUS, x20

		csrw	MEDELEG, x0		; Ensure no delegation
		csrw	SEDELEG, x0		;

		la	x20, machine_stack	;
		csrw	MSCRATCH, x20		;

		li	x8, magic_1		;
		li	x9, 0			;

		la	x2, user_code		;
		csrw	MEPC, x2		;
	;	set up user SP (x2)
		mret				;

magic_1		equ	0xFEA51B1e
magic_2		equ	0xFEE1900D
magic_3		equ	0xDEADBEEF

;-------------------------------------------------------------------------------

simple_adds	addi	x10, x0, 1		; Test simple additions
		add	x10, x10, x10		; x10 := 2
		li	x3, 2			; x3 := 2
		bne	x10, x3, broken2
		add	x3, x3, x2		; x3 := 0
		bne	x0, x3, broken2
		sub	x3, x0, x2		; x3 := 2
		bne	x3, x10, broken2
		addi	x3, x3, 2		; x3 := 4
		slli	x10, x10, 1		; x10 := 4
		bne	x3, x10, broken2
		li	x4, 3
		sll	x3, x3, x4		; x3 := 32
		addi	x10, x10, 28		; x10 := 32
		bne	x3, x10, broken2
		slti	x4, x3, 32		; x4 := false
		bgtz	x4, broken2
		slti	x4, x3, 33		; x4 := true
		beqz	x4, broken2
		slt	x4, x3, x10		; x4 := false
		bnez	x4, broken2
		slt	x4, x10, x3		; x4 := false
		bnez	x4, broken2
		slt	x4, x10, x2		; x4 := false
		bnez	x4, broken2
		slt	x4, x2, x10		; x4 := true
		beqz	x4, broken2
		sltu	x4, x2, x10		; x4 := false
		bnez	x4, broken2
		li	x10, -1			; x10 := -1
		sltu	x4, x10, x2		; x4 := false
		bnez	x4, broken2
		sltu	x4, x2, x10		; x4 := true
		beqz	x4, broken2
		xor	x4, x10, x2		; x4 := 1
		addi	x5, x4, -1
		bnez	x5, broken2
		ret

;-------------------------------------------------------------------------------
; Later part uses load

more_alu	li	x20, 0x2468_ACE0
		mv	x2, x20
		andi	x3, x2, -1
		bne	x2, x3, broken3
		and 	x3, x2, x0
		beq	x2, x3, broken3

		andi 	x3, x2, 0x7FF
		beq	x3, x2, broken3
		slli	x4, x2, 21		; Clear bits by shifting
		srli	x5, x4, 21
		bne	x3, x5, broken3
		bltz	x5, broken3		; If negative ...
		srai	x5, x4, 21		; Should be negative
		bgez	x5, broken3		; If positive ...
		beq	x3, x5, broken3

		li	x20, 0x1357_9BDF
		mv	x2, x20
		andi	x3, x2, -1
		bne	x2, x3, broken3
		and 	x3, x2, x0
		beq	x2, x3, broken3

		andi 	x3, x2, 0x7FF
		beq	x3, x2, broken3
		slli	x4, x2, 21		; Clear bits by shifting
		srli	x5, x4, 21
		bne	x3, x5, broken3
		bltz	x5, broken3		; If negative ...
		srai	x5, x4, 21		; Should be positive
		bltz	x5, broken3		; If negative ...
		bne	x3, x5, broken3

; AND registers
		li	x6, 0x07FE_0000
		not	x7, x6
		and	x3, x20, x7		; Cut out some high bits
		and	x4, x20, x6		; Cut out other bits
		beq	x3, x20, broken3
		beq	x4, x20, broken3
		beq	x4, x3, broken3
		or	x5, x4, x3		; Reassemble
		bne	x5, x20, broken3

		srli	x8, x3, 16
		srli	x9, x4, 16
		srli	x10, x20, 16
		beq	x8, x9, broken3
		andi	x8, x8, 0x0000_07FF
		beq	x8, x9, broken3
		beq	x8, x9, broken3
		andi	x10, x10, 0x0000_07FF
		beq	x9, x10, broken3
		ori	x9, x9, 0x0000_0001	; Reinsert 'missing' 1
		bne	x9, x10, broken3

		li	x20, 0x1357_9BDF
		mv	x2, x20
		ori	x3, x2, -1
		beq	x2, x3, broken3
		bgez	x3, broken3
		or 	x3, x2, x0
		bne	x2, x3, broken3

;		li	x6, 0x07FE_0000
;		andi 	x3, x2, 0x7FF
;		beq	x3, x2, broken3
;		slli	x4, x2, 21		; Clear bits by shifting
;		srli	x5, x4, 21
;		bne	x3, x5, broken3
;		bltz	x5, broken3		; If negative ...
;		srai	x5, x4, 21		; Should be positive
;		bltz	x5, broken3		; If negative ...
;		bne	x3, x5, broken3

; A bit more on logicals & shifts - and don't forget xor @@@


		la	x5, values
		li	x6, value_count
value_loop	lw	x10, [x5]
		lw	x11, 4[x5]
		and	x12, x10, x11
		or	x13, x10, x11
		xor	x14, x10, x11
		add	x15, x10, x11
		sub	x16, x10, x11
		lw	x22, 8[x5]
		lw	x23, 12[x5]
		lw	x24, 16[x5]
		lw	x25, 20[x5]
		lw	x26, 24[x5]
		bne	x12, x22, broken3
		bne	x13, x23, broken3
		bne	x14, x24, broken3
		addi	x5, x5, (value_size * 4)
		subi	x6, x6, 1
		bgtz	x6, value_loop
		ret

value_a		equ	0x55AAFF00
value_b		equ	0xF50A6996
value_c		equ	0x12345678
value_d		equ	0x0FEDCBA9
; More values to make more records below @@@
; Maybe add more functions, too? @@@

value_count	equ	(values_end - values) / (4 * value_size)
value_size	equ	7			; Size of a record (words)

values		defw	value_a, value_b, value_a and value_b
		defw	                  value_a or  value_b
		defw	                  value_a xor value_b
		defw	                  value_a  +  value_b
		defw	                  value_a  -  value_b

		defw	value_c, value_d, value_c and value_d
		defw	                  value_c or  value_d
		defw	                  value_c xor value_d
		defw	                  value_c  +  value_d
		defw	                  value_c  -  value_d
values_end

;-------------------------------------------------------------------------------

mem_ops		la	x6, string_1
		mv	x10, x0
		li	x11, 0x80
		li	x7, 16

loop_1		lb	x9, [x6]
		lbu	x8, [x6]
		bne	x8, x10, broken4	; Also stresses any forwarding
		blt	x10, x11, loop_1a
		beq	x8, x9, broken4		; Sign extension failed?
		j	loop_1b
loop_1a		bne	x8, x9, broken4		; Sign extension failed?
loop_1b		addi	x6, x6, 1		; Step pointer
		addi	x10, x10, 0x11		; Track data values
		addi	x7, x7, -1
		bgtz	x7, loop_1

		la	x6, string_1
		li	x10, 0x1100
		li	x11, 0x8000
		li	x12, 0x2222
		li	x7, 8

loop_2		lh	x9, [x6]		; Need expanding properly
		lhu	x8, [x6]
		bne	x8, x10, broken4	; Also stresses any forwarding
		blt	x10, x11, loop_2a
		beq	x8, x9, broken4		; Sign extension failed?
		j	loop_2b
loop_2a		bne	x8, x9, broken4		; Sign extension failed?
loop_2b		addi	x6, x6, 2		; Step pointer
		add	x10, x10, x12		; Track data values
		addi	x7, x7, -1
		bgtz	x7, loop_2

		la	x6, string_1
		li	x10, 0x33221100
		li	x12, 0x44444444
		li	x7, 4

loop_3		lwu	x9, [x6]		; Keep?
		lw	x8, [x6]
		bne	x8, x10, broken4	; Also stresses any forwarding
		bne	x8, x9, broken4		; Sign extension failed?
		addi	x6, x6, 4		; Step pointer
		add	x10, x10, x12		; Track data values
		subi	x7, x7, 1		; Added this mnemonic
		bgtz	x7, loop_3

		li	x7, 0x3322_1100
		lw	x8, -16[x6]		; (Start of*****) Indexing tests
		bne	x8, x7, broken5
		lw	x7, -4[x6]
		subi	x6, x6, 16
		lw	x9, +12[x6]
		bne	x9, x7, broken5

		addi	x28, x28, 1		; Next phase

; Need 'thorough' store tests  *****
		la	x6, word_1
		li	x8, 0x1234_5678
		sw	x8, [x6]
		lb	x7, 0[x6]
		srli	x9, x8, 0
		andi	x9, x9, 0xFF
		bne	x7, x9, broken5
		lb	x7, 1[x6]
		srli	x9, x8, 8
		andi	x9, x9, 0xFF
		bne	x7, x9, broken5
		lb	x7, 2[x6]
		srli	x9, x8, 16
		andi	x9, x9, 0xFF
		bne	x7, x9, broken5
		lb	x7, 3[x6]
		srli	x9, x8, 24
		andi	x9, x9, 0xFF
		bne	x7, x9, broken5

		la	x6, word_2
		sb	x8, 0[x6]
		srli	x10, x8, 8
		sb	x10, 1[x6]
		srli	x10, x8, 16
		sb	x10, 2[x6]
		srli	x10, x8, 24
		sb	x10, 3[x6]
		lw	x9, [x6]
		bne	x9, x8, broken5

		xor	x9, x8, x8
		beq	x9, x8, broken5
		la	x6, word_3
		sh	x8, 0[x6]
		srli	x10, x8, 16
		sh	x10, 2[x6]
		lw	x9, [x6]
		bne	x9, x8, broken5		; More store tests ****

		ret

string_1	defb	0x00, 0x11, 0x22, 0x33
		defb	0x44, 0x55, 0x66, 0x77
		defb	0x88, 0x99, 0xAA, 0xBB
		defb	0xCC, 0xDD, 0xEE, 0xFF

		align

word_1		defw	0
word_2		defw	0
word_3		defw	0

;-------------------------------------------------------------------------------
; Assumes: Load, possibly CSR (later)

test_fwd	li	x2, 0x1111_1111		; Test ALU forwarding
		li	x4, 0x2222_2222
		li	x6, 0x3333_3333
		li	x8, 0x4444_4444
		li	x10, 0x5555_5555

		li	x12, 4		
loop_4		li	x20, 0x3333_3333	; Will be *two* instructions
		mv	x3, x20			; Read X20 on successive cycles
		mv	x5, x20
		mv	x7, x20
		mv	x9, x20
		mv	x11, x20
		mv	x20, x0			; Clear target again
		beq	x2, x3, broken6
		beq	x4, x5, broken6
		bne	x6, x7, broken6		; Should match only this one
		beq	x8, x9, broken6
		beq	x10, x11, broken6
		subi	x12, x12, 1		; Iterate in case of (memory)
		bnez	x12, loop_4		;  waits etc.

		la	x2, string_1		; Test load forwarding
		li	x4, 0x33_22_11_00	; Patterns from string
		li	x6, 0x77_66_55_44
		li	x8, 0xBB_AA_99_88
		li	x10, 0xFF_EE_DD_CC

		li	x12, 4		
loop_5		mv	x20, x0
		lw	x20, 8[x2]
		mv	x5, x20			; Read X20 on successive cycles
		mv	x7, x20
		mv	x9, x20
		mv	x11, x20
		bne	x5, x8, broken6		; Should match only this one
		bne	x7, x8, broken6
		bne	x9, x8, broken6
		bne	x11, x8, broken6
		subi	x12, x12, 1		; Iterate in case of (memory)
		bnez	x12, loop_5		;  waits etc.

; Possibly need the same thing with CSRs? @@@

		ret

;-------------------------------------------------------------------------------

mul_div		li	x10, 6			; Just an inspection test
		li	x11, 9			; Need doing thoroughly
		la	x13, mul_div_results
		mul	x12, x11, x10		; 0000_0036
		lw	x14, 0[x13]
		bne	x12, x14, broken7
		mulh	x12, x11, x10		; 0000_0000
		lw	x14, 4[x13]
		bne	x12, x14, broken7
		mulhsu	x12, x11, x10		; 0000_0000
		lw	x14, 8[x13]
		bne	x12, x14, broken7
		mulhu	x12, x11, x10		; 0000_0000
		lw	x14, 12[x13]
		bne	x12, x14, broken7
		div	x12, x11, x10		; 
		lw	x14, 16[x13]
		bne	x12, x14, broken7
		divu	x12, x11, x10		; 
		lw	x14, 20[x13]
		bne	x12, x14, broken7
		rem	x12, x11, x10		; 
		lw	x14, 24[x13]
		bne	x12, x14, broken7
		remu	x12, x11, x10		; 
		lw	x14, 28[x13]
		bne	x12, x14, broken7

		li	x10, -6
		li	x11, 9
		mul	x12, x11, x10		; FFFF_FFCA
		lw	x14, 32[x13]
		bne	x12, x14, broken7
		mulh	x12, x11, x10		; FFFF_FFFF
		lw	x14, 36[x13]
		bne	x12, x14, broken7
		mulhsu	x12, x11, x10		; 0000_0008
		lw	x14, 40[x13]
		bne	x12, x14, broken7
		mulhu	x12, x11, x10		; 0000_0008
		lw	x14, 44[x13]
		bne	x12, x14, broken7
		div	x12, x11, x10
		lw	x14, 48[x13]
		bne	x12, x14, broken7
		divu	x12, x11, x10
		lw	x14, 52[x13]
		bne	x12, x14, broken7
		rem	x12, x11, x10
		lw	x14, 56[x13]
		bne	x12, x14, broken7
		remu	x12, x11, x10
		lw	x14, 60[x13]
		bne	x12, x14, broken7

		li	x10, 6
		li	x11, -9
		mul	x12, x11, x10		; FFFF_FFCA
		lw	x14, 64[x13]
		bne	x12, x14, broken7
		mulh	x12, x11, x10		; FFFF_FFFF
		lw	x14, 68[x13]
		bne	x12, x14, broken7
		mulhsu	x12, x11, x10		; FFFF_FFFF
		lw	x14, 72[x13]
		bne	x12, x14, broken7
		mulhu	x12, x11, x10		; 0000_0005
		lw	x14, 76[x13]
		bne	x12, x14, broken7
		div	x12, x11, x10
		lw	x14, 80[x13]
		bne	x12, x14, broken7
		divu	x12, x11, x10
		lw	x14, 84[x13]
		bne	x12, x14, broken7
		rem	x12, x11, x10
		lw	x14, 88[x13]
		bne	x12, x14, broken7
		remu	x12, x11, x10
		lw	x14, 92[x13]
		bne	x12, x14, broken7

		li	x10, -6
		li	x11, -9
		mul	x12, x11, x10		; 0000_0036
		lw	x14, 96[x13]
		bne	x12, x14, broken7
		mulh	x12, x11, x10		; 0000_0000
		lw	x14, 100[x13]
		bne	x12, x14, broken7
		mulhsu	x12, x11, x10		; FFFF_FFF7
		lw	x14, 104[x13]
		bne	x12, x14, broken7
		mulhu	x12, x11, x10		; FFFF_FFF1
		lw	x14, 108[x13]
		bne	x12, x14, broken7
		div	x12, x11, x10
		lw	x14, 112[x13]
		bne	x12, x14, broken7
		divu	x12, x11, x10
		lw	x14, 116[x13]
		bne	x12, x14, broken7
		rem	x12, x11, x10
		lw	x14, 120[x13]
		bne	x12, x14, broken7
		remu	x12, x11, x10
		lw	x14, 124[x13]
		bne	x12, x14, broken7

		li	x20, 20
		li	x2, -30
		mul	x3, x20, x2
		div	x4, x3, x20
		bne	x4, x2, broken7
		div	x4, x3, x2
		bne	x4, x20, broken7
		divu	x4, x3, x20		
		beq	x4, x2, broken7		; Shouldn't match
		divu	x4, x3, x2
		beq	x4, x20, broken7

		la	x13, mul_div_data	; Try various divisions
		la	x12, mul_div_no		; and remultiply results
		lw	x12, [x12]
mul_div_loop	lw	x20, 0[x13]
		lw	x2, 4[x13]
		mul	x3, x20, x2
		div	x4, x3, x20
		bne	x4, x2, broken7
		div	x4, x3, x2
		bne	x4, x20, broken7

		div	x5, x20, x2		; Possibly optimised sequence
		rem	x6, x20, x2		;
		mul	x7, x5, x2
		add	x7, x7, x6
		bne	x7, x20, broken7

		addi	x13, x13, 8
		subi	x12, x12, 1
		bgtz	x12, mul_div_loop

		ret

mul_div_results	defw	0x0000_0036		; 9 * 6
		defw	0x0000_0000
		defw	0x0000_0000
		defw	0x0000_0000

		defw	0x0000_0001		; 9 / 6
		defw	0x0000_0001
		defw	0x0000_0003
		defw	0x0000_0003

		defw	0xFFFF_FFCA		; 9 * -6
		defw	0xFFFF_FFFF
		defw	0x0000_0008
		defw	0x0000_0008

		defw	0xFFFF_FFFF		; 9 / -6
		defw	0x0000_0000
		defw	0x0000_0003
		defw	0x0000_0009

		defw	0xFFFF_FFCA		; -9 * 6
		defw	0xFFFF_FFFF
		defw	0xFFFF_FFFF
		defw	0x0000_0005

		defw	0xFFFF_FFFF		; -9 / 6
		defw	0x2AAA_AAA9
		defw	0xFFFF_FFFD
		defw	0x0000_0001

		defw	0x0000_0036		; -9 * -6
		defw	0x0000_0000
		defw	0xFFFF_FFF7
		defw	0xFFFF_FFF1

		defw	0x0000_0001		; -9 / -6
		defw	0x0000_0000
		defw	0xFFFF_FFFD
		defw	0xFFFF_FFF7

mul_div_no	defw	(mul_div_data_end - mul_div_data) / 8

mul_div_data	defw	27, 95			; Some trial data
		defw	-123, 4876		; Can expand here
mul_div_data_end

;-------------------------------------------------------------------------------

csr_test	csrrw	x20, USCRATCH, x0	; Just some operations for
		csrrw	x0, USCRATCH, x8	; checking traces
		csrrw	x20, USCRATCH, x8

		csrrs	x20, USCRATCH, x0
		csrrs	x0, USCRATCH, x8
		csrrs	x20, USCRATCH, x8

		csrrc	x20, USCRATCH, x0
		csrrc	x0, USCRATCH, x8
		csrrc	x20, USCRATCH, x8

		csrrw	x2, MSCRATCH, x20
		csrrw	x2, MSCRATCH, x3
		csrrw	x3, MSCRATCH, x2	; Swap values; stress forwarding
		csrrw	x2, MSCRATCH, x3
		csrrw	x2, MSCRATCH, x2
		csrrw	x2, MSCRATCH, x2

		csrrw	x20, MINSTRET, x20	; Useful, here?
		csrrs	x20, 0x400, x20
		csrrc	x20, 0x400, x20
		csrrw	x20, MINSTRET, x20

		la	x3, trap_vector_m	; Set up trap vector
		csrw	MTVEC, x3		;
		la	x3, machine_stack	; and a SP
		csrw	MSCRATCH, x3		;
		csrw	INSTRET, x20		; Should throw illegal trap

		ret

;-------------------------------------------------------------------------------

user_code	auipc	x3, 0			; Read PC
		bne	x3, x2, broken10	; Got here as expected?

		li	x4, 0x996655AA		; Value to carry through call
		li	x31, 0x2		;
		ecall				; Return magic number in X1
		bne	x1, x8, broken10	; Returned expected value?

		nop
		nop
		mv	x5, x0			; Zero return value
		;illegal				;
		li	x2, 0x111E9A15		; Illegal instructions
		bne	x5, x2, broken10	; Returned expected value?

		li	x31, 1			; Write CSR
		li	x30, MEDELEG		; Set to delegate
		li	x29, 1<<2		;  illegal instructions
		ecall				;

		li	x31, 0x2		;
		ecall				; Check ECALL not delegated
		bne	x1, x8, broken10	; Returned expected value?

		mv	x5, x0			; Zero return value
		defw	0x1234_0000		; Guaranteed illegal
		li	x2, 0xBAD		; Illegal instructions
		bne	x5, x2, broken10	; Returned expected value?

		li	x31, 1			; Write CSR
		li	x30, SEDELEG		; Delegate further
		li	x29, 1<<2		;
		ecall				;

		mv	x5, x0			; Zero return value
		defw	0x0000_0053		; fadd.s	f0, f0, f0
		li	x2, 0x900D900D		; Illegal instructions
		bne	x5, x2, broken10	; Returned expected value?

		li	x31, 0			; Ask for machine privilege
		li	x30, 3			; 
		ecall			; Should not return delegated value now

		mv	x5, x0			; Zero return value
		defw	0x0000_0053		; fadd.s	f0, f0, f0
		li	x2, 0x900D900D		; Illegal instructions
		beq	x5, x2, broken10	; Returned unexpected value
		li	x2, 0x111E9A15		; Illegal instructions
 		bne	x5, x2, broken10	; Returned expected value?

		li	x31, 1			; Write CSR
		li	x30, MEDELEG		; Don't delegate illegals
		li	x29, 0			;
		ecall				;

		li	x31, 0			; Ask for user privilege
		li	x30, 0			; 
		ecall	     			;

		mv	x5, x0			; Zero return value
		csrw	USCRATCH, x0		; Set up possible hazard
		defw	0x0000_0053		; fadd.s	f0, f0, f0
		li	x2, 0x111E9A15		; Illegal instructions
		bne	x5, x2, broken10	; Returned expected value?
		nop
		nop

		li	x31, 0			; Ask for machine privilege
		li	x30, 3			; 
		ecall				;
		li	x3, 0x5550_080A	; Pattern for tracking
		csrw	MSTATUS, x3
		la	x2, supervisor_code
		csrw	MEPC, x2
		mret

supervisor_code	nop
		nop
		defw	0x0000_0053	; fadd.s	f0, f0, f0

		li	x31, 1		; Write CSR
		li	x30, MEDELEG	; Set to delegate
		li	x29, 1<<2	;  illegal instructions
		ecall			;

		nop
		nop			; Try to delegate
		defw	0x0000_0053	; fadd.s	f0, f0, f0

		csrc	SEDELEG, x1	; Now allow - have privilege

		defw	0x0000_0053	; fadd.s	f0, f0, f0

		li	x31, 1		; Write CSR
		li	x30, MEDELEG	; Don't delegate
		li	x29, 0		;  illegal instructions
		ecall			;

		defw	0x0000_0053	; fadd.s	f0, f0, f0

		li	x10, -4
		lw	x10, [x10]	; Try to abort @@@
		sw	x0, [x10]	; Try to abort @@@

		jalr	x10		; Try to abort @@@
		li	x10, -0x100
		jalr	x10		; Try to abort @@@

		la	x10, magic_place
		lbu	x11, [x10]	; Aligned load
		li	x12, magic_4 and 0xFF
		bne	x11, x12, broken11
		lhu	x11, [x10]	; Aligned load
		li	x12, magic_4 and 0xFFFF
		bne	x11, x12, broken11
		lw	x11, [x10]	; Aligned load
		li	x12, magic_4
		bne	x11, x12, broken11

		lbu	x11, 2[x10]	; Aligned load
		li	x12, (magic_4 >> 16) and 0xFF
		bne	x11, x12, broken11
		lhu	x11, 2[x10]	; Aligned load
		li	x12, (magic_4 >> 16) and 0xFFFF
		bne	x11, x12, broken11
		lw	x11, 2[x10]	; Unaligned load
		li	x12, ((magic_4 >> 16) and 0xFFFF) or (magic_4 << 16)
		beq	x11, x12, broken11 ; Shouldn't match!

		lbu	x11, 1[x10]	; Aligned load
		li	x12, (magic_4 >> 8) and 0xFF
		bne	x11, x12, broken11
		lhu	x11, 1[x10]	; Unaligned load
		li	x12, (magic_4 >> 8) and 0xFFFF
		beq	x11, x12, broken11 ; Shouldn't match!
		lw	x11, 1[x10]	; Unaligned load
		li	x12, ((magic_4 >> 8) and 0xFFFFFF) or (magic_4 << 24)
		beq	x11, x12, broken11 ; Shouldn't match!

		li	x31, 0x2	;
		ecall			; Check TVAL cleared

		li	x10, 33
		li	x11, 44
		mul	x12, x10, x11

		li	x31, 0		; Back to machine mode
		li	x30, 3		;
		ecall			;

		li	x13, 1 << 12	; ISA bit 'M'
		csrc	MISA, x13	; Immediately before faulting op.
		mul	x12, x10, x11	; Should now fault

		csrs	MISA, x13	; Immediately before faulting op.
		mul	x12, x10, x11	; Should now go again

		li	x6, mm_io	; Point at I/O space
		lw	x3, [x6]	; Try memory-mapped I/O
		li	x3, 0x2468_ACE0	;
		sw	x3, [x6]	;
		lw	x4, [x6]	;

		csrci	MSTATUS, 0xB	; Clear global MIE, SIE, UIE
					; Currently in supervisor mode

		li	x5, 1		;
		li	x7, 12		;
int_lp_1	sw	x5, mm_ints[x6]	; Output bits to interrupt cause
		slli	x5, x5, 1	;
		subi	x7, x7, 1	;
		bnez	x7, int_lp_1	;

		sw	x0, mm_ints[x6]	; Clear external register

		li	x8, -1		; Enable 'all' interrupts
		csrrw	x8, MIE, x8	;

		li	x5, 1		;
		li	x7, 12		;
int_lp_2	sw	x5, mm_ints[x6]	; Output bits to interrupt cause
		slli	x5, x5, 1	;
		subi	x7, x7, 1	;
		bnez	x7, int_lp_2	;

		sw	x0, mm_ints[x6]	; Clear external register

		csrrw	x8, MIE, x0	; Read back present interrupt sources

		li	x5, 1 << 11	; MEIP bit
		csrw	MIE, x5	 	; Enable interrupt

		sw	x5, mm_ints[x6]	; Assert interrupt

		nop
		csrr	x7, MIP		; Check visibility
		nop
		nop
		csrsi	MSTATUS, 0x8	; Global MIE
		nop
		nop
		nop
		ebreak
		csrci	MSTATUS, 0x8	; Global MIE
		nop
		nop

		csrsi	MTVEC, 1	; Set interrupt vectoring
		illegal			; Check this doesn't vector
		li	x7, 1<<11	;
		li	x8, mm_io	;
		csrsi	MSTATUS, 0x8	; Global MIE
		sw	x7, mm_ints[x8]	;
		nop			; Allow time for write
		nop
		nop
		csrci	MTVEC, 1	; Clear interrupt vectoring
					; Do some more experimenting first @@@

stop		ebreak
		j	stop

magic_4		equ	0xDEADBEEF
magic_place	defw	magic_4

broken		beq	x0, x0, broken
broken2		j	 broken2
broken3		j	 broken3
broken4		j	 broken4
broken5		j	 broken5
broken6		j	 broken6
broken7		j	 broken7

broken10	j	 broken10
broken11	j	 broken11

;-------------------------------------------------------------------------------

trap_vector_m	j	trap_vector_all		; Unvectored arrival point
		j	m_int_1			;
		j	m_int_2			;
		j	m_int_3			;
		j	m_int_4			;
		j	m_int_5			;
		j	m_int_6			;
		j	m_int_7			;
		j	m_int_8			;
		j	m_int_9			;
		j	m_int_10		;
		j	m_int_11		;

trap_vector_all	csrrw	x2, MSCRATCH, x2	; Swap in SP
		subi	x2, x2, 8     		; Push (token) register(s)
		sw	x4, 4[x2]      		;
		sw	x3, [x2]      		;

		csrr	x4, MCAUSE		; Trap handler
		bltz	x4, interrupt_m		;
		li	x3, 16			;
		bgtu	x4, x3, trap_m_ret	; Out of range
		la	x3, trap_m_dispatch	; Table base
		slli	x4, x4, 2		; Word size
		add	x3, x3, x4		; Index
		lw	x3, [x3]		; Load vector
		jr	x3  			; Dispatch

trap_m_ret	csrrw	x30, MEPC, x30		;
		addi	x30, x30, 4		; Correct return address
		csrrw	x30, MEPC, x30		;
		lw	x3, [x2]   		; Pop ...
		lw	x4, 4[x2]   		;
		addi	x2, x2, 8		;
		csrrw	x2, MSCRATCH, x2	; Swap out SP
		mret				;

trap_m_dispatch	defw	trap_m_ret
		defw	trap_m_ret
		defw	trap_m_2		; Illegal
		defw	trap_m_ret
		defw	trap_m_4
		defw	trap_m_ret
		defw	trap_m_6
		defw	trap_m_ret
		defw	trap_m_8		; ECALL - U mode
		defw	trap_m_9		; ECALL - S mode
		defw	trap_m_ret
		defw	trap_m_11		; ECALL - M mode
		defw	trap_m_12		; Instr. fetch fault
		defw	trap_m_ret
		defw	trap_m_ret
		defw	trap_m_ret

trap_m_2	li	x5, 0x111E9A15		; Illegal instructions
		j	trap_m_ret

; Return some identifying values, below ****
trap_m_4	j	trap_m_ret		; Unaligned load
trap_m_6	j	trap_m_ret		; Unaligned store

trap_m_8	li	x3, 4			; User ECALL
		bgtu	x31, x3, ecall_u_unk	; Out of range
		la	x3, ecall_dispatch	; Table base
		slli	x4, x31, 2		; Word size
		add	x3, x3, x4		; Index
		lw	x3, [x3]		; Load vector
		jalr	x3  			; Dispatch
ecall_u_unk	li	x1, magic_1		; User ECALL
		j	trap_m_ret

ecall_dispatch	defw	ecall_priv
		defw	ecall_csr
		defw	ecall_test
		defw	ecall_u_unk

ecall_priv	li	x3, 0x0000_1800		; Clear MPP bits
		csrc	MSTATUS, x3		;
		andi	x3, x30, 3		; Range limit
		slli	x3, x3, 11		; Shift to position
		csrs	MSTATUS, x3		; Write new MPP bits
		ret		 		;

ecall_csr	li	x3, MEDELEG		; Can't yet self-mod.
		beq	x30, x3, csr_302	;
		li	x3, MISA		;
		beq	x30, x3, csr_301	;
		li	x3, MSTATUS		;
		beq	x30, x3, csr_300	;
		li	x3, SEDELEG		;
		beq	x30, x3, csr_102	;
		ret	     			;

csr_102		csrw	SEDELEG, x29		;
		ret	     			;
csr_300		csrw	MSTATUS, x29		;
		ret	     			;
csr_301		csrw	MISA, x29		;
		ret	     			;
csr_302		csrw	MEDELEG, x29		;
		ret	     			;

ecall_test	ret

trap_m_9	li	x3, 4			; Supervisor ECALL
		bgtu	x31, x3, ecall_s_unk	; Out of range
		la	x3, ecall_dispatch	; Table base
		slli	x4, x31, 2		; Word size
		add	x3, x3, x4		; Index
		lw	x3, [x3]		; Load vector
		jalr	x3  			; Dispatch
ecall_s_unk	li	x1, magic_2		; Supervisor ECALL
		j	trap_m_ret

trap_m_11	li	x3, 4			; Machine ECALL
		bgtu	x31, x3, ecall_m_unk	; Out of range
		la	x3, ecall_dispatch	; Table base
		slli	x4, x31, 2		; Word size
		add	x3, x3, x4		; Index
		lw	x3, [x3]		; Load vector
		jalr	x3  			; Dispatch
ecall_m_unk	li	x1, magic_3		; Machine ECALL
		j	trap_m_ret

trap_m_12	subi	x1, x1, 4   ; Assume reached by call - return to LR (x1)
		csrw	MEPC, x1		; Prefetch abort
		j	trap_m_ret


interrupt_m	la	x3, int_dispatch	; Legal range assumed @@@
		slli	x4, x4, 2		; Loses top bit
		add	x3, x3, x4		;
		lw	x3, [x3]		;
		jalr	x3  			; Call handler

int_m_ret	lw	x3, [x2]   		; Pop ...
		lw	x4, 4[x2]   		;
		addi	x2, x2, 8		;
		csrrw	x2, MSCRATCH, x2	; Swap out SP
		mret				;

int_dispatch	defw	int_0			;
		defw	int_1			;
		defw	int_unk			;
		defw	int_3			;
		defw	int_4			;
		defw	int_5			;
		defw	int_unk			;
		defw	int_7			;
		defw	int_8			;
		defw	int_9			;
		defw	int_unk			;
		defw	int_11			;

; Vectored interrupt destinations
m_int_1			;
m_int_2			;
m_int_3			;
m_int_4			;
m_int_5			;
m_int_6			;
m_int_7			;
m_int_8			;
m_int_9			;
m_int_10		;
m_int_11		;

		csrrw	x2, MSCRATCH, x2	; Swap in SP
		subi	x2, x2, 8     		; Push (token) register(s)
		sw	x4, 4[x2]      		;
		sw	x3, [x2]      		;
		call	int_unk			; Customise for each handler ***
		lw	x3, [x2]   		; Pop ...
		lw	x4, 4[x2]   		;
		addi	x2, x2, 8		;
		csrrw	x2, MSCRATCH, x2	; Swap out SP
		mret				;

int_0			;
int_1			;
int_3			;
int_4			;
int_5			;
int_7			;
int_8			;
int_9			;
int_11

int_unk		li	x3, mm_io		; IO space
		sw	x0, mm_ints[x3]		; Blast it!
		ret	    			;

;-------------------------------------------------------------------------------

trap_vector_s	csrr	x1, SCAUSE		; Trap handler
		li	x2, 16			;
		bgtu	x1, x2, trap_s_ret	; Out of range
		la	x2, trap_s_dispatch	;
		slli	x1, x1, 2		; Word size
		add	x2, x2, x1		; Index
		lw	x2, [x2]		; Load vector
		jr	x2

trap_s_ret	csrr	x30, SEPC		; Trap return
		addi	x30, x30, 4		; Correct return address
		csrw	SEPC, x30
		sret

trap_s_dispatch	defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_2
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret
		defw	trap_s_ret

trap_s_2	li	x5, 0xBAD		; Illegal instructions
		j	trap_s_ret

;-------------------------------------------------------------------------------

trap_vector_u	csrr	x1, UCAUSE		; Trap handler
		li	x2, 16			;
		bgtu	x1, x2, trap_u_ret	; Out of range
		la	x2, trap_u_dispatch	;
		slli	x1, x1, 2		; Word size
		add	x2, x2, x1		; Index
		lw	x2, [x2]		; Load vector
		jr	x2

trap_u_ret	csrr	x30, UEPC		; Trap return
		addi	x30, x30, 4		; Correct return address
		csrw	UEPC, x30
		uret

trap_u_dispatch	defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_2
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret
		defw	trap_u_ret

trap_u_2	li	x5, 0x900D900D		; Illegal instructions
		j	trap_u_ret

;-------------------------------------------------------------------------------

		wfi

;-------------------------------------------------------------------------------

		defs	0x100
machine_stack

;-------------------------------------------------------------------------------
