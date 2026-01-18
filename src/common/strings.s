# Copyright (c) 2020-2026 Travis Bemann
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

	## Advance one character if possible
	define_word "advance-once", visible_flag
_advance_once:
        li x15, eval_index_ptr
        lc x15, 0(x15)
        lc x14, 0(x15)
        li x13, eval_count_ptr
        lc x13, 0(x13)
        lc x12, 0(x13)
        beq x14, x12, 1f
        addi x14, x14, 1
        sc x14, 0(x15)
1:      ret
        end_inlined
	
	## Skip to the start of a token
	define_internal_word "skip-to-token", visible_flag
_skip_to_token:
        push ra
        call _token_start
        li x15, eval_index_ptr
        lc x15, 0(x15)
        sc tos, 0(x15)
        pull_tos
        pop ra
        ret
        end_inlined
	
	## Parse to a character in the input stream
	define_internal_word "parse-to-char", visible_flag
_parse_to_char:
        mv x15, tos
        li x14, eval_index_ptr
        lc x14, 0(x14)
        lc x14, 0(x14)
        li x13, eval_count_ptr
        lc x13, 0(x13)
        lc x13, 0(x13)
        li x12, eval_ptr
        lc x12, 0(x12)
        add x14, x14, x12
        add x13, x13, x12
1:      beq x14, x13, 2f
        lbu x12, 0(x14)
        beq x12, x15, 2f
        addi x14, x14, 1
        b 1b
2:      li x15, eval_index_ptr
        lc x15, 0(x15)
        lc x13, 0(x15)
        li x12, eval_ptr
        lc x12, 0(x12)
        add tos, x13, x12
        push_tos
        sub x14, x14, x12
        sub tos, x14, x13
        li x13, eval_count_ptr
        lc x13, 0(x13)
        lc x13, 0(x13)
        beq x14, x12, 3f
        addi x14, x14, 1
3:      sc x14, 0(x15)
        ret
        end_inlined

	## Immediately type a string in the input stream
	define_word ".(", visible_flag | immediate_flag
_type_to_paren:
        push ra
        push_tos
        li tos, 0x29
        call _parse_to_char
        call _type
        pop ra
        ret
        end_inlined

	## Print a string immediately
	define_word ".\"", visible_flag | immediate_flag | compiled_flag
_type_compiled:
        push ra
        call _compile_imm_string
        push_tos
        li tos, _type
        call _asm_call
        pop ra
        ret
        end_inlined
	
	## Compile a non-counted string
	define_word "s\"", visible_flag | immediate_flag | compiled_flag
_compile_imm_string:
        push ra
        call _compile_imm_cstring
        push_tos
        li tos, _count
        call _asm_call
        pop ra
        ret
        end_inlined

	## Compile a counted-string
	define_word "c\"", visible_flag | immediate_flag | compiled_flag
_compile_imm_cstring:
        push ra
        push_tos
        li tos, 0x22
        call _parse_to_char
        call _compile_cstring
        pop ra
        ret
	end_inlined

	## Compile a counted-string
	define_word "compile-cstring", visible_flag
_compile_cstring:
        push ra
        call _asm_undefer_lit
        push_tos
        li tos, 8 # TOS
        call _asm_push
        call _asm_reserve_branch
        push_tos
        li tos, 1 # C.NOP
        call _current_comma_2
        push_tos
        li tos, start_string
        call _current_comma_2
        call _rot
        call _rot
        call _current_comma_cstring
        push_tos
        li tos, 2
        call _current_align
        call _current_here
        call _swap
        call _asm_branch_back
        pop ra
        ret
        end_inlined
	
	@@ Parse a character and put it on the stack
	define_word "char", visible_flag
_char:	push ra
        call _token
        pull_tos
        lbu tos, 0(tos)
        pop ra
        ret
	end_inlined

	@@ Parse a character and compile it
	define_word "[char]", visible_flag | immediate_flag | compiled_flag
_compile_char:
        push ra
        call _char
        call _comma_lit
        pop ra
        ret
        end_inlined

	@@ Type an integer without a following space
	define_word "(.)", visible_flag
_type_integer:
        addi sp, sp, -2*cell
        scsp ra, 0(sp)
        call _here
        call _swap
        call _format_integer
        scsp tos, cell(sp)
        push_tos
        call _allot
        call _type
        push_tos
        lcsp tos, cell(sp)
        sub tos, zero, tos
        call _allot
        lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
        end_inlined

	@@ Type an unsigned integer without a following space
	define_word "(u.)", visible_flag
_type_unsigned:
        addi sp, sp, -2*cell
        scsp ra, 0(sp)
        call _here
        call _swap
        call _format_unsigned
        scsp tos, cell(sp)
        push_tos
        call _allot
        call _type
        push_tos
        lcsp tos, cell(sp)
        sub tos, zero, tos
        call _allot
        lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
        end_inlined

	@@ Type an unsigned hexadecimal integer safely without a following space
	define_word "debugu.", visible_flag
_debug_unsigned:
        addi sp, sp, -3*cell
        scsp ra, 0(sp)
        call _base
        lc x15, 0(tos)
        pull_tos
        lc x13, 0(x15)
        li x14, 16
        sc x15, 0(x15)
        scsp x13, 2*cell(sp)
        call _here
        call _swap
        call _format_unsigned
        scsp tos, 1*cell(sp)
        push_tos
        call _allot
        call _serial_type
        push_tos
        lcsp tos, 1*cell(sp)
        sub tos, zero, tos
        call _allot
        call _base
        lcsp x13, 2*cell(sp)
        sc x13, 0(tos)
        lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
        end_inlined

	@@ Type an integer with a following space
	define_word ".", visible_flag
_type_space_integer:
        push ra
        call _type_integer
        call _space
        pop ra
        ret
	end_inlined

	@@ Type an unsigned integer with a following space
	define_word "u.", visible_flag
_type_space_unsigned:
        push ra
        call _type_unsigned
        call _space
        pop ra
        ret
	end_inlined
	
	@@ Copy bytes from one buffer to another one (which may overlap)
	define_word "move", visible_flag
_move:  pop ra
        lc x15, 0(dp)
        lc x14, cell(dp)
        bgtu x14, x15, 1f
        call _move_from_high
        j 2f
1:      call _move_from_low
2:      pop ra
        ret
        end_inlined

	@@ Copy bytes starting at a high address
	define_internal_word "<move", visible_flag
_move_from_high:
        mv x15, tos
        lc x14, 0(dp)
        lc x13, 1*cell(dp)
        lc tos, 2*cell(dp)
        addi dp, dp, 3*cell
        add x14, x14, x15
        add x13, x13, x15
1:      beq x15, zero, 2f
        addi x15, x15, -1
        addi x14, x14, -1
        addi x13, x13, -1
        lbu x12, 0(x13)
        sb x12, 0(x14)
        j 1b
2:      ret
        end_inlined

	@@ Copy bytes starting at a low address
	define_internal_word "move>", visible_flag
_move_from_low:
        mv x15, tos
        lc x14, 0(dp)
        lc x13, 1*cell(dp)
        lc tos, 2*cell(dp)
        addi dp, dp, 3*cell
1:      beq x15, zero, 2f
        addi x15, x15, -1
        lbu x12, 0(x13)
        sb x12, 0(x14)
        addi x14, x14, 1
        addi x13, x13, 1
        j 1b
2:      ret
        end_inlined

	@@ Reverse bytes in place
	define_word "reverse", visible_flag
_reverse:
        mv x15, tos
        lc x14, 0(dp)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        add x15, x15, x14
        addi x15, x15, -1
1:      bgeu x14, x15, 2f
        lbu x13, 0(x14)
        lbu x12, 0(x15)
        sb x13, 0(x15)
        sb x12, 0(x14)
        addi x14, x14, 1
        addi x15, x15, -1
        j 1b
2:      ret
        end_inlined

	@@ Format an unsigned integer as a string
	define_word "format-unsigned", visible_flag
_format_unsigned:
        addi sp, sp, -3*cell
        scsp ra, 0(sp)
        beq tos, zero, 1f
        call _format_integer_inner
        call _here
        call _swap
        lc x15, 0(dp)
        scsp x15, 1*cell(sp)
        scsp tos, 2*cell(sp)
        call _reverse
        mv x13, tos
        addi dp, dp, -2*cell
        lcsp x15, 1*cell(sp)
        sc x15, cell(dp)
        sc x13, 0(dp)
        lcsp tos, 2*cell(sp)
        scsp x13, 1*cell(sp)
        call _move
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        lcsp tos, 1*cell(sp)
        sc tos, 0(dp)
        lcsp tos, 2*cell(sp)
        j 2f
1:      lc x14, 0(dp)
        li x15, 0x30
        sb x15, 0(x14)
        li tos, 1
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
        end_inlined
	
	@@ Format an integer as a string
	define_word "format-integer", visible_flag
_format_integer:
        addi sp, sp, -3*cell
        scsp ra, 0(sp)
        beq tos, zero, 1f
        blt tos, zero, 3f
        call _format_integer_inner
        j 4f
3:      sub tos, zero, tos
        call _format_integer_inner
        lc x15, 0(dp)
        add x15, x15, tos
        li x14, 0x2D
        sb x14, 0(x15)
        addi tos, tos, 1        
4:      call _here
        call _swap
        lc x15, 0(dp)
        scsp x15, 1*cell(sp)
        scsp tos, 2*cell(sp)
        call _reverse
        mv x13, tos
        addi dp, dp, -2*cell
        lcsp x15, 1*cell(sp)
        sc x15, cell(dp)
        sc x13, 0(dp)
        lcsp tos, 2*cell(sp)
        scsp x13, 1*cell(sp)
        call _move
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        lcsp tos, 1*cell(sp)
        sc tos, 0(dp)
        lcsp tos, 2*cell(sp)
        j 2f
1:      lc x14, 0(dp)
        li x15, 0x30
        sb x15, 0(x14)
        li tos, 1
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
	end_inlined

	@@ The inner portion of formatting an integer as a string
	define_internal_word "format-integer-inner", visible_flag
_format_integer_inner:
        push ra
        call _base
        lc x14, 0(tos)
        pull_tos
        li x15, 2
        blt x14, x15, 4f
        li x15, 36
        bgt x14, x15, 4f
        call _here
        mv x15, tos
        lc x13, 0(dp)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
1:      beq x13, zero, 3f
        remu x12, x13, x14
        divu x13, x13, x14
        li x11, 10
        bgeu x12, x11, 2f
        addi x12, x12, 0x30
5:      sb x12, 0(x15)
        addi x15, x15, 1
        j 1b
2:      addi x12, x12, 0x37
        j 5b
3:      push_tos
        li tos, x15
        call _here
        call _swap
        mv x15, tos
        pull_tos
        sub tos, x15, tos
        pop ra
        ret
4:      push_tos
        li tos, _invalid_base
        call _raise
        ret # Dummy instruction
	end_inlined

        @ Exception handler for invalid BASE values
        define_word "x-invalid-base", visible_flag
_invalid_base:
        push ra
        string_ln "invalid base (less than 2 or greater than 36)"
        call _type
        pop ra
        ret
        end_inlined
