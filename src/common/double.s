# Copyright (c) 2013 Matthias Koch
# Copyright (c) 2020-2025 Travis Bemann
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

	## Double drop
	define_word "2drop", visible_flag | inlined_flag
_2drop:	lc tos, cell(dp)
	addi dp, dp, 2*cell
	ret
	end_inlined

	## Double swap
	define_word "2swap", visible_flag | inlined_flag
_2swap:	lc x15, 0(dp)
        lc x14, 1*cell(dp)
        lc x13, 2*cell(dp)
        sc tos, 1*cell(dp)
        sc x15, 2*cell(dp)
        sc x13, 0(dp)
        mv tos, x14
        ret
	end_inlined

	## Double over
	define_word "2over", visible_flag | inlined_flag
_2over: lc x15, 1*cell(dp)
        lc x14, 2*cell(dp)
        addi dp, dp, -2*cell
        sc tos, 1*cell(dp)
        sc x14, 0(dp)
        mv tos, x15
        ret
	end_inlined
	
	## Double dup
	define_word "2dup", visible_flag | inlined_flag
_2dup:  lc x15, 0{dp}
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        sc x15, 0(dp)
        ret
	end_inlined

        ## Quadruple dup
        define_word "4dup", visible_flag | inlined_flag
_4dup:  lc x15, 0(dp)
        lc x14, 1*cell(dp)
        lc x13, 2*cell(dp)
        push_tos
        addi dp, dp, -4*cell
        sc x15, 0(dp)
        sc x14, 1*cell(dp)
        sc x13, 2*cell(dp)
        ret
        end_inlined

	## Double nip
	define_word "2nip", visible_flag | inlined_flag
_2nip:  lc x15, 0(dp)
        sc x15, 2*cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Double tuck
	define_word "2tuck", visible_flag
_2tuck: lc x15, 0(dp)
        lc x14, 1*cell(dp)
        lc x13, 2*cell(dp)
        sc tos, 1*cell(dp)
        sc x15, 2*cell(dp)
        addi dp, dp, -2*cell
        sc x15, 0(dp)
        sc x14, 1*cell(dp)
        sc x13, 2*cell(dp)
        ret
	end_inlined

	## Test for the equality of two double words
	define_word "d=", visible_flag
_deq:   lc x15, 1*cell(dp)
        xor tos, tos, x15
        lc x15, 0*cell(dp)
        lc x14, 2*cell(dp)
        xor x15, x15, x14
        addi dp, dp, 3*cell
        or tos, tos, x15
        sltiu tos, tos, 1
        sub tos, zero, tos
        ret
	end_inlined

	## Test for the inequality of two double words
	define_word "d<>", visible_flag
_dne:   lc x15, 1*cell(dp)
        xor tos, tos, x15
        lc x15, 0*cell(dp)
        lc x14, 2*cell(dp)
        xor x15, x15, x14
        addi dp, dp, 3*cell
        or tos, tos, x15
        sltiu tos, tos, 1
        addi tos, tos, -1
        ret
	end_inlined

	## Unsigned double less than
	define_word "du<", visible_flag
_dult:  lc x15, 2*cell(dp)
        lc x14, 0*cell(dp)
        sltu x13, x15, x14
        lc x15, 1*cell(dp)
        sltu x14, x15, x13
        sub x15, x15, x13
        sltu x15, x15, tos
        or tos, x15, x14
        addi tos, tos, -1
        not tos, tos
        addi dp, dp, 3*cell
        ret
	end_inlined

	## Unsigned double greater than
	define_word "du>", visible_flag
_dugt:  push ra
        call _2swap
        pop ra
        j _dult
	end_inlined

	## Unsigned double greater than or equal
	define_word "du>=", visible_flag
_duge:  push ra
        call _2swap
        call _4dup
        call _dult
        push tos
        pull_tos
        call _deq
        pop x15
        or tos, tos, x15
        pop ra
        ret
	end_inlined

	## Unsigned double less than or equal
	define_word "du<=", visible_flag | inlined_flag
_dule:  push ra
        call _4dup
        call _dult
        push tos
        pull_tos
        call _deq
        pop x15
        or tos, tos, x15
        pop ra
        ret
	end_inlined

	## Signed double less than
	define_word "d<", visible_flag
_dlt:   srai x15, tos, sign_shift
        lc x14, cell(dp)
        srai x14, x14, sign_shift
        addi sp, sp, -3*cell
        scsp ra, 0(sp)
        scsp x14, 1*cell(sp)
        scsp x15, 2*cell(sp)
        call _dult
        lcsp x15, 2*cell(sp)
        lcsp x14, 1*cell(sp)
        lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        xor tos, tos, x15
        xor tos, tos, x14
        ret
	end_inlined

	## Signed double greater than
	define_word "d>", visible_flag
_dgt:   push ra
        call _2swap
        pop ra
        j _dlt
	end_inlined

	## Signed double greater than or equal than
	define_word "d>=", visible_flag
_dge:   push ra
        call _2swap
        pop ra
        j _dle
	end_inlined

	## Signed double less than or equal than
	define_word "d<=", visible_flag
_dle:   push ra
        call _2swap
        call _4dup
        call _dlt
        push tos
        pull_tos
        call _deq
        pop x15
        or tos, tos, x15
        pop ra
        ret
	end_inlined
	
	## Double equals zero
	define_word "d0=", visible_flag | inlined_flag
_d0eq:	lc x15, 0(dp)
        addi dp, dp, cell
        or tos, tos, x15
        sltiu tos, tos, 1
        sub tos, zero, tos
        ret
	end_inlined

	## Double not equals zero
	define_word "d0<>", visible_flag | inlined_flag
_d0ne:	lc x15, 0(dp)
        addi dp, dp, cell
        or tos, tos, x15
        sltiu tos, tos, 1
        addi tos, tos, -1
        ret
	end_inlined

	## Double less than zero
	define_word "d0<", visible_flag | inlined_flag
_d0lt:	addi dp, dp, cell
        srai tos, tos, sign_shift
        ret
	end_inlined

	## Double greater than zero
	define_word "d0>", visible_flag
_d0gt:	lc x14, 0(dp)
        addi dp, dp, cell
        snez x14, x14
        snez x15, tos
        or x15, x15, x14
        sub x15, zero, x15
        srai tos, tos, sign_shift
        not tos, tos
        and tos, tos, x15
        ret
	end_inlined
	
	## Double less than or equal to zero
	define_word "d0<=", visible_flag
_d0le:	lc x14, 0(dp)
        addi dp, dp, cell
        seqz x14, x14
        seqz x15, tos
        and x15, x15, x14
        sub x15, zero, x15
        srai tos, tos, sign_shift
        or tos, tos, x15
        ret
	end_inlined

	## Double greater than or equal to zero
	define_word "d0>=", visible_flag | inlined_flag
_d0ge:	addi dp, dp, cell
        srai tos, tos, sign_shift
        not tos, tos
        ret
	end_inlined

	## Double left shift
	define_word "2lshift", visible_flag
_dlshift:	
        andi tos, tos, 2*cell_bits - 1
        bnez tos, 1f
        pull_tos
        ret
1:      addi x14, tos, -cell_bits
        blt x14, zero, 2f # Branch if the shift is less than 32 bits
        lc x15, cell(dp)
        sll tos, x15, x14
        addi dp, dp, cell
        sc zero 0(dp)
        ret
2:      lc x15, cell(dp)
        sll x14, x15, tos
        sc x14, cell(dp)
        li x14, cell_bits
        sub x14, x14, tos
        srl x15, x15, x14
        lc x14, 0(dp)
        sll tos, x15, tos
        or tos, tos, x15
        addi dp, dp, cell
        ret
	end_inlined

	## Double right shift
	define_word "2rshift", visible_flag
_drshift:
        andi tos, tos, 2*cell_bits - 1
        bnez tos, 1f
        pull_tos
        ret
1:      addi x14, tos, -cell_bits
        blt x14, zero, 2f # Branch if the shift is less than 32 bits
        lc x15, 0(dp)
        srl x15, x15, x14
        addi dp, dp, cell
        sc x15, 0(dp)
        li tos, 0
        ret
2:      lc x15, 0(dp)
        srl x13, x15, tos
        li x14, cell_bits
        sub x14, x14, tos
        sll x15, x15, x14
        lc x14, cell(dp)
        srl x14, x14, tos
        or x14, x14, x15
        sc x14, cell(dp)
        mv tos, x13
        addi dp, dp, cell
        ret
	end_inlined

	## Double arithmetic right shift
	define_word "2arshift", visible_flag
_darshift:
        andi tos, tos, 2*cell_bits - 1
        bnez tos, 1f
        pull_tos
        ret
1:      addi x14, tos, -cell_bits
        blt x14, zero, 2f # Branch if the shift is less than 32 bits
        lc x15, 0(dp)
        sra tos, x15, sign_shift
        sra x15, x15, x14
        addi, dp, dp cell
        sc x15, 0(dp)
        ret
2:      lc x15, 0(dp)
        sra x13, x15, tos
        li x14, cell_bits
        sub x14, x14, tos
        sll x15, x15, x14
        lc x14, cell(dp)
        srl x14, x14, tos
        or x14, x14, x15
        sc x14, cell(dp)
        mv tos, x13
        addi dp, dp, cell
        ret
	end_inlined
	
	## Negate a double word
	define_word "dnegate", visible_flag | inlined_flag
_dnegate:
        lc x15, 0(dp)
        not x15, x15
        not tos, tos
        addi x15, tos, 1
        sltiu x14, x15, tos
        add tos, tos, x14
        sc x15, 0(dp)
        ret
	end_inlined
	
	## Add two double words
	define_word "d+", visible_flag | inlined_flag
_dadd:  lc x15, 0(dp)
        lc x14, 1*cell(dp)
        lc x13, 2*cell(dp)
        add x13, x13, x15
        sltu x12, x13, x15
        add x14, x14, x12
        add tos, x14, tos
        sc x13, 2*cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Subtract two double words
	define_word "d-", visible_flag | inlined_flag
_dsub:  lc x15, 0(dp)
        lc x14, 1*cell(dp)
        lc x13, 2*cell(dp)
        sub x12, x13, x15
        sltu x11, x13, x15
        sub x14, x14, x11
        sub tos, x14, tos
        sc x12, 2*cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined
	
	## Add with carry
	define_word "um+", visible_flag | inlined_flag
_umadd:	lc x15, 0(dp)
        add x15, x15, tos
        sltu tos, x15, tos
        sc x15, 0(dp)
        ret
	end_inlined

	## Multiply two unsigned 32-bit values to get an unsigned 64-bit value
	define_word "um*", visible_flag | inlined_flag
_ummul:	lc x15, 0(dp)
        mul x14, x15, tos
        mulhu tos, x15, tos
        sc x15, 0(dp)
        ret
	end_inlined

	## Multiply two signed 32-bit values to get a signed 64-bit value
	define_word "m*", visible_flag | inlined_flag
_mmul:	lc x15, 0(dp)
        mul x14, x15, tos
        mulh tos, x15, tos
        sc x15, 0(dp)
        ret
	end_inlined

	## Unsigned multiply 64 * 64 = 64
	define_word "ud*", visible_flag
_udmul:
        lc x15, 0(dp)
        lc x14, 1*cell(dp)
        lc x13, 2*cell(dp)

        mul tos, tos, x13 # High-1 * Low-2 --> tos
        mul x14, x14, x15 # High-2 * Low-1 --> x14
        add tos, tos, x14 #                    Sum into tos

        srli x14, x15, 16
        srli x12, x13, 16
        mul x14, x14, x12
        add tos, x14

        srli x14, x15, cell_bits / 2
        li x11, (cell_bits / 2) - 1
        and x15, x15, x11
        and x13, x13, x11
        mul x14, x14, x13
        mul x12, x12, x15
        mul x15, x15, x13

        add x14, x14, x12
        sltu x13, x14, x12
        slli x13, x13, 16
        add tos, tos, x13

        slli x13, x14, 16
        srli x14, x14, 16
        add x15, x15, x13
        sltu x13, x15, x13
        add tos, tos, x13
        add tos, tos, x14

        add dp, dp, 2*cell
        sc x15, 0(dp)

        ret
	end_inlined

	## Unsigned multiply 64 * 64 = 128
	## ( ud1 ud2 -- udl udh )
	define_word "udm*", visible_flag
_udmmul:
        addi sp, sp, -5*cell
        scsp ra, 4*cell(sp)

        # ( d c b a )

        push_tos
        lc tos, 1*cell(dp) ## b
        push_tos
        lc tos, 4*cell(dp) ## d
        call _ummul
        mv x14, tos ## b*d-high
        pull_tos
        mv x15, tos ## b*d-low

        lc tos, 0*cell(dp) ## a
        push_tos
        lc tos, 3*cell(dp) ## c

        scsp x15, 0*cell(sp)
        scsp x14, 1*cell(sp)
        call _ummul
        lcsp x15, 0*cell(sp)
        lcsp x14, 1*cell(sp)
        
        mv x12, tos ## a*c-high
        pull_tos
        mv x13, tos ## a*c-low

        lc tos, 0*cell(dp) ## a
        push_tos
        lc tos, 4*cell(dp) ## d

        scsp x15, 0*cell(sp)
        scsp x14, 1*cell(sp)
        scsp x13, 2*cell(sp)
        scsp x12, 3*cell(sp)
        call _ummul
        lcsp x15, 0*cell(sp)
        lcsp x14, 1*cell(sp)
        lcsp x13, 2*cell(sp)
        lcsp x12, 3*cell(sp)

        add x13, x13, tos ## a*c-low + a*d-high
        sltu x11, x13, tos
        add x12, x12, x11 ## carry
        pull_tos
        add x14, x14, tos ## a*d-low + b*d-high
        sltu x11, x14, tos
        add x13, x13, x11 ## carry
        sltu x11, x13, x11
        add x14, x14, x11 ## carry

        lc tos, 1*cell(dp) ## b
        push_tos
        lc tos, 3*cell(dp) ## c
        
        scsp x15, 0*cell(sp)
        scsp x14, 1*cell(sp)
        scsp x13, 2*cell(sp)
        scsp x12, 3*cell(sp)
        call _ummul
        lcsp x15, 0*cell(sp)
        lcsp x14, 1*cell(sp)
        lcsp x13, 2*cell(sp)
        lcsp x12, 3*cell(sp)

        add x13, x13, tos ## a*c-low + b*c-high + a*d-high
        sltu x11, x13, tos
        add x12, x12, x11 ## carry
        pull_tos
        add x14, x14, tos ## b*c-low + a*d-low + b*d-high
        sltu x11, x14, tos
        add x13, x13, x11 ## carry
        sltu x11, x13, x11
        add tos, x14, x11 ## carry

        addi dp, dp, cell
        sc x13, 0*cell(dp)
        sc x14, 1*cell(dp)
        sc x15, 2*cell(dp)

        lcsp ra, 4*cell(sp)
        addi sp, sp, 5*cell
        ret
	end_inlined
		
	# ( n1 n2 n3 -- n1*n2/n3 ) With double length intermediate result
	define_word "*/", visible_flag
_muldiv:
        addi sp, sp, -2*cell
        scsp ra, 0*cell(sp)
        scsp tos, 1*cell(sp)
	pull_tos
	call _mmul
	push_tos
        lcsp tos, 1*cell(sp)
	call _mdivmod
	call _nip
        lcsp ra, 0*cell(sp)
        addi sp, sp, 2*cell
        ret
	end_inlined
	
	# ( u1 u2 u3 -- u1*u2/u3 ) With double length intermediate result
	define_word "*/mod", visible_flag
_muldivmod:
	addi sp, sp, -2*cell
        scsp ra, 0*cell(sp)
        scsp tos, 1*cell(sp)
	pull_tos
	call _mmul
	push_tos
        lcsp tos, 1*cell(sp)
	call _mdivmod
	lcsp ra, 0*cell(sp)
        addi sp, sp, 2*cell
        ret
	end_inlined
	
	# ( u1 u2 u3 -- u1*u2/u3 ) With double length intermediate result
	define_word "u*/", visible_flag
_umuldiv:
	addi sp, sp, -2*cell
        sc ra, 0*cell(sp)
        sc tos, 1*cell(sp)
	pull_tos
	call _ummul
	push_tos
        lcsp tos, 1*cell(sp)
	call _umdivmod
	call _nip
        lcsp ra, 0*cell(sp)
        addi sp, sp, 2*cell
        ret
	end_inlined
	
	# ( u1 u2 u3 -- u1*u2/u3 ) With double length intermediate result
	define_word "u*/mod", visible_flag
_umuldivmod:
        addi sp, sp, -2*cell
        sc ra, 0*cell(sp)
        sc tos, 1*cell(sp)
	pull_tos
	call _ummul
	push_tos
        lcsp tos, 1*cell(sp)
	call _umdivmod
        lcsp ra, 0*cell(sp)
        addi sp, sp, 2*cell
        ret
	end_inlined

	## Unsigned 64 / 32 = 32 remainder 32 division
	define_word "um/mod", visible_flag
_umdivmod:
        push ra
	push_tos
        li tos, 0
	call _uddivmod
	pull_tos
        addi dp, dp, cell
        pop ra
        ret
	end_inlined

	## Signed 64 / 32 = 32 remainder 32 division
	define_word "m/mod", visible_flag
_mdivmod:
        push ra
	push_tos
        srai tos, tos, sign_shift
	call _ddivmod
	pull_tos
        addi dp, dp, cell
        pop ra
        ret
	end_inlined
	
        ## Unsigned divide 64/64 = 64 remainder 64
        ## ( ud1 ud2 -- ud ud)
        ## ( 1L 1H 2L tos: 2H -- Rem-L Rem-H Quot-L tos: Quot-H )
	define_word "ud/mod", visible_flag
_uddivmod:
	# ( DividendL DividendH DivisorL DivisorH -- RemainderL RemainderH ResultL ResultH )
	#   8         4         0        tos      -- 8          4          0       tos
	
	
	# Shift-High Shift-Low Dividend-High Dividend-Low
	#        x12       x13           x14          x15
	
	li x12, 0
	li x13, 0
	lc  x14, 1*cell(dp)
	lc  x15, 2*cell(dp)
	
	# Divisor-High Divisor-Low
	#          x10           x11

	mv x10, tos
	lc  x11, 0*cell(dp)
	
	# For this long division, we need 64 individual division steps.
	li tos, 64

	# Shift the long chain of four registers.
3:	srli x6, x15, sign_shift
        slli x15, x15, 1
        srli x7, x14, sign_shift
        slli x14, x14, 1
        add x14, x14, x6
        srli x6, x13, sign_shift
        slli x13, x13, 1
        add x13, x13, x7
        slli x12, x12, 1
        add x12, x12, x6
	
	# Compare Divisor with top two registers
        bgtu x12, x10, 1f # Check high part first
        bltu x12, x10, 2f
	
	bltu x13, x11, 2f # High part is identical. Low part decides.

	# Subtract Divisor from two top registers
1:  	mv x6, x13
        sub x13, x13, x11 # Subtract low part
        sltu x6, x6, x11
        sub x12, x12, x6
        sub x12, x12, x10 # Subtract high part with carry
	
	# Insert a bit into Result which is inside LSB of the long register.
	addi x15, x15, 1

2:	addi tos, tos, -1
        bnez tos, 3b

	# Now place all values to their destination.
	mv tos, x14       # Result-High
	sc  x15, 0*cell(dp) # Result-Low
	sc  x12, 1*cell(dp) # Remainder-High
	sc  x13, 2*cell(dp) # Remainder-Low
	
        ret
	end_inlined

        ## Unsigned divide 64/64 = 64 remainder 64
        ## ( ud1 ud2 -- ud ud)
        ## ( 1L 1H 2L tos: 2H -- Rem-L Rem-H Quot-L tos: Quot-H )
	define_word "uf/mod", visible_flag
_ufdivmod:
        li x12, 0
	lc  x13, 1*cell(dp)
	lc  x14, 2*cell(dp)
        li x15, 0
	
	# Divisor-High Divisor-Low
	#          x10           x11

        mv x10, tos
	lc  x11, 0*cell(dp)
	
	# For this long division, we need 64 individual division steps.
        li tos, 64

	# Shift the long chain of four registers.
3:	srli x6, x15, sign_shift
        slli x15, x15, 1
        srli x7, x14, sign_shift
        slli x14, x14, 1
        add x14, x14, x6
        srli x6, x13, sign_shift
        slli x13, x13, 1
        add x13, x13, x7
        slli x12, x12, 1
        add x12, x12, x6
		
	# Compare Divisor with top two registers
	bgtu x12, x10, 1f # Check high part first
	bltu x12, x10, 2f
	
	bltu x13, x11, 2f # High part is identical. Low part decides.

	# Subtract Divisor from two top registers
1:  	mv x6, x13
        sub x13, x13, x11 # Subtract low part
        sltu x6, x6, x11
        sub x12, x12, x6
        sub x12, x12, x10 # Subtract high part with carry
		
	# Insert a bit into Result which is inside LSB of the long register.
	addi x15, x15, 1

2:	addi tos, tos, -1
        bnez tos, 3b

	# Now place all values to their destination.
	mv tos, x14        # Result-High
	sc  x15, 0*cell(dp) # Result-Low
	sc  x12, 1*cell(dp) # Remainder-High
	sc  x13, 2*cell(dp) # Remainder-Low
	
        ret
	end_inlined

	## Signed divide 64 / 64 = 64 remainder 64
	## ( d1 d2 -- d d )
	## ( 1L 1H 2L tos: 2H -- Rem-L Rem-H Quot-L tos: Quot-H )
	define_word "d/mod", visible_flag
_ddivmod:
	push ra
        blt tos, zero, 2f
	## ? / -
	call _dnegate
	call _2swap
        blt tos, zero, 2f
	## - / -
	call _dnegate
	call _2swap
	call _uddivmod
	call _2swap
	call _dnegate # Negative remainder
	call _2swap
	pop ra
        ret
1:	## + / -
	call _2swap
	call _uddivmod
	call _dnegate # Negative result
	pop ra
        ret
2:	## ? / +
	call _2swap
        blt tos, zero, 3f
	## - / +
	call _dnegate
	call _2swap
	call _uddivmod
	call _dnegate # Negative result
	call _2swap
	call _dnegate # Negative remainder
	call _2swap
        pop ra
        ret
3:	## + / +
	call _2swap
	call _uddivmod
        pop ra
        ret
	end_inlined

	## Divide unsigned two double words and get a double word quotient
	define_word "ud/", visible_flag
_uddiv:	push ra
	call _uddivmod
	call _2nip
        pop ra
        ret
	end_inlined
	
	## Divide signed two double words and get a double word quotient
	define_word "d/", visible_flag
_ddiv:	push ra
	call _ddivmod
	call _2nip
        pop ra
        ret
	end_inlined

	## Signed multiply two s31.32 numbers, sign wrong in overflow
	define_word "f*", visible_flag
_fmul:  push ra
        bge tos, zero, 1f
	# - * ?
	call _dnegate
	call _2swap
        bge tos, zero, 1f # - * +
	
	# - * -
	call _dnegate
	
3:      # + * +, - * -
	call _udmmul
	# ( LL L H HH )
        lc tos, 0(dp)
        lc x15, cell(dp)
        addi dp, dp, 2*cell
        sc x15, 0(dp)
	# ( L H )
        pop ra
        ret
	
1:      # + * ?
	call _2swap
        bge tos, zero, 3b # + * +
	
	call _dnegate
	
	# - * + or + * -
2:      call _udmmul
	# ( LL L H HH )
        lc tos, 0(dp)
        lc x15, cell(dp)
        addi dp, dp,2*cell
        sc x15, 0(dp)
	# ( L H )
	call _dnegate
        pop ra
        ret
	end_inlined
	
	## Signed divide for s31.32, sign wrong in overflow
	define_word "f/", visible_flag
_fdiv:	# Take care of sign ! ( 1L 1H 2L 2H - EL EH )
        push ra
        bge tos, zero, 2f
	# ? / -
	call _dnegate
	call _2swap
        bge tos, zero, 3f # + / -
	
	# - / -
	call _dnegate
1:      call _2swap # - / - or + / +
	call _ufdivmod
	call _2nip
	pop ra
        ret
	
2:      # ? / +
	call _2swap
        bge tos, zero, 1b # + / +
	
	# - / +
	call _dnegate
3:      call _2swap # - / + or + / -
	call _ufdivmod
	call _dnegate
	call _2nip
        pop ra
        ret
	end_inlined
