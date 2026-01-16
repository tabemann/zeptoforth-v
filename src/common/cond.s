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

        ## Start a block
        define_internal_word "begin-block", visible_flag
_begin_block:
        li x15, block_begin_hook
        lc x15, 0(x15)
        bez x15, 1f
        jr x15
1:      ret
        end_inlined
        
        ## End a block
        define_internal_word "end-block", visible_flag
_end_block:
        push ra
        li x15, block_exit_hook
        lc x15, 0(x15)
        beq x15, zero, 1f
        jalr ra, x15
1:      li x15, block_end_hook
        lc x15, 0(x15)
        beq x15, zero, 2f
        jalr ra, x15
2:      pop ra
        ret
        end_inlined
        
	## Start an IF block
	define_word "if", visible_flag | immediate_flag | compiled_flag
_if:	push ra
        call _asm_undefer_lit
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        li tos, 8 # TOS
        sc tos, 0(dp)
        li tos, 15 # x15
        call _asm_mv
        push_tos
        li tos, 8 # TOS
        call _asm_pull
        call _asm_reserve_branch
        call _begin_block
        push_tos
        li tos, syntax_if
        call _push_syntax
        push_tos
        li tos, -1
        pop ra
        ret
	end_inlined

	## ELSE in an IF ELSE THEN block
	define_word "else", visible_flag | immediate_flag | compiled_flag
_else:	addi sp, sp, -2*cell
        scsp ra, 0(sp)
        call _asm_undefer_lit
        push_tos
        li tos, syntax_if
        call _verify_syntax
        call _drop_syntax
        push_tos
        li tos, syntax_else
        call _push_syntax
        beq tos, zero, 1f
	pull_tos
        call _end_block
        mv x15, tos
	pull_tos
        scsp x15, cell(sp)
	call _asm_reserve_branch
	call _current_here
        lcsp x15, cell(sp)
	addi dp, dp, -2*cell
        sc tos, cell(dp)
        li tos, 15 # x15
        sc tos, 0(dp)
        mv tos, x15
	call _asm_branch_zero_back
        call _begin_block
	push_tos
	li tos, false_value
	lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
1:	li tos, _not_following_if
	call _raise
	ret # Dummy instruction
	end_inlined
	
	## Not following an IF exception
	define_word "not-following-if", visible_flag
_not_following_if:
	push ra
	string_ln "not following if"
	call _type
	pop ra
        ret
	end_inlined
	
	## End an IF block
	define_word "then", visible_flag | immediate_flag | compiled_flag
_then:	addi sp, sp, -3*cell
        scsp ra, 0(sp)
	call _asm_undefer_lit
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        li tos, syntax_if
        sc tos, 0(dp)
        li tos, syntax_else
        call _verify_syntax_2
        call _drop_syntax
        call _end_block
        mv x14, tos
        lc x15, 0(dp)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
	call _current_here
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
	push_tos
        li tos, x15
        beq x14, zero, 1f
        push_tos
        li tos, 15 # x15
        call _swap
	call _asm_branch_zero_back
        j 2f
1:	call _asm_branch_back
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
	end_inlined

        ## End an IF block without ending a block
	define_internal_word "then-no-block", visible_flag | immediate_flag | compiled_flag
_then_no_block:
addi sp, sp, -3*cell
        scsp ra, 0(sp)
	call _asm_undefer_lit
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        li tos, syntax_if
        sc tos, 0(dp)
        li tos, syntax_else
        call _verify_syntax_2
        call _drop_syntax
        mv x14, tos
        lc x15, 0(dp)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
	call _current_here
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
	push_tos
        li tos, x15
        beq x14, zero, 1f
        push_tos
        li tos, 15 # x15
        call _swap
	call _asm_branch_zero_back
        j 2f
1:	call _asm_branch_back
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
	end_inlined

	## Start a BEGIN block
	define_word "begin", visible_flag | immediate_flag | compiled_flag
_begin:	push ra
        call _asm_undefer_lit
        call _current_here
        call _begin_block
        push_tos
        li tos, syntax_begin
        call _push_syntax
        pop ra
        ret
        end_inlined

	## Start a WHILE block
	define_word "while", visible_flag | immediate_flag | compiled_flag
_while: push ra
        call _asm_undefer_lit
        push_tos
        li tos, syntax_begin
        call _verify_syntax
        call _drop_syntax
        push_tos
        li tos, syntax_while
        call _push_syntax
        call _end_block
        addi dp, dp -2*cell
        sc tos, cell(dp)
        li tos, 8 # TOS
        sc tos, 0(dp)
        li tos, 15 # x15
        call _asm_mv
        push_tos
        li tos, 8 # TOS
        call _asm_pull
        call _asm_reserve_branch
        call _begin_block
        pop ra
        ret
	end_inlined

	## End a BEGIN-WHILE-REPEAT block
	define_word "repeat", visible_flag | immediate_flag | compiled_flag
_repeat:
        addi sp, sp, -2*cell
        scsp ra, 0(sp)
        call _asm_undefer_lit
        push_tos
        li tos, syntax_while
        call _verify_syntax
        call _drop_syntax
        call _end_block
        scsp tos, cell(sp)
        pull_tos
        call _asm_branch
        call _current_here
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        li tos, 15 # x15
        sc tos, 0(dp)
        lcsp tos, cell(sp)
        call _asm_branch_zero_back
        lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
        end_inlined

	## End a BEGIN-UNTIL block
	define_word "until", visible_flag | immediate_flag | compiled_flag
_until:	push ra
        call _asm_undefer_lit
        push_tos
        li tos, syntax_begin
        call _verify_syntax
        call _drop_syntax
        call _end_block
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        li tos, 8 # TOS
        sc tos, 0(dp)
        li tos, 15 # x15
        call _asm_mv
        push_tos
        li tos, 8 # TOS
        call _asm_pull
	call _asm_branch_zero
	pop ra
        ret
	end_inlined

	## End a BEGIN-AGAIN block
	define_word "again", visible_flag | immediate_flag | compiled_flag
_again:	push ra
	call _asm_undefer_lit
        push_tos
        li tos, syntax_begin
        call _verify_syntax
        call _drop_syntax
        call _end_block
	call _asm_branch
	pop ra
        ret
	end_inlined

	## Implement the core of DO
	define_internal_word "(do)", visible_flag
_xdo:   lc x15, 0(dp)
        lc x14, 1*cell(dp)
        lc x13, 2*cell(dp)
        sc tos, 2*cell(dp)
        sc x15, 1*cell(dp)
        sc x14, 0(dp)
        mv tos, x13
        ret
	end_inlined

	## Implement the core of ?DO
	define_internal_word "(?do)", visible_flag
_xqdo:  lc x15, 0(dp)
        lc x14, 1*cell(dp)
        lc x13, 2*cell(dp)
        addi dp, dp, 3*cell
        beq x15, x14, 1f
        addi dp, dp, -3*cell
        sc tos, 2*cell(dp)
        sc x15, 1*cell(dp)
        sc x14, 0(dp)
        mv tos, x13
        ret
1:      mv x15, tos
        mv tos, x13
        jr x15
        ret # Dummy instruction
        end_inlined

	## Implement the core of LOOP
	define_internal_word "(loop)", visible_flag
_xloop: lcsp x15, cell(sp)
        lcsp x14, 0(sp)
        addi x15, x15, 1
        beq x15, x14, 1f
        scsp x15, cell(sp)
        mv x15, tos
        pull_tos
        jr x15
1:      pull_tos
        addi sp, sp, 3*cell
        ret
        end_inlined

	## Implement the core of +LOOP
	define_internal_word "(+loop)", visible_flag
_xploop:
        lcsp x15, cell(sp)
        lcsp x14, 0(sp)
        lc x13, 0(dp)
        blt x13, zero, 1f
        add x15, x15, x13
        bge x15, x14, 2f
        scsp x15, cell(sp)
        mv x15, tos
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        jr x15
1:      add x15, x15, x13
        blt x15, x14, 2f
        scsp x15, cell(sp)
        mv x15, tos
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        jr x15
2:      lc tos, cell(dp)
        addi dp, dp, 2*cell
        addi sp, sp, 3*cell
        ret
	end_inlined

	## Get the outermost loop index
	define_word "i", visible_flag | inlined_flag
_i:	push_tos
        lcsp tos, cell(sp)
        ret
	end_inlined

	## Get the first inner loop index
	define_word "j", visible_flag | inlined_flag
_j:	push_tos
	lcsp tos, 4*cell(sp)
	ret
	end_inlined

	## Leave a do loop
	define_word "leave", visible_flag
_leave:	lcsp ra, 2*cell(sp)
        addi sp, sp, 3*cell
        ret
	end_inlined

	## Unloop a do loop
	define_word "unloop", visible_flag | inlined_flag
_unloop:
        addi sp, sp, 3*cell
        ret
	end_inlined
