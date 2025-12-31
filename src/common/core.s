# Copyright (c) 2019-2025 Travis Bemann
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

	# Include the kernel info, needed for welcome
	.include "../common/kernel_info.s"

	## Drop the top of the data stack
	define_word "drop", visible_flag | inlined_flag
_drop:	pull_tos
        ret
	end_inlined

	## Duplicate the top of the data stack
	define_word "dup", visible_flag | inlined_flag
_dup:	push_tos
	ret
	end_inlined

	## Swap the top two places on the data stack
	define_word "swap", visible_flag | inlined_flag
_swap:	mv x15, tos
        lc tos, 0(dp)
        sc x15, 0(dp)
        ret
	end_inlined

	## Copy the second place on the data stack onto the top of the stack,
	## pushing the top of the data stack to the second place
	define_word "over", visible_flag | inlined_flag
_over:	push_tos
        lc tos, cell(dp)
        ret
	end_inlined

	## Rotate the top three places on the data stack, so the third place
	## moves to the first place
	define_word "rot", visible_flag | inlined_flag
_rot:   lc x15, cell(dp)
        lc x14, 0(dp)
        sc tos, 0(dp)
        sc x14, cell(dp)
        mv tos, x15
        ret
	end_inlined

	## Pick a value at a specified depth on the stack
	define_word "pick", visible_flag | inlined_flag
_pick:  slli tos, tos, cell_bytes_power
        add tos, tos, dp
        lc tos, 0(tos)
        ret
	end_inlined

	## Rotate a value at a given deph to the top of the stackk
	define_word "roll", visible_flag | inlined_flag
_roll:  mv x15, tos
        slli x15, x15, cell_bytes_power
        add x15, x15, dp
        lc tos, 0(x15)
1:      beq x15, dp, 2f
        lc x14, -cell(x15)
        sc x14, 0(x15)
        addi x15, x15, -cell
        j 1b
2:      addi dp, dp, cell
        ret
	end_inlined

	## Remove the cell under that on the top of the stack
	define_word "nip", visible_flag | inlined_flag
_nip:	addi dp, dp, cell
        ret
	end_inlined

	## Push the cell on top of the stack under the item beneath it
	define_word "tuck", visible_flag | inlined_flag
_tuck:	lc x15, 0(dp)
        sc tos, 0(dp)
        addi dp, dp, -cell
        sc x15, 0(dp)
        ret
	end_inlined

	## Logical shift left
	define_word "lshift", visible_flag | inlined_flag
_lshift:
        mv x15, tos
        pull_tos
        sll tos, tos, x15
        ret
	end_inlined

	## Logical shift right
	define_word "rshift", visible_flag | inlined_flag
_rshift:
        mv x15, tos
        pull_tos
        srl tos, tos, x15
        ret
	end_inlined

	## Arithmetic shift right
	define_word "arshift", visible_flag | inlined_flag
_arshift:
        mv x15, tos
        pull_tos
        sra tos, tos, x15
        ret
	end_inlined

	## Binary and
	define_word "and", visible_flag | inlined_flag
_and:	mv x15, tos
        pull_tos
        and tos, tos, x15
        ret
	end_inlined

	## Binary or
	define_word "or", visible_flag | inlined_flag
_or:	mv x15, tos
        pull_tos
        or tos, tos, x15
        ret
	end_inlined

	## Binary xor
	define_word "xor", visible_flag | inlined_flag
_xor:	mv x15, tos
        pull_tos
        xor tos, tos, x15
        ret
	end_inlined

	## Bit clear
	define_word "bic", visible_flag | inlined_flag
_bic:	mv x15, tos
	pull_tos
        andn tos, tos, x15
        ret
	end_inlined

	## Binary not
	define_word "not", visible_flag | inlined_flag
_not:	not tos, tos
        ret
	end_inlined

	## Negation
	define_word "negate", visible_flag | inlined_flag
_negate:
        not tos, tos
        addi tos, tos, 1
        ret
	end_inlined
	
	## Addition of two two's complement integers
	define_word "+", visible_flag | inlined_flag
_add:	mv x15, tos
	pull_tos
	add tos, tos, x15
	ret
	end_inlined

	## Substraction of two two's complement integers
	define_word "-", visible_flag | inlined_flag
_sub:	mv x15, tos
	pull_tos
        sub tos, tos, x15
        ret
	end_inlined

	## Multiplication of two two's complement integers
	define_word "*", visible_flag | inlined_flag
_mul:	mv x15, tos
	pull_tos
	mul tos, tos, x15
	ret
	end_inlined

	## Get the minimum of two values
	define_word "min", visible_flag | inlined_flag
_min:	mv x15, tos
        pull_tos
        min tos, tos, x15
        ret
	end_inlined

	## Get the maximum of two values
	define_word "max", visible_flag | inlined_flag
_max:	mv x15, tos
        pull_tos
        max tos, tos, x15
        jr jra
	end_inlined

	## Equals
	define_word "=", visible_flag
_eq:	mv x15, tos
        pull_tos
        sub tos, tos, x15
        seqz tos, tos
        sub tos, zero, tos
        ret
	end_inlined

	## Not equal
	define_word "<>", visible_flag
_ne:	mv x15, tos
        pull_tos
        sub tos, tos, x15
        snez tos, tos
        sub tos, zero, tos
        ret
	end_inlined

	## Less than
	define_word "<", visible_flag
_lt:	mv x15, tos
        pull_tos
        slt tos, tos, x15
        sub tos, zero, tos
        ret
	end_inlined

	## Greater than
	define_word ">", visible_flag
_gt:	mv x15, tos
        pull_tos
        slt tos, x15, tos
        sub tos, zero, tos
        ret
	end_inlined

	## Less than or equal
	define_word "<=", visible_flag
_le:	mv x15, tos
        pull_tos
        sub x14, tos, x15
        seqz x14, x14
        slt tos, tos, x15
        or tos, tos, x14
        sub tos, zero, tos
        ret
        end_inlined

	## Greater than or equal
	define_word ">=", visible_flag
_ge:	mv x15, tos
        pull_tos
        sub x14, tos, x15
        seqz x14, x14
        slt tos, x15, tos
        or tos, tos, x14
        sub tos, zero, tos
        ret
	end_inlined

	## Equals zero
	define_word "0=", visible_flag | inlined_flag
_0eq:	seqz tos, tos
        sub tos, zero, tos
        ret
	end_inlined

	## Not equal to zero
	define_word "0<>", visible_flag | inlined_flag
_0ne:	snez tos, tos
        sub tos, zero, tos
        ret
	end_inlined

	## Less than zero
	define_word "0<", visible_flag | inlined_flag
_0lt:	srai tos, tos, sign_shift
        ret
	end_inlined

	## Greater than zero
	define_word "0>", visible_flag | inlined_flag
_0gt:	slt tos, zero, tos
        sub tos, zero, tos
        ret
	end_inlined

	## Less than or equal to zero
	define_word "0<=", visible_flag | inlined_flag
_0le:	seqz x15, tos
        srai tos, tos, sign_shift
        sub x15, zero, x15
        or tos, tos, x15
        ret
	end_inlined

	## Greater than or equal to zero
	define_word "0>=", visible_flag | inlined_flag
_0ge:	srai tos, tos, sign_shift
        not tos, tos
        ret
	end_inlined
	
	## Unsigned less than
	define_word "u<", visible_flag
_ult:	mv x15, tos
        pull_tos
        sltu tos, tos, x15
        sub tos, zero, tos
        ret
	end_inlined

	## Unsigned greater than
	define_word "u>", visible_flag
_ugt:	mv x15, tos
        pull_tos
        sltu tos, x15, tos
        sub tos, zero, tos
        ret
	end_inlined

	## Unsigned less than or equal
	define_word "u<=", visible_flag
_ule:	mv x15, tos
        pull_tos
        sub x14, tos, x15
        seqz x14, x14
        sltu tos, tos, x15
        or tos, tos, x14
        sub tos, zero, tos
        ret
	end_inlined

	## Unsigned greater than or equal
	define_word "u>=", visible_flag
_uge:	mv x15, tos
        pull_tos
        sub x14, tos, x15
        seqz x14, x14
        sltu tos, x15, tos
        or tos, tos, x14
        sub tos, zero, tos
        ret
	end_inlined
	
	## Get the RAM HERE pointer
	define_word "ram-here", visible_flag
_here:	push ra
        call _cpu_offset
        li x15, dict_base
        add tos, tos, x15
        lc tos, 0(tos)
        lc tos, ram_here_offset(tos)
        pop ra
        ret
	end_inlined

	## Get the PAD pointer
	define_word "pad", visible_flag
_pad:	push ra
        call _here
        li x15, pad_offset
        add tos, tos, x15
        pop ra
        ret
	end_inlined

	## Allot space in RAM
	define_word "ram-allot", visible_flag
_allot: push ra
        call _cpu_offset
        li x15, dict_base
        add x15, x15, tos
        lc x15, 0(x15)
        addi x15, x15, ram_here_offset
        pull_tos
        lc x14, 0(x15)
        add x14, x14, tos
        sc x14, 0(x15)
        pull_tos
        pop ra
        ret
        end_inlined

	## Set the RAM flash pointer
	define_word "ram-here!", visible_flag
_store_here:
        push ra
        call _cpu_offset
        li x15, dict_base
        add x15, x15, tos
        lc x15, 0(x15)
        addi x15, x15, ram_here_offset
        pull_tos
        sc tos, 0(x15)
        pull_tos
        pop ra
        ret
	end_inlined

	## Get the flash HERE pointer
	define_word "flash-here", visible_flag
_flash_here:
        li x15, flash_here
        push_tos
        lc tos, 0(x15)
        ret
	end_inlined

	## Allot space in flash
	define_word "flash-allot", visible_flag
_flash_allot:
        li x15, flash_here
        lc x14, 0(x15)
        add x14, x14, tos
        sc x14, 0(x15)
        pull_tos
        ret
	end_inlined

	## Set the flash HERE pointer
	define_word "flash-here!", visible_flag
_store_flash_here:
        li x15, flash_here
        sc tos, 0(x15)
        pull_tos
        ret
	end_inlined

	## Get the base address of the latest word
	define_word "latest", visible_flag
_latest:
        push_tos
        li x15, latest
        lc tos, 0(x15)
        ret
	end_inlined

	## Get the base address of the latest RAM word
	define_word "ram-latest", visible_flag
_ram_latest:
        push_tos
        li x15, ram_latest
        lc tos, 0(x15)
        ret
	end_inlined

	## Get the base address of the latest flash word
	define_word "flash-latest", visible_flag
_flash_latest:
        push_tos
        li x15, flash_latest
        lc tos, 0(x15)
        ret
	end_inlined

	## Set the base address of the latest word
	define_word "latest!", visible_flag
_store_latest:
        li x15, latest
        sc tos, 0(x15)
        pull_tos
        ret
	end_inlined

	## Set the base address of the latest RAM word
	define_word "ram-latest!", visible_flag
_store_ram_latest:
        li x15, ram_latest
        sc tos, 0(x15)
        pull_tos
        ret
	end_inlined

	## Set the base address of the latest flash word
	define_word "flash-latest!", visible_flag
_store_flash_latest:
        li x15, flash_latest
        sc tos, 0(x15)
        pull_tos
        ret
	end_inlined

	## Get either the HERE pointer or the flash HERE pointer, depending on
	## compilation mode
	define_word "here", visible_flag
_current_here:
        push ra
        li x15, compiling_to_flash
        lc x15, 0(x15)
        bnez x15, 1f
        call _here
        pop ra
        ret
1:      call _flash_here
        pop ra
        ret
	end_inlined

	## Allot space in RAM or in flash, depending on the compilation mode
	define_word "allot", visible_flag
_current_allot:
        push ra
        li x15, compiling_to_flash
        lc x15, 0(x15)
        bnez x15, 1f
        call _allot
        pop ra
        ret
1:      call _flash_allot
        pop ra
        ret
	end_inlined

	## Emit a character
	define_word "emit", visible_flag
_emit:	push ra
        call _emit_hook
        lc x15, 0(tos)
        pull_tos
        beqz x15, 1f
        jr x15
1:      pop ra
        ret
	end_inlined

	## Test for whether the system is ready to receive a character
	define_word "emit?", visible_flag
_emit_q:
	push ra
        call _emit_q_hook
        lc x15, 0(tos)
        pull_tos
        beqz x15, 1f
        jr x15
        pop ra
        ret
1:      push_tos
        li tos, 0
        pop ra
        ret
	end_inlined

	## Emit a space
	define_word "space", visible_flag
_space:	push ra
        push_tos
        li tos, 0x20
        call _emit
        pop ra
        ret
	end_inlined

	## Emit a newline
	define_word "cr", visible_flag
_cr:	push ra
        push_tos
        li tos, 0x0D
        call _emit
        push_tos
        li tos, 0x0A
        call _emit
        pop ra
        ret
	end_inlined

	## Type a string
	define_word "type", visible_flag
_type:  addi sp, sp, -3*cell
        scsp ra, 0(sp)
        mv x15, tos
        lc x14, 0(dp)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
1:      beqz x15, 2f
        push_tos
        lb tos, 0(x14)
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        call _emit
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
        addi x15, x15, -1
        addi x14, x14, 1
        j 1b
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
	end_inlined

	## Type a string using the native serial driver
	define_word "serial-type", visible_flag
_serial_type:
	addi sp, sp, -3*cell
        scsp ra, 0(sp)
        mv x15, tos
        lc x14, 0(dp)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
1:      beqz x15, 2f
        push_tos
        lb tos, 0(x14)
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        call _serial_emit
        lcsp x14, 2*cell(sp)
        lcsp x15, 1*cell(sp)
        addi x15, x15, -1
        addi x14, x14, 1
        j 1b
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
	end_inlined

	# Convert a cstring to a string
	define_word "count", visible_flag
_count:	lb x15, 0(tos)
        addi tos, tos, 1
        push_tos
        mv tos, x15
        ret
	end_inlined
	
	## Receive a character
	define_word "key", visible_flag
_key:   push ra
        call _key_hook
        lc x15, 0(tos)
        pull_tos
        beqz x15, 1f
        jr x15
        pop ra
        ret
1:      push_tos
        li tos, 0x0D
        pop ra
        ret
	end_inlined

	## Test for whether the system is ready to receive a character
	define_word "key?", visible_flag
_key_q:	push ra
        call _key_q_hook
        lc x15, 0(tos)
        pull_tos
        beqz x15, 1f
        jr x15
        pop ra
        ret
1:      push_tos
        li tos, 0
        pop ra
        ret
	end_inlined

	## Enable interrupts
	define_word "enable-int", visible_flag
_enable_int:
        csrrsi zero, mstatus, mie_bit
        ret
	end_inlined

	## Disable interrupts
	define_word "disable-int", visible_flag
_disable_int:
        csrrci zero, mstatus, mie_bit
        ret
	end_inlined

	## Enter sleep mode
	define_word "sleep", visible_flag
_sleep:
        # Implement later
        ret
	end_inlined
	
	## Execute an xt
	define_word "execute", visible_flag
_execute:
        mv x15, tos
        pull_tos
        jr x15
        ret # This is a dummy instruction
	end_inlined

	## Inline-execute an xt
	define_word "inline-execute", visible_flag | inlined_flag
_inline_execute:
        mv x15, tos
        pull_tos
        jal ra,r x15
        ret # This is a dummy instruction
	end_inlined

	## Execute an xt if it is non-zero
	define_word "?execute", visible_flag
_execute_nz:
        mv x15, tos
        pull_tos
        beqz x15, 1f
        jr x15
1:      ret
	end_inlined

	## Do nothing
	define_internal_word "do-nothing", visible_flag
_do_nothing:
        ret
	end_inlined

	## Exit a word
	define_word "exit", visible_flag | immediate_flag | compiled_flag
_exit:  push ra
        call _asm_undefer_lit
        li x15, word_exit_hook
        lc x15, 0(x15)
        beqz x15, 1f
        jal ra,r x15
1:      call _asm_exit
        pop ra
        ret
	end_inlined

	## Initialize the flash dictionary
	define_internal_word "init-flash-dict", visible_flag
_init_flash_dict:
        push ra
        call _find_flash_end
        call _next_flash_block
        li x14, flash_dict_start
        li x15, flash_here
        blt tos, x14, 1f
        sc tos, 0(x15)
        j 2f
1:      sc x14, 0(x15)
2:      call _find_last_flash_word
        call _find_last_visible_word
        li x15, latest
        sc tos, 0(x15)
        li x15, flash_latest
        sc tos, 0(x15)
        pop ra
        ret
        end_inlined
	
	## Initiatlize the dictionary
	define_internal_word "init-dict", visible_flag
_init_dict:
        push ra
        call _init_flash_dict
        pull_tos
        li x14, 0
        li x15, ram_latest
        sc x14, 0(x15)
        pop ra
        ret
	end_inlined

	## Find the last visible word
	define_internal_word "find-last-visible-word", visible_flag
_find_last_visible_word:
1:      beqz tos, 2f
        lc x15, 0(tos)
        li x14, visible_flag
        and x14, x14, x15
        bnez x14, 2f
        lc tos, cell(tos)
        j 1b
2:      ret
        end_inlined

	.ltorg
	
	## An empty init routine, to call if no other init routines are
	## available, so as to enable any source file to call a preceding init
	## routine without having to check if one exists
	define_word "init", visible_flag
_init:	ret
	end_inlined

        ## Execute a word in the dictionary if it exists
        define_internal_word "find-execute", visible_flag
_find_execute:
        push ra
        call _find_all
        beqz tos, 1f
        call _to_xt
        call _execute
        pop ra
        ret
1:      pull_tos
        pop ra
        ret
	end_inlined

 	## Run the initialization and turnkeys routines, if they exist
	define_internal_word "do-init", visible_flag
_do_init:
        push ra
        string "init"
        call _find_execute
        string "turnkey"
        call _find_execute
        pop ra
        ret
	end_inlined

        ## Run the welcome routine
        define_internal_word "do-welcome", visible_flag
_do_welcome:
        push ra
        string "welcome"
        call _find_execute
        string_ln " ok"
        call _type
        pop ra
        ret
        end_inlined
	
	## Set the currently-defined word to be immediate
	define_word "[immediate]", visible_flag | immediate_flag | compiled_flag
_bracket_immediate:
        li x15, current_flags
        lc x14, 0(x15)
        ori x14, x14, immediate_flag
        sc x14, 0(x15)
        ret
	end_inlined

	## Set the currently-defined word to be compile-only
	define_word "[compile-only]", visible_flag | immediate_flag | compiled_flag
_bracket_compile_only:
        li x15, current_flags
        lc x14, 0(x15)
        ori x14, x14, compiled_flag
        sc x14, 0(x15)
        ret
	end_inlined

	## Set the currently-defined word to be inlined
	define_word "[inlined]", visible_flag | immediate_flag | compiled_flag
_bracket_inlined:
        li x15, current_flags
        lc x14, 0(x15)
        ori x14, x14, inlined_flag
        sc x14, 0(x15)
        ret
	end_inlined

	## Set the currently-defined word to be immediate
	define_word "immediate", visible_flag
_immediate:
        j _bracket_immediate
        ret
	end_inlined

	.ltorg
	
	## Set the currently-defined word to be compile-only
	define_word "compile-only", visible_flag
_compile_only:
        j _bracket_compile_only
        ret
	end_inlined

	## Set the currently-defined word to be inlined
	define_word "inlined", visible_flag
_inlined:
        j _bracket_inlined
        ret
	end_inlined

	## Set the currently-defined word to be visible
	define_word "visible", visible_flag
_visible:
        li x15, current_flags
        lc x14, 0(x15)
        ori x14, x14, visible_flag
        sc x14, 0(x15)
        ret
	end_inlined

        ## Set the currently-define word to be an initialized value
        define_word "init-value", visible_flag
_init_value:
        li x15, current_flags
        lc x14, 0(x15)
        ori x14, x14, init_value_flag
        sc x14, 0(x15)
        ret
        end_inlined
        
	## Switch to interpretation mode
	define_word "[", visible_flag | immediate_flag
_to_interpret:
        li x15, state
        li x14, false_value
        sc x14, 0(x15)
        ret
	end_inlined

	## Switch to compilation state
	define_word "]", visible_flag
_to_compile:
        li x15, state
        li x14, true_value
        sc x14, 0(x15)
        ret
	end_inlined

	## Set compilation to RAM
	define_word "compile-to-ram", visible_flag
_compile_to_ram:
        push ra
        call _asm_undefer_lit
        li x15, compiling_to_flash
        li x14, false_value
        sc x14, 0(x15)
        pop ra
        ret
	end_inlined

	## Set compilation to flash
	define_word "compile-to-flash", visible_flag
_compile_to_flash:
        push ra
        call _asm_undefer_lit
        li x15, compiling_to_flash
        li x14, true_value
        sc x14, 0(x15)
        pop ra
        ret
	end_inlined

	## Get whether compilation is to flash
	define_word "compiling-to-flash?", visible_flag
_compiling_to_flash:
        push_tos
        li tos, compiling_to_flash
        lc tos, 0(tos)
        ret
	end_inlined

	## Get whether to compress code compiled to flash
	define_word "compress-flash", visible_flag
_compress_flash:
        li x15, compress_flash_enabled
        li x14, true_value
        sc x14, 0(x15)
        ret
	end_inlined

	## Get whether flash is being compressed
	define_word "compressing-flash", visible_flag
_compressing_flash:
        push_tos
        li tos, compress_flash_enabled
        lc tos, 0(tos)
        ret
	end_inlined

	## Compile an xt
	define_word "compile,", visible_flag
_compile:
        push ra
        call _asm_call
        pop ra
        ret
	end_inlined

	## Get the word corresponding to a token
	define_word "token-word", visible_flag
_token_word:
        push ra
        call _token
        beqz tos, 1f
        call _find
        beqz tos, 2f
        pop ra
        ret
1:      li tos, _token_expected
        call _raise
        pop ra
        ret
2:      li tos, _unknown_word
        call _raise
        pop ra
        ret
	end_inlined

	## Tick
	define_word "'", visible_flag
_tick:	push ra
        call _token_word
        call _to_xt
        pop ra
        ret
	end_inlined

	## Compiled tick
	define_word "[']", visible_flag | immediate_flag | compiled_flag
_compiled_tick:
        push ra
        call _tick
        call _comma_lit
        pop ra
        ret
	end_inlined
	
	## Postpone a word
	define_word "postpone", visible_flag | immediate_flag | compiled_flag
_postpone:
        addi sp, sp, -3*cell
        scsp ra, 0(sp)
        call _token
        bnez tos, 1f
        li tos, _token_expected
        call _raise
1:      mv x14, tos
        lc x15, 0(dp)
        scsp x15, 1*cell(sp)
        scsp x14, 2*cell(sp)
        call _find
        bnez tos, 1f
        lcsp tos, 1*cell(sp)
        push_tos
        lcsp tos, 2*cell(sp)
        li x14, true_value
        li x15, postpone_literal_q
        sc x14, 0(x15)
        call _parse_literal
        li x14, false_value
        li x15, postpone_literal_q
        sc x14, 0(x15)
        j 2f
1:      lc x15, 0(tos)
        andi x14, x15, immediate_flag
        beqz x14, 1f
        andi x14, x15, inlined_flag
        bnez x14, 3f
        call _to_xt
        call _compile
        j 2f
3:      call _to_xt
        call _asm_inline
        j 2f
1:      scsp x15, cell(sp)
        call _to_xt
        push_tos
        li tos, 8 # DP
        call _asm_push
        push_tos
        li tos, 8 # DP
        call _asm_literal
        push_tos
        lcsp x15, cell(sp)
        andi x15, x15, inlined_flag
        bnez x15, 2f
        li tos, _compile
        call _compile
        j 2f
1:      li tos, _asm_inline
        call _compile
2:      lcsp ra, 0(sp)
        addi sp, sp, 3*cell
        ret
        end_inlined

	## Compile a literal
	define_word "lit,", visible_flag
_comma_lit:
        push ra
        li x14, literal_deferred_q
        li x15, 0(x14)
        beqz x15, 1f
        call _asm_undefer_lit
1:      li x13, deferred_literal
        sc tos, 0(x13)
        li x14, literal_deferred_q
        li x15, true_value
        sc x15, 0(x14)
        pull_tos
        li x15, postpone_literal_q
        lc x15, 0(x15)
        beqz x15, 1f
        push_tos
        li tos, _comma_lit
        call _compile
1:      pop ra
        ret
        end_inlined

	## Compile a literal
	define_word "literal", visible_flag | immediate_flag | compiled_flag
_literal:
        push ra
        call _comma_lit
        pop ra
        ret
	end_inlined

	## Recursively call a word
	define_word "recurse", visible_flag | immediate_flag | compiled_flag
_recurse:
        push ra
        push_tos
        li tos, current_unit_start
        lc tos, 0(tos)
        call _asm_call
        pop ra
        ret
	end_inlined
	
	## Unknown word exception
	define_word "x-unknown-word", visible_flag
_unknown_word:
        push ra
        string_ln "unknown word"
        call _type
        pop ra
        ret
	end_inlined
	
	## Store a byte
	define_word "c!", visible_flag | fold_flag
_store_1:
        lc x15, 0(dp)
        sb x15, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Store a halfword
	define_word "h!", visible_flag | fold_flag
_store_2:
        lc x15, 0(dp)
        sh x15, 0(tos)
        lc tos, cell(dp)
        addi dp, dp 2*cell
        ret
	end_inlined

	## Store a word
	define_word "!", visible_flag | fold_flag
_store_4:
        lc x15, 0(dp)
        sc x15, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Store a doubleword
	define_word "2!", visible_flag
_store_8:
        lc x15, 0(dp)
        lc x14, cell(dp)
        sc x15, 0(tos)
        sc x14, cell(tos)
        lc tos, 2*cell(dp)
        addi dp, dp, 3*cell
        ret
	end_inlined

	## Read a byte from an address, add a value, and write it back
	define_word "c+!", visible_flag
_add_store_1:
        lc x15, 0(dp)
        lb x14, 0(tos)
        add x14, x14, x15
        sb x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Read a halfword from an address, add a value, and write it back
	define_word "h+!", visible_flag
_add_store_2:	
        lc x15, 0(dp)
        lh x14, 0(tos)
        add x14, x14, x15
        sh x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Read a word from an address, add a value, and write it back
	define_word "+!", visible_flag
_add_store_4:	
        lc x15, 0(dp)
        lc x14, 0(tos)
        add x14, x14, x15
        sc x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

        ## Read a double word from an address, add a value, and write it back
        define_word "2+!", visible_flag
_add_store_8:
        lc x13, 0(dp)
        lc x12, cell(dp)
        lc x14, cell(tos)
        lc x15, 0(tos)
        add x14, x14, x12
        sltu x11, x14, x12
        add x15, x15, x13
        add x15, x15, x11
        sc x14, cell(tos)
        sc x15, 0(tos)
        lc tos, 2*cell(dp)
        addi dp, dp, 3*cell
        ret
        end_inlined
        
	## Specify a bit
	define_word "bit", visible_flag | inlined_flag
_bit:	mv x15, tos
        li tos, 1
        sll tos, tos, x15
        ret
	end_inlined

	## Bit set a byte
	define_word "cbis!", visible_flag | inlined_flag
_bit_set_1:
        lc x15, 0(dp)
        lb x14, 0(tos)
        or x14, x14, x15
        sb x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Bit set a halfword
	define_word "hbis!", visible_flag | inlined_flag
_bit_set_2:
        lc x15, 0(dp)
        lh x14, 0(tos)
        or x14, x14, x15
        sh x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Bit set a word
	define_word "bis!", visible_flag | inlined_flag
_bit_set_4:
        lc x15, 0(dp)
        lc x14, 0(tos)
        or x14, x14, x15
        sc x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Bit clear a byte
	define_word "cbic!", visible_flag | inlined_flag
_bit_clear_1:
        lc x15, 0(dp)
        lb x14, 0(tos)
        andn x14, x14, x15
        sb x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	## Bit clear a halfword
	define_word "hbic!", visible_flag | inlined_flag
_bit_clear_2:
        lc x15, 0(dp)
        lh x14, 0(tos)
        andn x14, x14, x15
        sh x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

	.ltorg
	
	## Bit clear a word
	define_word "bic!", visible_flag | inlined_flag
_bit_clear_4:
        lc x15, 0(dp)
        lc x14, 0(tos)
        andn x14, x14, x15
        sc x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
	end_inlined

        # Load, exclusive-or, and store a byte
        define_word "cxor!", visible_flag | inlined_flag
_xor_set_1:
        lc x15, 0(dp)
        lb x14, 0(tos)
        xor x14, x14, x15
        sb x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
        end_inlined

        # Load, exclusive-or, and store a halfword
        define_word "hxor!", visible_flag | inlined_flag
_xor_set_2:
        lc x15, 0(dp)
        lh x14, 0(tos)
        xor x14, x14, x15
        sh x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
        end_inlined
        
        # Load, exclusive-or, and store a word
        define_word "xor!", visible_flag | inlined_flag
_xor_set_4:
        lc x15, 0(dp)
        lc x14, 0(tos)
        xor x14, x14, x15
        sc x14, 0(tos)
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        ret
        end_inlined

	# Test for bits in a byte
	define_word "cbit@", visible_flag | inlined_flag
_bit_test_1:
	movs r0, tos
	pull_tos
	ldrb r0, [r0]
	ands tos, r0
	subs tos, #1
	sbcs tos, tos
	mvns tos, tos
	bx lr
	end_inlined

	# Test for bits in a halfword
	define_word "hbit@", visible_flag | inlined_flag
_bit_test_2:
	movs r0, tos
	pull_tos
	ldrh r0, [r0]
	ands tos, r0
	subs tos, #1
	sbcs tos, tos
	mvns tos, tos
	bx lr
	end_inlined

	# Test for bits in a word
	define_word "bit@", visible_flag | inlined_flag
_bit_test_4:
	movs r0, tos
	pull_tos
	ldr r0, [r0]
	ands tos, r0
	subs tos, #1
	sbcs tos, tos
	mvns tos, tos
	bx lr
	end_inlined

	## Get a byte
	define_word "c@", visible_flag | inlined_flag
_get_1: ldrb tos, [tos]
	bx lr
	end_inlined

	## Get a halfword
	define_word "h@", visible_flag | inlined_flag
_get_2: ldrh tos, [tos]
	bx lr
	end_inlined

	## Get a word
	define_word "@", visible_flag | inlined_flag
_get_4: ldr tos, [tos]
	bx lr
	end_inlined

	## Get a doubleword
	define_word "2@", visible_flag
_get_8:	ldr r0, [tos]
	ldr tos, [tos, #4]
	push_tos
	movs tos, r0
	bx lr
	end_inlined

.ltorg
        
	## Store a byte at the RAM HERE location
	define_word "cram,", visible_flag
_comma_1:
	push {lr}
	bl _cpu_offset
	ldr r0, =dict_base
	adds r0, tos
	ldr r0, [r0]
	adds r0, #ram_here_offset
	pull_tos
	ldr r1, [r0]
	strb tos, [r1], #1
	str r1, [r0]
	pull_tos
	pop {pc}
	end_inlined

	## Store a halfword at the RAM HERE location
	define_word "hram,", visible_flag
_comma_2:
	push {lr}
	bl _cpu_offset
	ldr r0, =dict_base
	adds r0, tos
	ldr r0, [r0]
	adds r0, #ram_here_offset
	pull_tos
	ldr r1, [r0]
	strh tos, [r1], #2
	str r1, [r0]
	pull_tos
	pop {pc}
	end_inlined

	## Store a word at the RAM HERE location
	define_word "ram,", visible_flag
_comma_4:
	push {lr}
	bl _cpu_offset
	ldr r0, =dict_base
	adds r0, tos
	ldr r0, [r0]
	adds r0, #ram_here_offset
	pull_tos
	ldr r1, [r0]
	str tos, [r1], #4
	str r1, [r0]
	pull_tos
	pop {pc}
	end_inlined
	
	## Store a doubleword at the RAM HERE location
	define_word "2ram,", visible_flag
_comma_8:
	push {lr}
	bl _cpu_offset
	ldr r0, =dict_base
	adds r0, tos
	ldr r0, [r0]
	adds r0, #ram_here_offset
	pull_tos
	ldr r1, [r0]
	str tos, [r1], #4
	pull_tos
	str tos, [r1], #4
	str r1, [r0]
	pull_tos
	pop {pc}
	end_inlined

	## Store a byte at the flash HERE location
	define_word "cflash,", visible_flag
_flash_comma_1:
	push {lr}
	ldr r0, =flash_here
	push_tos
	ldr tos, [r0]
	push {r0, tos}
	bl _store_flash_1
	pop {r0, r1}
	adds r1, #1
	str r1, [r0]
	pop {pc}
	end_inlined

	## Store a halfword at the flash HERE location
	define_word "hflash,", visible_flag
_flash_comma_2:
	push {lr}
	ldr r0, =flash_here
	push_tos
	ldr tos, [r0]
	push {r0, tos}
	bl _store_flash_2
	pop {r0, r1}
	adds r1, #2
	str r1, [r0]
	pop {pc}
	end_inlined

	## Store a word at the flash HERE location
	define_word "flash,", visible_flag
_flash_comma_4:
	push {lr}
	ldr r0, =flash_here
	push_tos
	ldr tos, [r0]
	push {r0, tos}
	bl _store_flash_4
	pop {r0, r1}
	adds r1, #4
	str r1, [r0]
	pop {pc}
	end_inlined

	## Store a doubleword at the flash HERE location
	define_word "2flash,", visible_flag
_flash_comma_8:
	push {lr}
	ldr r0, =flash_here
	push_tos
	ldr tos, [r0]
	push {r0, tos}
	bl _store_flash_8
	pop {r0, r1}
	adds r1, #8
	str r1, [r0]
	pop {pc}
	end_inlined

	## Store a byte to RAM or to flash
	define_word "ccurrent!", visible_flag
_store_current_1:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _store_1
	pop {pc}
1:	bl _store_flash_1
	pop {pc}
	end_inlined

	## Store a halfword to RAM or to flash
	define_word "hcurrent!", visible_flag
_store_current_2:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _store_2
	pop {pc}
1:	bl _store_flash_2
	pop {pc}
	end_inlined

	## Store a word to RAM or to flash
	define_word "current!", visible_flag
_store_current_4:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _store_4
	pop {pc}
1:	bl _store_flash_4
	pop {pc}
	end_inlined

	## Store a doubleword to RAM or to flash
	define_word "2current!", visible_flag
_store_current_8:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _store_8
	pop {pc}
1:	bl _store_flash_8
	pop {pc}
	end_inlined

	## Store a byte to the RAM or flash HERE location
	define_word "c,", visible_flag
_current_comma_1:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _comma_1
	pop {pc}
1:	bl _flash_comma_1
	pop {pc}
	end_inlined

	## Store a halfword to the RAM or flash HERE location
	define_word "h,", visible_flag
_current_comma_2:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _comma_2
	pop {pc}
1:	bl _flash_comma_2
	pop {pc}
	end_inlined

	## Store a word to the RAM or flash HERE location
	define_word ",", visible_flag
_current_comma_4:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _comma_4
	pop {pc}
1:	bl _flash_comma_4
	pop {pc}
	end_inlined

	## Store a doubleword to the RAM or flash HERE location
	define_word "2,", visible_flag
_current_comma_8:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _comma_8
	pop {pc}
1:	bl _flash_comma_8
	pop {pc}
	end_inlined

	## Reserve a byte at the RAM HERE location
	define_word "cram-reserve", visible_flag
_reserve_1:
	push {lr}
	bl _cpu_offset
	ldr r0, =dict_base
	adds r0, tos
	ldr r0, [r0]
	adds r0, #ram_here_offset
	pull_tos
	ldr r1, [r0]
	push_tos
	movs tos, r1
	adds r1, #1
	str r1, [r0]
	pop {pc}
	end_inlined

	## Reserve a halfword at the RAM HERE location
	define_word "hram-reserve", visible_flag
_reserve_2:
	push {lr}
	bl _cpu_offset
	ldr r0, =dict_base
	adds r0, tos
	ldr r0, [r0]
	adds r0, #ram_here_offset
	pull_tos
	ldr r1, [r0]
	push_tos
	movs tos, r1
	adds r1, #2
	str r1, [r0]
	pop {pc}
	end_inlined

	## Reserve a word at the RAM HERE location
	define_word "ram-reserve", visible_flag
_reserve_4:
	push {lr}
	bl _cpu_offset
	ldr r0, =dict_base
	adds r0, tos
	ldr r0, [r0]
	adds r0, #ram_here_offset
	pull_tos
	ldr r1, [r0]
	push_tos
	movs tos, r1
	adds r1, #4
	str r1, [r0]
	pop {pc}
	end_inlined

	## Reserve a doubleword at the RAM HERE location
	define_word "2ram-reserve", visible_flag
_reserve_8:
	push {lr}
	bl _cpu_offset
	ldr r0, =dict_base
	adds r0, tos
	ldr r0, [r0]
	adds r0, #ram_here_offset
	pull_tos
	ldr r1, [r0]
	push_tos
	movs tos, r1
	adds r1, #8
	str r1, [r0]
	pop {pc}
	end_inlined

	## Reserve a byte at the flash HERE location
	define_word "cflash-reserve", visible_flag
_flash_reserve_1:
	ldr r0, =flash_here
	ldr r1, [r0]
	push_tos
	movs tos, r1
	adds r1, #1
	str r1, [r0]
	bx lr
	end_inlined

	## Reserve a halfword at the flash HERE location
	define_word "hflash-reserve", visible_flag
_flash_reserve_2:
	ldr r0, =flash_here
	ldr r1, [r0]
	push_tos
	movs tos, r1
	adds r1, #2
	str r1, [r0]
	bx lr
	end_inlined

	## Reserve a word at the flash HERE location
	define_word "flash-reserve", visible_flag
_flash_reserve_4:
	ldr r0, =flash_here
	ldr r1, [r0]
	push_tos
	movs tos, r1
	adds r1, #4
	str r1, [r0]
	bx lr
	end_inlined

	## Reserve a doubleword at the flash HERE location
	define_word "2flash-reserve", visible_flag
_flash_reserve_8:
	ldr r0, =flash_here
	ldr r1, [r0]
	push_tos
	movs tos, r1
	adds r1, #8
	str r1, [r0]
	bx lr
	end_inlined

	## Reserve a byte at the RAM or flash HERE location
	define_word "creserve", visible_flag
_current_reserve_1:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _reserve_1
	pop {pc}
1:	bl _flash_reserve_1
	pop {pc}
	end_inlined

	## Reserve a halfword at the RAM or flash HERE location
	define_word "hreserve", visible_flag
_current_reserve_2:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _reserve_2
	pop {pc}
1:	bl _flash_reserve_2
	pop {pc}
	end_inlined

	## Reserve a word at the RAM or flash HERE location
	define_word "reserve", visible_flag
_current_reserve_4:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _reserve_4
	pop {pc}
1:	bl _flash_reserve_4
	pop {pc}
	end_inlined

	## Reserve a doubleword at the RAM or flash HERE location
	define_word "2reserve", visible_flag
_current_reserve_8:
	push {lr}
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	bne 1f
	bl _reserve_8
	pop {pc}
1:	bl _flash_reserve_8
	pop {pc}
	end_inlined

	## Align to a power of two
	define_word "align,", visible_flag
_current_comma_align:
	push {lr}
	subs tos, #1
	movs r0, tos
	pull_tos
1:	push {r0}
	bl _current_here
	pop {r0}
	ands tos, r0
	beq 2f
	movs tos, #0
	push {r0}
	bl _current_comma_1
	pop {r0}
	b 1b
2:	pull_tos
	pop {pc}
	end_inlined

	## Align to a power of two
	define_word "flash-align,", visible_flag
_flash_comma_align:
	push {lr}
	subs tos, #1
	movs r0, tos
	pull_tos
1:	push {r0}
	bl _flash_here
	pop {r0}
	ands tos, r0
	beq 2f
	movs tos, #0
	push {r0}
	bl _flash_comma_1
	pop {r0}
	b 1b
2:	pull_tos
	pop {pc}
	end_inlined

	## Align to a power of two
	define_word "ram-align,", visible_flag
_comma_align:
	push {lr}
	subs tos, #1
	movs r0, tos
	pull_tos
1:	push {r0}
	bl _here
	pop {r0}
	ands tos, r0
	beq 2f
	movs tos, #0
	push {r0}
	bl _comma_1
	pop {r0}
	b 1b
2:	pull_tos
	pop {pc}
	end_inlined

	## Compile a c-string
	define_word "cstring,", visible_flag
_current_comma_cstring:
	push {lr}
	ldr r0, =255
	cmp tos, r0
	ble 1f
	movs tos, r0
1:	push_tos
	bl _current_comma_1
	movs r0, tos
	pull_tos
	movs r1, tos
	pull_tos
2:	cmp r0, #0
	beq 1f
	push_tos
	ldrb tos, [r1]
	push {r0, r1}
	bl _current_comma_1
	pop {r0, r1}
	subs r0, #1
	adds r1, #1
	b 2b
1:	pop {pc}
	end_inlined

	## Push a value onto the return stack
	define_word ">r", visible_flag | inlined_flag
_push_r:
	push {tos}
	pull_tos
	bx lr
	end_inlined

	## Pop a value off the return stack
	define_word "r>", visible_flag | inlined_flag
_pop_r:	push_tos
	pop {tos}
	bx lr
	end_inlined

	## Get a value off the return stack without popping it
	define_word "r@", visible_flag | inlined_flag
_get_r:	push_tos
	ldr tos, [sp]
	bx lr
	end_inlined

	## Drop a value from the return stack
	define_word "rdrop", visible_flag | inlined_flag
_rdrop:	adds sp, #4
	bx lr
	end_inlined

	## Push two values onto the return stack
	define_word "2>r", visible_flag | inlined_flag
_push_2r:
	ldr r0, [dp], #4
        ldr r1, [dp], #4
	push {tos}
	push {r0}
	movs tos, r1
	bx lr
	end_inlined

	## Pop two values off the return stack
	define_word "2r>", visible_flag | inlined_flag
_pop_2r:
	push_tos
	pop {r0, tos}
	stmdb dp!, {r0}
	bx lr
	end_inlined

	## Get two values off the return stack without popping it
	define_word "2r@", visible_flag | inlined_flag
_get_2r:
	push_tos
	ldr tos, [sp, #4]
	ldr r0, [sp, #0]
	stmdb dp!, {r0}
	bx lr
	end_inlined
	
	## Drop two values from the return stack
	define_word "2rdrop", visible_flag | inlined_flag
_2rdrop:
	adds sp, #8
	bx lr
	end_inlined

	## Get the return stack pointer
	define_word "rp@", visible_flag | inlined_flag
_get_rp:
	push_tos
	mov tos, sp
	bx lr
	end_inlined

	## Set the return stack pointer
	define_word "rp!", visible_flag | inlined_flag
_store_rp:
	mov sp, tos
	pull_tos
	bx lr
	end_inlined

	## Get the data stack pointer
	define_word "sp@", visible_flag | inlined_flag
_get_sp:
	push_tos
	movs tos, dp
	bx lr
	end_inlined

	## Set the data stack pointer
	define_word "sp!", visible_flag | inlined_flag
_store_sp:
	movs dp, tos
	pull_tos
	bx lr
	end_inlined

	## Get the current compilation wordlist
	define_word "get-current", visible_flag
_get_current:
	ldr r0, =wordlist
	push_tos
	ldr tos, [r0]
	bx lr
	end_inlined

	## Set the current compilation wordlist
	define_word "set-current", visible_flag
_set_current:
	ldr r0, =wordlist
	str tos, [r0]
	pull_tos
	bx lr
	end_inlined

	## Get the current wordlist order
	define_word "get-order", visible_flag
_get_order:
  	ldr r0, =order
	ldr r1, =order_count
  	ldr r1, [r1]
	lsls r2, r1, #1
	adds r0, r2
3:	cmp r2, #0
	beq 4f
	subs r2, #2
	subs r0, #2
	push_tos
	ldrh tos, [r0]
	b 3b
4:	push_tos
	movs tos, r1
	bx lr
	end_inlined

	## Set the current wordlist order
	define_word "set-order", visible_flag
_set_order:
	ldr r0, =order
	ldr r1, =order_count
        cmp tos, #0
        blt 5f
2:	str tos, [r1]
	movs r1, tos
	pull_tos
3:	cmp r1, #0
	beq 4f
	subs r1, #1
	strh tos, [r0]
	pull_tos
	adds r0, #2
	b 3b
5:      movs tos, #1
        subs dp, #4
        movs r2, #0
        str r2, [dp]
        b 2b
4:	bx lr
	end_inlined

	## Context switch ( ctx -- old-ctx )
	define_internal_word "context-switch", visible_flag
_context_switch:
	movs r0, tos
	pull_tos
	push {r4, r5, r6, r7, r8, r9, r10}
	mov r1, sp
	mov sp, r0
	pop {r4, r5, r6, r7, r8, r9, r10}
	push_tos
	movs tos, r1
	bx lr
	end_inlined

	## Null exception handler
	define_word "handle-null", visible_flag
_handle_null:
	bx lr
	end_inlined

	## Initialize the variables
	define_internal_word "init-variables", visible_flag
_init_variables:
	push {lr}
	movs r1, #0
	ldr r0, =xon_xoff_enabled
	str r1, [r0]
        ldr r0, =postpone_literal_q
        str r1, [r0]
	ldr r1, =-1
	ldr r0, =ack_nak_enabled
	str r1, [r0]
	ldr r0, =bel_enabled
	str r1, [r0]
        ldr r0, =color_enabled
        str r1, [r0]
        ldr r0, =uart_special_enabled
        str r1, [r0]
        ldr r1, =syntax_stack + syntax_stack_size
        ldr r0, =syntax_stack_ptr
        str r1, [r0]
        ldr r0, =ram_current
	## Initialize the data stack base
	ldr r1, =stack_top
	str r1, [r0, #stack_base_offset]
	## Initialize the return stack base
	ldr r1, =rstack_top
	str r1, [r0, #rstack_base_offset]
	## Initialize the data stack end
	ldr r1, =stack_top - stack_size
	str r1, [r0, #stack_end_offset]
	## Initialize the return stack end
	ldr r1, =rstack_top - rstack_size
	str r1, [r0, #rstack_end_offset]
	## Initialize BASE
	movs r1, #10
	str r1, [r0, #base_offset]
        ## Initalize key-hook
        ldr r1, =_serial_key
        str r1, [r0, #key_hook_offset]
        ## Initialize key?-hook
        ldr r1, =_serial_key_q
        str r1, [r0, #key_q_hook_offset]
        ## Initialize emit-hook
        ldr r1, =_serial_emit
        str r1, [r0, #emit_hook_offset]
        ## Initialize emit?-hook
        ldr r1, =_serial_emit_q
        str r1, [r0, #emit_q_hook_offset]
	ldr r2, =cpu_count * 4
1:	cmp r2, #0
	beq 2f
	subs r2, #4
        movs r1, #0
        mvns r1, r1
	ldr r0, =pause_enabled
	str r1, [r0, r2]
	b 1b
2:	ldr r0, =error_hook
        ldr r1, =_execute
        str r1, [r0]
        ldr r0, =prompt_hook
	ldr r1, =_do_prompt
	str r1, [r0]
	ldr r0, =handle_number_hook
	ldr r1, =_do_handle_number
	str r1, [r0]
	ldr r0, =failed_parse_hook
	ldr r1, =_do_failed_parse
	str r1, [r0]
	ldr r0, =refill_hook
	ldr r1, =_do_refill
	str r1, [r0]
	ldr r0, =pause_hook
	ldr r1, =_do_nothing
	str r1, [r0]
        ldr r0, =reboot_hook
        str r1, [r0]
	ldr r0, =validate_dict_hook
	str r1, [r0]
        ldr r0, =word_begin_hook
        str r1, [r0]
        ldr r0, =word_exit_hook
        str r1, [r0]
        ldr r0, =word_end_hook
        str r1, [r0]
        ldr r0, =word_reset_hook
        str r1, [r0]
        ldr r0, =block_begin_hook
        str r1, [r0]
        ldr r0, =block_exit_hook
        str r1, [r0]
        ldr r0, =block_end_hook
        str r1, [r0]
	ldr r0, =finalize_hook
	str r1, [r0]
        ldr r0, =parse_hook
        movs r1, #0
        str r1, [r0]
	ldr r0, =find_hook
	ldr r1, =_find_raw
	str r1, [r0]
        ldr r0, =find_raw_hook
        ldr r1, =_do_find
        str r1, [r0]
	ldr r0, =compiling_to_flash
	movs r1, #0
	str r1, [r0]
	ldr r0, =current_compile
	str r1, [r0]
        ldr r0, =current_unit_start
        str r1, [r0]
	ldr r0, =deferred_literal
	str r1, [r0]
	ldr r0, =literal_deferred_q
	str r1, [r0]
	ldr r0, =latest
	str r1, [r0]
	ldr r0, =ram_latest
	str r1, [r0]
	ldr r0, =flash_latest
	str r1, [r0]
	ldr r0, =wordlist
	str r1, [r0]
	ldr r0, =build_target
	str r1, [r0]
	ldr r0, =current_flags
	str r1, [r0]
	ldr r0, =input_buffer_index
	str r1, [r0]
	ldr r0, =input_buffer_count
	str r1, [r0]
	ldr r0, =state
	str r1, [r0]
	ldr r0, =compress_flash_enabled
	str r1, [r0]
	ldr r0, =order
	strh r1, [r0]
	movs r1, #1
	ldr r0, =order_count
	str r1, [r0]
        bl _prepare_prompt
	pop {pc}
	end_inlined
	
	## Initialize the in-RAM vector table
_init_vector_table:
	ldr r0, =vectors
	ldr r1, =vectors + vector_table_size
	ldr r2, =vector_table
1:	cmp r0, r1
	beq 2f
	ldr r3, [r0]
	adds r0, #4
	str r3, [r2]
	adds r2, #4
	b 1b
2:	ldr r0, =VTOR
	ldr r1, =VTOR_value
	str r1, [r0]
	dmb
	dsb
	isb
	bx lr

	.ltorg
	
