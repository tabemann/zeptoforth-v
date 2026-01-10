# Copyright (c) 2019-2026 Travis Bemann
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

	## Test whether a character is whitespace.
	define_word "ws?", visible_flag
_ws_q:	addi tos, tos, -0x20
        seqz tos, tos
        sub tos, zero, tos
        ret
	end_inlined

	## Test whether a character is a newline.
	define_word "newline?", visible_flag
_newline_q:
        addi tos, tos, -0x0A
        seqz x15, tos
        addi tos, tos, -(0x0D - 0x0A)
        seqz tos, tos
        or tos, tos, x15
        sub tos, zero,tos
        ret
	end_inlined

	## Parse the input buffer for the start of a token
	define_word "token-start", visible_flag
_token_start:
        addi sp, sp, -2*cell
        scsp ra, 0(sp)
        li x15, eval_index_ptr
        lc x15, 0(x15)
        lc x14, 0(x15)
        push_tos
1:      li x15, eval_count_ptr
        lc x15, 0(x15)
        lc x13, 0(x15)
        beq x14, x13, 2f
        li x15, eval_ptr
        lc x15, 0(x15)
        add x15, x15, x14
        lbu tos, 0(x15)
        scsp x14, cell(sp)
        call _ws_q
        lcsp x14, cell(sp)
        beq tos, zero, 2f
        addi x14, x14, 1
        j 1b
2:      mv tos, x14
        lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
        end_inlined

	## Parse the input buffer for the end of a token
	define_word "token-end", visible_flag
_token_end:
        addi sp, sp, -2*cell
        scsp ra, 0(sp)
        mv x14, tos
1:      li x15, eval_count_ptr
        lc x15, 0(x15)
        lc x13, 0(x15)
        beq x14, 13, 2f
        li x15, eval_ptr
        lc x15, 0(x15)
        add x15, x15, x14
        lbu tos, 0(x15)
        scsp x14, cell(sp)
        call _ws_q
        lcsp x14, cell(sp)
        bne tos, zero, 2f
        addi x14, x14, 1
        j 1b
2:      mov tos, x14
        lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
        end_inlined

	## Parse a token
	define_word "token", visible_flag
_token: addi sp, sp, -2*cell
        scsp ra, 0(sp)
        call _token_start
        scsp tos, cell(sp)
        call _token_end
        lcsp x15, cell(sp)
        mv x14, tos
        li tos, eval_ptr
        lc tos, 0(tos)
        addi tos, tos, x15
        push_tos
        sub tos, x14, x15
        li x15, eval_index_ptr
        lc x15, 0(x15)
        sc x14, 0(x15)
        call _advance_once
        lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
        end_inlined

	## Parse a line comment
	define_word "\\", visible_flag | immediate_flag
_line_comment:
        sub sp, sp, -4*cell
        scsp ra, 0(sp)
        li x15, eval_index_ptr
        lc x15, 0(x15)
        lc x15, 0(x15)
        li x14, eval_count_ptr
        lc x14, 0(x14)
        lc x14, 0(x14)
        li x13, eval_ptr
        lc x13, 0(x13)
        push_tos
1:      beq x15, x14, 2f
        add x12, x15, x13
        lbu tos, 0(x12)
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        scsp x13, 3*cell(sp)
        call _newline_q
        lcsp x13, 3*cell(sp)
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
        beq tos, zero, 2f
        addi x15, x15, 1
        j 1b
2:      pull_tos
        li x14, eval_index_ptr
        lc x14, 0(x14)
        sc x15, 0(x14)
        lcsp ra, 0(sp)
        addi sp, sp, 4*cell
        ret
        end_inlined

	## Parse a paren coment
	define_word "(", visible_flag | immediate_flag
_paren_comment: 
        li x15, eval_index_ptr
        lc x15, 0(x15)
        lc x15, 0(x15)
        li x14, eval_count_ptr
        lc x14, 0(x14)
        lc x14, 0(x14)
        li x13, eval_ptr
        lc x13, 0(x13)
1:      beq x15, x14, 3f
        add x12, x15, x13
        lbu x12, 0(x12)
        addi x12, x12, -0x29
        beq x12, zero, 2f
        addi x15, x15, 1
        j 1b
2:      addi x15, x15, 1
3:      li x14, eval_index_ptr
        lc x14, 0(x14)
        sc x15, 0(x14)
        ret
	end_inlined
	
	## Convert a character to being uppercase
	define_word "to-upper-char", visible_flag
_to_upper_char:
        li x15, 0x7A
        sltiu x14, tos, 0x61
        slti x13, x15, tos
        or x14, x14, x13
        bne x14, zero, 2f
        addi tos, tos, -0x20
1:      ret
	end_inlined

	## Compare whether two strings are equal ignoring ASCII case
	define_word "equal-case-strings?", visible_flag
_equal_case_strings:
        mv x15, tos
        lc x14, 0(dp)
        lc x13, 1*cell(dp)
        lc x12, 2*cell(dp)
        addi dp, dp, 3*cell
        beq x15, x13, 3f
1:      beq x15, zero, 2f
        lbu x13, 0(x14)
        addi x14, x14, 1
        li x11, 0x61
        bltiu x13, x11, 4f
        li x11, 0x7A
        bltiu x11, x13, 4f
        addi x13, x13, -0x20
4:      lbu tos, 0(x12)
        addi x12, x12, 1
        li x11, 0x61
        bltiu tos, x11, 5f
        li x11, 0x7A
        bltiu x11, tos, 5f
        addi tos, tos, -0x20
5:      addi x15, x15, -1
        beq x13, tos, 1b
3:      li tos, false_flag
        ret
2:      li tos, true_flag
        ret
        end_inlined

	## Find a word in a specific dictionary for a specific wordlist
	## ( addr bytes dict wid -- addr|0 )
	define_internal_word "find-dict", visible_flag
_find_dict:
        addi sp, sp, -7*cell
        scsp ra, 0(sp)
        mv x10, tos
        lc x15, 0(dp)
        lc x13, 1*cell(dp)
        lc x12, 2*cell(dp)
        addi dp, dp, 3*cell
1:      beq x15, zero, 3f
        lhu x11, 0(x15)
        andi x11, x11, visible_flag
        beq x11, zero, 2f
        lhu x11, 2(x15)
        bne x11, x10, 2f
        lbu x11, 4+cell(x15)
        addi dp, dp, 3*cell
        sc x12, 2*cell(dp)
        sc x13, 1*cell(dp)
        addi tos, x15, 5+cell
        sc tos, 0(dp)
        mv tos, x11
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        scsp x13, 3*cell(sp)
        scsp x12, 4*cell(sp)
        scsp x11, 5*cell(sp)
        scsp x10, 6*cell(scsp)
        call _equal_case_strings
        lcsp x15, 1*cell(sp)
        lcsp x14, 2*cell(sp)
        lcsp x13, 3*cell(sp)
        lcsp x12, 4*cell(sp)
        lcsp x11, 5*cell(sp)
        lcsp x10, 6*cell(sp)
        bne tos, zero, 4f
2:      lc x15, 4(x15)
        j 1b
3:      li tos, false_value
        j 5f
4:      mv tos, x15
5:      lcsp ra, 0(sp)
        addi sp, sp, 7*cell
        ret
        end_inlined

	## Duplicate three items on the stack
	define_word "3dup", visible_flag
_3dup:	push_tos
        lc tos, 2*cell(dp)
	push_tos
        lc tos, 2*cell(dp)
	push_tos
        lc tos, 2*cell(dp)
        ret
	end_inlined

	## Find a word in a specific wordlist
	## ( addr bytes wid -- addr|0 )
	define_internal_word "find-in-wordlist", visible_flag
_find_in_wordlist:
        addi sp, sp, -2*cell
        scsp ra, 0(sp)
        li x15, compiling_to_flash
        lc x15, 0(x15)
        bne x15, zero, 1f
3:      mv x15, tos
        pull_tos
        scsp x15, cell(sp)
        call _2dup
        lcsp x15, cell(sp)
        push_tos
        li x14, ram_latest
        lc tos, 0(x14)
        push_tos
        mv tos, x15
        scsp x15, cell(sp)
        call _find_dict
        lcsp x15, cell(sp)
        bne tos, zero, 2f
4:      li x14, flash_latest
        lc tos, 0(x14)
        push_tos
        mv tos, x15
        call _find_dict
        lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
1:      li x15, state
        lc x15, 0(x15)
        beq x15, zero, 3b
        mv x15, tos
        j 4b
2:      addi dp, dp, 2*cell
        lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
        end_inlined
	
	## Find a word in the dictionary according to the word order list
	## ( addr bytes -- addr|0 )
	define_word "do-find", visible_flag
_do_find:
        addi sp, sp, -3*cell
        scsp ra, 0(sp)
        li x15, order_count
        lc x15, 0(x15)
        li x14, order
1:      beq x15, zero, 2f
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        call _2dup
        lcsp x14, 2*cell(sp)
        push_tos
        lhu tos, 0(x14)
        call _find_in_wordlist
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
        bne tos, zero, 3f
        addi x15, x15, -1
        addi x14, x14, 2
        pull_tos
        j 1b
2:      addi dp, dp, cell
        li tos, false_flag
        j 4f
3:      addi dp, dp, 2*cell
4:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
        end_inlined

	## Invoke the find hook
	## ( b-addr bytes -- addr|0 )
	define_word "find", visible_flag
_find:	li x15, find_hook
        lc x15, 0(x15)
        beq x15, zero, 1f
        jr x15
1:      push_tos
        li tos, _hook_needed
        call _raise
        ret # Dummy instruction
	end_inlined

	## Invoke the find raw hook
	## ( b-addr bytes -- addr|0 )
	define_word "find-raw", visible_flag
_find_raw:
        li x15, find_raw_hook
        lc x15, 0(x15)
        beq x15, zero, 1f
        jr x15
1:      push_tos
        li tos, _hook_needed
        call _raise
        ret # Dummy instruction
	end_inlined

	## Hook needed exception handler
	define_word "x-hook-needed", visible_flag
_hook_needed:
        push ra
	string_ln "hook needed"
	call _type
        pop ra
        ret
        end_inlined
	
	## Find a word in a specific dictionary in any wordlist in order of
	## definition
	## ( addr bytes dict -- addr|0 )
	define_word "find-all-dict", visible_flag
_find_all_dict:
        addi sp, sp, -6*cell
        scsp ra, 0(sp)
        mv x15, tos
        lc x13, 0(dp)
        lc x12, cell(dp)
        addi dp, dp, 2*cell
1:      beq x15, zero, 3f
        lhu x11, 0(x15)
        andi x11, x11, visible_flag
        beq x11, zero, 2f
        lbu x11, 4+cell(x15)
        addi dp, dp, 3*cell
        sc x12, 2*cell(dp)
        sc x13, 1*cell(dp)
        addi tos, x15, 5+cell
        sc tos, 0(dp)
        mv tos, x11
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        scsp x13, 3*cell(sp)
        scsp x12, 4*cell(sp)
        scsp x11, 5*cell(sp)
        call _equal_case_strings
        lcsp x15, 1*cell(sp)
        lcsp x14, 2*cell(sp)
        lcsp x13, 3*cell(sp)
        lcsp x12, 4*cell(sp)
        lcsp x11, 5*cell(sp)
        bne tos, zero, 4f
2:      lc x15, 4(x15)
        j 1b
3:      li tos, false_value
        j 5f
4:      mv tos, x15
5:      lcsp ra, 0(sp)
        addi sp, sp, 6*cell
        ret
	end_inlined

	## Find a word in the dictionary in any wordlist in order of definition
	## ( addr bytes -- addr|0 )
	define_word "find-all", visible_flag
_find_all:
        addi sp, sp, -3*cell
        scsp ra, 0(sp)
        li x15, compiling_to_flash
        lc x15, 0(x15)
        bne x15, zero, 1f
3:      mv x14, tos
        pull_tos
        mv x13, tos
        push_tos
        mv tos, x14
        push_tos
        li x12, ram_latest
        lc tos, 0(x12)
        scsp x14, 1*cell(sp)
        scsp x13, 2*cell(sp)
        call _find_all_dict
        lcsp x13, 2*cell(sp)
        lcsp x14, 1*cell(sp)
        bne tos, zero, 2f
        addi dp, dp, 2*cell
        sc x13, cell(dp)
        sc x14, 0(dp)
        li x12, flash_latest
        lc tos, 0(x12)
        call _find_all_dict
        j 2f
1:      li x15, state
        lc x15, 0(x15)
        beq x15, zero, 3b
        push_tos
        li x15, flash_latest
        lc tos, 0(x15)
        call _find_all_dict
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
        end_inlined

	## Get an xt from a word
	define_word ">xt", visible_flag
_to_xt: push ra
        push_tos
        addi tos, tos, 4 + cell
        call _get_flash_buffer_value_1
        mv x15, tos
        pull_tos
        addi tos, tos, 5 + cell
        add tos, tos, x15
        andi x15, tos, 3
        beq x15, zero, 1f
        ori tos, tos, 3
        addi tos, tos, 1
1:      pop ra
        ret
        end_inlined

	## Abort
	define_word "abort", visible_flag
_abort: call _stack_base
        lc dp, 0(tos)
        li x15, word_reset_hook
        lc x15, 0(x15)
        beq x15, zero, 1f
        jalr ra, x15
1:      call _bel
        call _nak
        j _quit
        ret # Dummy instruction
        end_inlined
        
        ## Prepare the prompt
        define_internal_word "prepare-prompt" visible_flag
_prepare_prompt:
        li x14, false_value
        li x15, prompt_disabled
        sc x14, 0(x15)
        li x15, eval_data
        sc x14, 0(x15)
        li x14, _quit_refill
        li x15, eval_refill
        sc x14, 0(x15)
        li x14, _quit_eof
        li x15, eval_eof
        sc x14, 0(x15)
        li x14, input_buffer_index
        li x15, eval_index_ptr
        sc x14, 0(x15)
        li x14, input_buffer_count
        li x15, eval_count_ptr
        sc x14, 0(x15)
        li x14, input_buffer
        li x15, eval_ptr
        sc x14, 0(x15)
        ret
        end_inlined
        
        ## QUIT refill word
        define_internal_word "quit-refill", visible_flag
_quit_refill:
        li x15, refill_hook
        lc x15, 0(x15)
        beq x15, zero, 1f
        jr x15
1:      ret
        end_inlined

        ## QUIT EOF word
        define_internal_word "quit-eof?", visible_flag
_quit_eof:
        push_tos
        li tos, false_value
        ret
        end_inlined

	## QUIT while resetting the state
	define_word "quit-reset", visible_flag
_quit_reset:
        call _stack_base
        lc dp, 0(tos)
        li x15, word_reset_hook
        lc x15, 0(x15)
        beq x15, zero, 1f
        jalr ra, x15
1:      j _quit
        ret # Dummy instruction
	end_inlined

        ## Use error-emit and error-emit? hooks for an xt
        define_word "with-error-console", visible_flag
_with_error_console:
        li x15, error_hook
        lc x15, 0(x15)
        jr x15
        ret # Dummy instruction
        end_inlined
        
        ## The outer loop of Forth
	define_word "quit", visible_flag
_quit:  call _rstack_base
        lc tos, 0(tos)
        mv sp, tos
        li x15, syntax_stack + syntax_stack_size
        li x14, syntax_stack-ptr
        sc x15, 0(x14)
        li x15, state
        li x14, false_value
        sc x14, 0(x15)
        li x15, current_compile
        sc x14, 0(x15)
        li x15, current_unit_start
        sc x14, 0(x15)
        li x15, postpone_literal_q
        sc x14, 0(x15)
        call _prepare_prompt
        li tos, _main
        call _try
        push_tos
        li tos, _quit_error
        call _with_error_console
        j _abort
        ret # Dummy instruction
        end_inlined

        ## Display an error
_quit_error:
        push ra
        call _display_red
        beq tos, zero, 1f
        call _try
1:      pull_tos
        call _display_normal
        pop ra
        ret
	end_inlined

	## Display red text
	define_word "display-red", visible_flag
_display_red:
        push ra
        li x15, =color_enabled
        lc x15, 0(x15)
        beq x15, zero, 1f
	string "\x1B[31;1m"
        call_type
1:      pop ra
        ret
        end_inlined

	## Display normal text
	define_word "display-normal", visible_flag
_display_normal:
        push ra
        li x15, =color_enabled
        lc x15, 0(x15)
        beq x15, zero, 1f
	string "\x1B[0m"
        call_type
1:      pop ra
        ret
        end_inlined

	## The main functionality, within the main exception handler
	define_internal_word "main", visible_flag
_main:  push ra
        call _flush_all_flash
        li x15, state
        li x14, 0
        sc x14, 0(x15)
        call _refill
        call _outer
        pop ra
        ret
        end_inlined

        ## The main loop of the outer interpreter
        define_word "outer", visible_flag
_outer: push ra
1:      call _display_entry_spce
        call _interpret_line
        call _display_prompt
        li x15, eval_eof
        lc x15, 0(x15)
        jalr ra, x15
        bne tos, zero, 2f
        pull_tos
        call _refill
        j 1b
2:      pull_tos
        pop ra
        ret
        end_inlined

        ## Display the space after entry
        define_word "display-entry-space", visible_flag
_display_entry_space:
        li x15, prompt_disabled
        lc x15, 0(x15)
        bnez x15, zero, 1f
        j _space
1:      ret
        end_inlined
        
        ## Display the prompt
        define_word "display-prompt", visible_flag
_display_prompt:
        li x15, prompt_disabled
        lc x15, 0(x15)
        bnez x15, zero, 1f
        li x15, prompt_hook
        lc x15, 0(x15)
        bnez x15, zero, 1f
        jr x15
1:      ret
        end_inlined
        
	## Interpret a line of Forth code
	define_internal_word "interpret-line", visible_flag
_interpret_line:
        push ra
1:      call _validate
        call _token
        beq tos, zero, 2f
        mv x15, tos
        lc x14, 0(dp)
        addi sp, sp, -2*cell
        scsp x15, 0(sp)
        scsp x14, cell(sp)
        li x13, parse_hook
        lc x13, 0(x13)
        beq x13, zero, 5f
        jalr ra, x13
        beq tos, zero, 3f
        lcsp x14, cell(sp)
        lcsp x15, 0(sp)
        addi sp, sp, 2*cell
        pull_tos
        j 1b
3:      addi dp, dp, -cell
        lc x14, cell(sp)
        sc x14, 0(dp)
        lc tos, 0(sp)
5:      call _find
        lcsp x14, cell(sp)
        lcsp x15, 0(sp)
        addi sp, sp, 2*cell
        beq tos, zero, 3f
        li x15, state
        lc x15, 0(x15)
        bne x15, zero, 4f
        lbu x15, 0(tos)
        andi x14, x15, compiled_flag
        bne x14, zero, 5f
6:      call _to_xt
        call _execute
        j 1b
3:      addi dp, dp, -cell
        sc x14, 0(dp)
        mv tos, x15
        call _parse_literal
        j 1b
4:      lbu x15, 0(tos)
        andi x14, x15, immediate_flag
        bne x14, zero, 6b
        andi x14, x15, inlined_flag
        bne x14, zero, 7f
        andi x14, x15, fold_flag
        bne x14, zero, 8f
        call _to_xt
        call _asm_call
        j 1b
5:      push_tos
        li tos, _not_compiling
        call _raise
        j 1b
7:      call _to_xt
        call _asm_inline
        j 1b
8:      call _to_xt
        call _asm_fold
        j 1b
2:      lc tos, cell(dp)
        addi dp, dp, 2*cell
        pop ra
        ret
        end_inlined
	
	## Validate the current state
	define_internal_word "validate", visible_flag
_validate:
        push ra
        call _stack_base
        lc x15, 0(tos)
        pull_tos
        bleu dp, x15, 1f
        push_tos
        li tos, _stack_underflow
        call _raise
1:      call _stack_end
        lc x15, 0(tos)
        pull_tos
        bgeu dp, x15, 1f
        push_tos
        li tos, _stack_overflow
        call _raise
1:      mv x14, sp
        push x14
        call _rstack_base
        pop x14
        lc x15, 0(tos)
        pull_tos
        ble x14, x15, 1f
        push_tos
        li tos, _rstack_underflow
        call _raise
1:      push x14
        call _rstack_end
        pop x14
        lc x15, 0(tos)
        pull_tos
        bge x14, x15, 1f
        push_tos
        li tos, _rstack_overflow
        call _raise
1:      li x15, validate_dict_hook
        lc x15, 0(x15)
        beq x15, zero, 1f
        jalr ra, x15
1:      pop ra
        ret
	end_inlined

	## Stack overflow exception
	define_word "stack-overflow", visible_flag
_stack_overflow:
        push ra
	string_ln "stack overflow"
	call _type
	pop ra
        ret
	end_inlined

	## Stack underflow exception
	define_word "stack-underflow", visible_flag
_stack_underflow:
        push ra
	string_ln "stack underflow"
	call _type
        pop ra
        ret
	end_inlined

	## Return stack overflow exception
	define_word "rstack-overflow", visible_flag
_rstack_overflow:
	push ra
	string_ln "return stack overflow"
	call _type
	pop ra
        ret
	end_inlined

	## Return stack underflow exception
	define_word "rstack-underflow", visible_flag
_rstack_underflow:
	push ra
	string_ln "return stack underflow"
	call _type
	pop ra
        ret
	end_inlined

	## Display a prompt
	define_internal_word "do-prompt", visible_flag
_do_prompt:
	push ra
	string_ln " ok"
        call _type
	pop ra
        ret
	end_inlined

	## Parse a literal word
	define_internal_word "parse-literal", visible_flag
_parse_literal:
        addi sp, sp, -3*cell
        scsp ra, 0(sp)
        mv x15, tos
        lc x14, cell(dp)
        lc tos, 0(dp)
        addi dp, dp, 2*cell
        li x13, handle_number_hook
        lc x13, 0(x13)
        beq x13, zero, 1f
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        addi dp, dp -2*cell
        sc tos, cell(dp)
        sc x14, 0(dp)
        mv tos, x15
        jalr ra, x13
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
        beq tos, zero, 1f
        pull_tos
        j 2f
1:      li x13, failed_parse_hook
        lc x13, 0(x13)
        beq x13, zero, 2f
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        sc x14, 0(dp)
        mv tos, x15
        jalr ra, x13
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
        end_inlined

	## Refill the input buffer
	define_word "refill", visible_flag
_refill:
        li x15, eval_refill
        lc x15, 0(x15)
        beq x15, zero, 1f
        jr x15
1:      ret
	end_inlined

	## Send XON
	define_word "xon", visible_flag
_xon:   li x15, xon_xoff_enabled
        lc x15, 0(x15)
        beq x15, zero, 1f
        push_tos
        li tos, 0x11
        j _emit
1:      ret
	end_inlined

	## Send XOFF
	define_word "xoff", visible_flag
_xoff:	li x15, xon_xoff_enabled
        lc x15, 0(x15)
        beq x15, zero, 1f
        push_tos
        li tos, 0x13
        j _emit
1:      ret
	end_inlined

	## Send ACK
	define_word "ack", visible_flag
_ack:	li x15, ack_nak_enabled
        lc x15, 0(x15)
        beq x15, zero, 1f
        push_tos
        li tos, 0x06
        j _emit
1:      ret
	end_inlined

	## Send NAK
	define_word "nak", visible_flag
_nak:	li x15, ack_nak_enabled
        lc x15, 0(x15)
        beq x15, zero, 1f
        push_tos
        li tos, 0x15
        j _emit
1:      ret
	end_inlined

	## Send BEL
	define_word "bel", visible_flag
_bel:	li x15, bel_enabled
        lc x15, 0(x15)
        beq x15, zero, 1f
        push_tos
        li tos, 0x07
        j _emit
1:      ret
	end_inlined

	## Implement the refill hook
	define_internal_word "do-refill", visible_flag
_do_refill:
        addi sp, sp, -4*cell
        scsp ra, 0(sp)
        call _xon
        call _ack
        li x14, input_buffer_size
        li x13, input_buffer
        mv x15, x13
        add x14, x14, x13
1:      beq x15, x14, 2f
6:      scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        call _key
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
        li x12, 0x0D
        beq tos, x12, 3f
        li x12, 0x0A
        beq tos, x12, 3f
        li x12, 0x7F
        beq tos, x12, 4f
        li x12, 0x09
        beq tos, x12, 8f
        li x12, 0x20
        bltu tos, x12, 7f
8:      sb tos, 0(x15)
        addi x15, x15, 1
        mv x13, tos
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        scsp x13, 3*cell(sp)
        call _emit
        lcsp x13, 3*cell(sp)
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
        j 1b
7:      pull_tos
        b 6b
4:      li x13, input_buffer
        beq x15, x13, 7b
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        li tos, 0x08
        call _emit
        push_tos
        li tos, 0x20
        call _emit
        push_tos
        li tos, 0x08
        call _emit
        lcsp x15, 1*cell(sp)
        lcsp x14, 2*cell(sp)
4:      li x13, input_buffer
        beq x15, x13, 1b
        addi x15, x15, -1
        lbu x13, 0(x15)
        andi x12, x13, 0x80
        beq x12, zero, 1b
        mv x12, x15
        addi x12, x12, -1
        li x13, input_buffer
        beq x12, x13, 1b
        lbu x13, 0(x12)
        andi x12, x13, 0x80
        bne x12, zero, 4b
        j 1b
3:      pull_tos
2:      li x13, input_buffer
        sub x15, x15, x13
        li x13, input_buffer_count
        sc x15, 0(x13)
        li x15, 0
        li x13, input_buffer_index
        sc x15, 0(x13)
        call _xoff
        lcsp ra, 0(sp)
        addi sp, sp, 4*cell
        ret
        end_inlined
	
	## Implement the failed parse hook
	define_internal_word "do-failed-parse", visible_flag
_do_failed_parse:
        push_tos
        li tos, _really_do_failed_parse
        j _with_error_console
_really_do_failed_parse:
        push ra
	call _display_red
	string "unable to parse: "
	call _type
	call _type
	string_ln ""
	call _type
	call _display_normal
	push_tos
	li tos, _failed_parse
	call _raise
        pop ra
        ret
	end_inlined

	## Failed parse exception
	define_word "x-failed-parse", visible_flag
_failed_parse:
        ret
	end_inlined
	
	## Implement the handle number hook
	define_internal_word "do-handle-number", visible_flag
_do_handle_number:
        push ra
        call _parse_integer
        beq tos, zero, 2f
        pull_tos
        li x15, state
        lc x15, 0(x15)
        beq x15, zero, 1f
        call _comma_lit
1:      push_tos
        li tos, true_value
        j 3f
2:      pull_tos
        li tos, false_value
3:      pop ra
        ret
        end_inlined

	## Parse an integer ( addr bytes -- n success )
	define_word "parse-integer", visible_flag
_parse_integer:
	push ra
	call _parse_base
	call _parse_integer_core
	pop ra
        ret
	end_inlined

	## Parse an unsigned integer ( addr bytes -- u success )
	define_word "parse-unsigned", visible_flag
_parse_unsigned:
	push ra
	call _parse_base
        lc x15, 0(dp)
        beq x15, zero, 1f
	call _parse_unsigned_core
        j 2f
1:	pull_tos
	li tos, 0
	sc tos, 0(dp)
2:      pop ra
        ret
	end_inlined

	## Actually parse an integer base ( addr bytes -- addr bytes base )
	define_word "parse-base", visible_flag
_parse_base:
        push ra
        beq tos, zero, 5f
        mv x15, tos
        pull_tos
        lbu x14, 0(tos)
        li x13, 0x24
        bne x14, x13, 1f
        li x14, 16
        j 6f
1:      li x13, 0x23
        bne x14, x13, 2f
        li x14, 10
        j 6f
2:      li x13, 0x2F
        bne x14, x13, 3f
        li x14, 8
        j 6f
3:      li x13, 0x25
        bne x14, x13, 4f
        li x14, 2
        j 6f
4:      push_tos
        mv tos, x15
5:      call _base
        lc tos, 0(tos)
        j 7f
6:      addi tos, tos, 1
        push_tos
        addi x15, x15, -1
        addi dp, dp, -cell
        sc x15, 0(dp)
        mv tos, x14
7:      pop ra
        ret
        end_inlined

	## Actually parse an integer ( addr bytes base -- n success )
	define_internal_word "parse-integer-core", visible_flag
_parse_integer_core:
        push ra
        mv x13, tos
        pull_tos
        beq tos, zero, 3f
        mv x15, tos
        pull_tos
        lbu x14, 0(tos)
        li x12, 0x2D
        beq x14, x12, 1f
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        sc x15, 0(dp)
        mv tos, x13
        call _parse_unsigned_core
        j 4f
1:      addi dp, dp, -2*cell
        addi tos, tos, 1
        sc tos, cell(dp)
        addi x15, x15, -1
        sc x15, 0(dp)
        mv tos, x13
        call _parse_unsigned_core
        beq tos, zero, 2f
        sc x15, 0(dp)
        not x15, x15
        addi x15, x15, 1
        j 4f
3:      addi dp, dp, cell
        li tos, 0
        sc tos, 0(dp)
4:      pop ra
        ret
        end_inlined
	
	## Actually parse an unsigned integer ( addr bytes base  -- u success )
	define_internal_word "parse-unsigned-core", visible_flag
_parse_unsigned_core:
        addi sp, sp, -5*cell
        scsp ra, 0(sp)
        mv x15, tos
        scsp x15, 1*cell(sp)
        lc x14, 2*cell(dp)
        lc x13, 1*cell(dp)
        lc tos, 0(dp)
        li x12, 0
1:      beq x14, zero, 3f
        push_tos
        lbu tos, 0(x13)
        addi x14, x14, -1
        addi x13, x13, 1
        li x11, 0x5F # underscore
        bne tos, x11, 4f
        pull_tos
        j 1b
4:      mul x12, x12, x15
        push_tos
        mv tos, x15
        scsp x14, 2*cell(sp)
        scsp x13, 3*cell(sp)
        scsp x12, 4*cell(sp)
        call _parse_digit
        lcsp x12, 4*cell(sp)
        lcsp x13, 3*cell(sp)
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
        beq tos, zero, 2f
        pull_tos
        add x12, x12, tos
        pull_tos
        j 1b
2:      li tos, false_value
        sc tos, 0(dp)
        j 4f
3:      addi dp, dp, -2*cell
        sc tos, cell(dp)
        sc x12, 0(dp)
        li tos, true_value
4:      pop ra
        ret
        end_inlined

	## Parse a digit ( c base -- digit success )
	define_word "parse-digit", visible_flag
_parse_digit:
        addi sp, sp, -2*cell
        scsp ra, 0(sp)
        li x15, 2
        blt tos, x15, 1f
        li x15, 36
        bgt tos, x15, 1f
        mv x15, tos
        pull_tos
        li x14, 0x30
        li x13, 0x39
        blt tos, x14, 1f
        bgt tos, x13, 2f
        addi tos, tos, -0x30
        j 3f
1:      li tos, 0
        push_tos
        j 4f
2:      scsp x15, cell(sp)
        call _to_upper_char
        lcsp x15, cell(sp)
        li x14, 0x41
        li x13, 0x5A
        blt tos, x14, 1b
        bgt tos, x13, 1b
        addi tos, tos, -0x37
3:      bge tos, x15, 1b
        push_tos
        li tos, true_value
4:      lcsp ra, 0(sp)
        addi sp, sp, 2*cell
        ret
	end_inlined
	
	## Start a colon definition
	define_word ":", visible_flag
_colon: push ra
        call _token
        beq tos, zero, 1f
        li x15, state
        li x14, true_value
        sc x14, 0(x15)
        call _asm_start
        li x15, current_flags
        li x14, visible_flag
        sc x14, 0(x15)
        pop ra
        ret
1:      push_tos
        li tos, _token_expected
        call _raise
        ret # Dummy instruction
        end_inlined

	## Start an anonymous colon definition
	define_word ":noname", visible_flag
_colon_noname:
        push ra
        addi dp, dp, -2*cell
        sc tos, cell(dp)
        li tos, 0
        sc tos, 0(dp)
        li x15, state
        li x14, true_value
        sc x14, 0(x15)
        call _asm_start
        li x15, current_flags
        li x14, 0
        sc x14, 0(x15)
        pop ra
        ret
1:      push_tos
        li tos, _token_expected
        call _raise
        ret # Dummy instruction
        end_inlined

	## End a colon definition
	define_word ";", visible_flag | immediate_flag
_semi:  push ra
        li x15, =state
        lc x14, 0(x15)
        beq x14, zero, 1f
        li x14, 0
        sc x14, 0(x15)
        call _asm_end
        pop ra
        ret
1:      push_tos
        li tos, _not_compiling
        call _raise
        ret # Dummy instruction
	end_inlined

	## Create a constant
	define_word "constant", visible_flag
_constant_cell:
        push ra
        call _token
        beq tos, zero, 1f
        call _asm_start
        li x15, current_flags
        li x14, visible_flag | inlined_flag
        sc x14, 0(x15)
        push_tos
        li tos, 8 # TOS
        call _asm_push
        push_tos
        li tos, 8 @ TOS
        call _asm_literal
        call _asm_end
        pop ra
        ret
1:      push_tos
        li tos, _token_expected
        call _raise
        ret # Dummy instruction
        end_inlined

	## Create a constant with a specified name as a string
	define_internal_word "constant-with-name", visible_flag
_constant_with_name_cell:
        push ra
        call _asm_start
        li x15, current_flags
        li x14, visible_flag | inlined_flag
        sc x14, 0(x15)
        push_tos
        li tos, 8 # TOS
        call _asm_push
        push_tos
        li tos, 8 @ TOS
        call _asm_literal
        call _asm_end
        pop ra
        ret
	end_inlined

	## Create a 2-cell constant
	define_word "2constant", visible_flag
_constant_double:
        push ra
        call _token
        beq tos, zero, 1f
        call _asm_start
        li x15, current_flags
        li x14, visible_flag | inlined_flag
        sc x14, 0(x15)
        push_tos
        li tos, 8 # TOS
        call _asm_push
        push tos # We are pushing TOS onto the return stack here
        li tos, 8 # TOS
        call _asm_literal
        push_tos
        li tos, 8 # TOS
        call _asm_push
        push_tos
        pop tos
        push_tos
        li tos, 8 # TOS
        call _asm_literal
        call _asm_end
        pop ra
        ret
1:      push_tos
        li tos, _token_expected
        call _raise
        ret # Dummy instruction
        end_inlined

	## Create a 2-cell constant with a name specified as a string
	define_internal_word "2constant-with-name", visible_flag
_constant_with_name_double:
        push ra
        call _asm_start
        li x15, current_flags
        li x14, visible_flag | inlined_flag
        sc x14, 0(x15)
        push_tos
        li tos, 8 # TOS
        call _asm_push
        push tos # We are pushing TOS onto the return stack here
        li tos, 8 # TOS
        call _asm_literal
        push_tos
        li tos, 8 # TOS
        call _asm_push
        push_tos
        pop tos
        push_tos
        li tos, 8 # TOS
        call _asm_literal
        call _asm_end
        pop ra
        ret
	end_inlined

	## Token expected exception handler
	define_word "x-token-expected", visible_flag
_token_expected:
	push ra
	string_ln "token expected"
	call _type
	pop ra
        ret
	end_inlined

	## We are not currently compiling
	define_word "x-not-compiling", visible_flag
_not_compiling:
	push ra
	string_ln "not compiling"
	call _type
	pop ra
        ret
	end_inlined

	## We are currently compiling to flash
	define_word "x-compile-to-ram-only", visible_flag
_compile_to_ram_only:
	push ra
	string_ln "compile to ram only"
	call _type
	pop ra
        ret
	end_inlined
