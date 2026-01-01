# Copyright (c) 2019-2023 Travis Bemann
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

	## Aliases for data stack and top of stack registers
tos 	.req x8
dp 	.req x9

        ## Cell size
        .equ cell, 4
        
	## True value
	.equ true_value, -1

	## False value
	.equ false_value, 0

        ## Built-in syntax values
        .equ syntax_none, 0
        .equ syntax_word, 1
        .equ syntax_lambda, 2
        .equ syntax_naked_lambda, 3
        .equ syntax_if, 4
        .equ syntax_else, 5
        .equ syntax_begin, 6
        .equ syntax_while, 7
        .equ syntax_do, 8
        
	## Invisible word
	.equ invisible_flag, 0x0000

	## Visible word
	.equ visible_flag, 0x0001

	## Immediate word
	.equ immediate_flag, 0x0002

	## Compile-only word
	.equ compiled_flag, 0x0004

	## Inlined word
	.equ inlined_flag, 0x0008

	## Folded word
	.equ fold_flag, 0x0010

        ## Initialized value word
        .equ init_value_flag, 0x0020
	
	## The internal wordlist
	.equ internal, 1

	## The maximum wordlist order size
	.equ max_order_size, 32

	## Initialize the current RAM pointer
	.set ram_current, ram_start
	
        ## String marker
        .equ start_string, 0xDEFE # Fix later for RISC-V

        ## MIE bit in MSTATUS
        .equ mie_bit, 8

        ## Cell bits
        .equ cell_bits, 32

        ## Cell bytes power of two
        .equ cell_bytes_power, 2
        
        ## Sign shift
        .equ sign_shift, cell_bits - 1

        ## Load a cell
        .macro lc dest, src
        lw \dest, \src
        .endm

        ## Save a cell
        .macro sc src, dest
        sw \src, \dest
        .endm

        ## Push a register
        .macro push reg
        addi sp, sp, -cell
        swsp \reg, 0(sp)
        .endm

        ## Pop a register
        .macro pop reg
        lwsp \reg, 0(sp)
        addi sp, sp, cell
        .endm

        ## Store in the SP
        .macro scsp reg, dest
        swsp \reg, \dest
        .endm

        ## Load in the SP
        .macro lcsp reg, src
        lwsp \reg, \src
        .endm
        
	## Allot space in RAM
	.macro allot name, size
	.equ \name, ram_current
	.set ram_current, ram_current + \size
	.endm

	## Finish an inlined word
	.macro end_inlined
	.hword 0x003F ## movs r7, r7
	.endm
	
	## Word header macro
	.macro define_word name, flags
	.p2align 2
	.byte \flags
        .byte 0xFF
	.hword 0
	.word 10b - 8
10:	.byte 12f - 11f
11:	.ascii "\name"
12:	.p2align 1
	.endm

	## Internal word header macro
	.macro define_internal_word name, flags
	.p2align 2
	.byte \flags
        .byte 0xFF
	.hword internal
	.word 10b - 8
10:	.byte 12f - 11f
11:	.ascii "\name"
12:	.p2align 1
	.endm

	## Push the top of the stack onto the data stack
	.macro push_tos
        addi dp, dp, -cell
        sc tos, 0(dp)
	.endm

	## Push a register onto the data stack
	.macro push_reg reg
        addi dp, dp, -cell
        sc \reg, 0(dp)
	.endm

	## Push a constant onto the top of the stack
	.macro push_const const
	li tos, \const
        addi dp, dp, -cell
        sc tos, 0(dp)
	.endm

	## Pull the top of the stack into the TOS register
	.macro pull_tos
        lc tos, 0(dp)
        addi dp, dp, cell
	.endm

	## String macro
	.macro cstring text, dest
        li \dest, 11f
	b 14f
11:	.byte 13f - 12f
12:	.ascii "\text"
13:	.p2align 1
14:	nop
	.endm

	## String with newline
	.macro cstring_ln text, dest
	li \dest, 11f
	b 14f
11:	.byte 13f - 12f
12:	.ascii "\text\r\n"
13:	.p2align 1
14:	nop
	.endm

	## Push a string onto the stack macro
	.macro string text
        push_tos
	cstring "\text", tos
	addi tos, tos, 1
	push_tos
        lb tos, -1(tos)
	.endm

	## Push a string onto the stack macro
	.macro string_ln text
        push_tos
	cstring_ln "\text", tos
	addi tos, tos, 1
	push_tos
        lb tos, -1(tos)
	.endm
