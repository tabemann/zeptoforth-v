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

	## Get the STATE variable address
	define_word "state", visible_flag
_state:	push_tos
	li tos, state
	ret
	end_inlined

	## Get the BASE variable address
	define_word "base", visible_flag
_base:	push ra
	call _cpu_offset
	li x15, dict_base
	addi tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, base_offset
	pop ra
        ret
	end_inlined

	## Get the PAUSE enabled variable address
	define_word "pause-enabled", visible_flag
_pause_enabled:
        push ra
        call _cpu_offset
        li x15, pause_enabled
        add tos, tos, x15
        pop ra
        ret
	end_inlined

	## Get the XON/XOFF enabled variable address
	define_word "xon-xoff-enabled", visible_flag
_xon_xoff_enabled:
	push_tos
	li tos, xon_xoff_enabled
	ret
	end_inlined

	## Get the ACK/NAK enabled variable address
	define_word "ack-nak-enabled", visible_flag
_ack_nak_enabled:
	push_tos
	li tos, ack_nak_enabled
	ret
	end_inlined

        ## Get the color enabled variable address
        define_word "color-enabled", visible_flag
_color_enabled:
        push_tos
        li tos, color_enabled
        ret
	end_inlined

	## Get the BEL enabled variable address
	define_word "bel-enabled", visible_flag
_bel_enabled:
	push_tos
	li tos, bel_enabled
	ret
	end_inlined

        ## Get the UART special enabled variable address
        define_word "uart-special-enabled", visible_flag
_uart_special_enabled:
        push_tos
        li tos, uart_special_enabled
        ret
        end_inlined
        
	## Get the RAM dictionary base variable address
	define_word "dict-base", visible_flag
_dict_base:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	pop ra
        ret
	end_inlined
	
	## Get the RAM base
	define_word "ram-base", visible_flag
_ram_base:
	push_tos
	li tos, ram_start
	ret
	end_inlined

	## Get the RAM end
	define_word "ram-end", visible_flag
_ram_end:
	push_tos
	li tos, ram_end
	ret
	end_inlined

	## Get the flash base
	define_word "flash-base", visible_flag
_flash_base:
	push_tos
	li tos, flash_start
	ret
	end_inlined

	## Get the flash end
	define_word "flash-end", visible_flag
_flash_end:
	push_tos
	li tos, flash_dict_end
	ret
	end_inlined
	
	## Get the current stack base variable address
	define_word "stack-base", visible_flag
_stack_base:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, stack_base_offset
	pop ra
        ret
	end_inlined

	## Get the current stack end variable address
	define_word "stack-end", visible_flag
_stack_end:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, stack_end_offset
	pop ra
        ret
	end_inlined

	## Get the current return stack base variable address
	define_word "rstack-base", visible_flag
_rstack_base:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, rstack_base_offset
	pop ra
        ret
	end_inlined

	## Get the current returns stack end variable address
	define_word "rstack-end", visible_flag
_rstack_end:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, rstack_end_offset
	pop ra
        ret
	end_inlined

	## Get the current exception handler variable address
	define_word "handler", visible_flag
_handler:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, handler_offset
	pop ra
        ret
	end_inlined

	## The parse index
	define_word ">parse", visible_flag
_to_parse:
	push_tos
	ldr tos, =eval_index_ptr
	ldr tos, [tos]
	bx lr
	end_inlined

	## THe parse count
	define_word "parse#", visible_flag
_parse_count:	
	push_tos
	ldr tos, =eval_count_ptr
	ldr tos, [tos]
	ldr tos, [tos]
	bx lr
	end_inlined

	## The source info
	define_word "parse-buffer", visible_flag
_parse_buffer:
	push_tos
	ldr tos, =eval_ptr
	ldr tos, [tos]
	bx lr
	end_inlined
	
	## The source info
	define_word "source", visible_flag
_source:
	push_tos
	ldr tos, =eval_ptr
	ldr tos, [tos]
	push_tos
	ldr tos, =eval_count_ptr
	ldr tos, [tos]
	ldr tos, [tos]
	bx lr
	end_inlined

	## Get the address to store a literal in for the word currently being
	## built
	define_word "build-target", visible_flag
_build_target:
	push_tos
	li tos, build_target
	ret
	end_inlined

	## Get the base of the system RAM dictionary space
	define_word "sys-ram-dict-base", visible_flag
_sys_ram_dict_base:
	push_tos
	li tos, ram_current
	ret
	end_inlined

	## The input buffer index
	define_word ">in", visible_flag
_to_in:	push_tos
	li tos, input_buffer_index
	ret
	end_inlined

	## The input buffer count
	define_word "input#", visible_flag
_input_count:
	push_tos
	li tos, input_buffer_count
	ret
	end_inlined

	## The input buffer
	define_word "input", visible_flag
_input:	push_tos
	li tos, input_buffer
	ret
	end_inlined

	## The input buffer size
	define_word "input-size", visible_flag
_input_size:
	push_tos
	li tos, input_buffer_size
	ret
	end_inlined

	## The wordlist count
	define_word "order-count", visible_flag
_order_count:
	push_tos
	li tos, order_count
	ret
	end_inlined

	## The wordlist order
	define_word "order", visible_flag
_order: push_tos
	li tos, order
	ret
	end_inlined
	
	## The prompt hook
	define_word "prompt-hook", visible_flag
_prompt_hook:
	push_tos
	li tos, prompt_hook
	ret
	end_inlined

	## The handle number hook
	define_word "handle-number-hook", visible_flag
_handle_number_hook:
	push_tos
	li tos, handle_number_hook
	ret
	end_inlined

	## The failed parse hook
	define_word "failed-parse-hook", visible_flag
_failed_parse_hook:
	push_tos
	li tos, failed_parse_hook
	ret
	end_inlined

	## The emit hook
	define_word "emit-hook", visible_flag
_emit_hook:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, emit_hook_offset
	pop ra
        ret
	end_inlined

	## The emit? hook
	define_word "emit?-hook", visible_flag
_emit_q_hook:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, emit_q_hook_offset
	pop ra
        ret
	end_inlined

	## The key hook
	define_word "key-hook", visible_flag
_key_hook:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, key_hook_offset
	pop ra
        ret
	end_inlined

	## The key? hook
	define_word "key?-hook", visible_flag
_key_q_hook:
	push ra
	call _cpu_offset
	li x15, dict_base
	add tos, tos, x15
	lc tos, 0(tos)
	addi tos, tos, key_q_hook_offset
	pop ra
        ret
	end_inlined

        ## The error hook
        define_word "error-hook", visible_flag
_error_hook:
        push_tos
        li tos, error_hook
        ret
        end_inlined
        
	## The refill hook
	define_word "refill-hook", visible_flag
_refill_hook:
	push_tos
	li tos, refill_hook
	ret
	end_inlined

	## The pause hook
	define_word "pause-hook", visible_flag
_pause_hook:
	push_tos
	li tos, pause_hook
	ret
	end_inlined

	## The dictionary size validation hook
	define_word "validate-dict-hook", visible_flag
_validate_dict_hook:
	push_tos
	li tos, validate_dict_hook
	ret
	end_inlined
        
        ## The parse hook
        define_word "parse-hook", visible_flag
_parse_hook:
        push_tos
        li tos, parse_hook
        ret
        end_inlined
        
	## The find hook
	define_word "find-hook", visible_flag
_find_hook:
	push_tos
	li tos, find_hook
	ret
	end_inlined

        ## The find raw hook
        define_word "find-raw-hook", visible_flag
_find_raw_hook:
        push_tos
        li tos, find_raw_hook
        ret
        end_inlined

        ## The word (including quotation) beginning hook
        define_word "word-begin-hook", visible_flag
_word_begin_hook:
        push_tos
        li tos, word_begin_hook
        ret
        end_inlined

        ## The word exit hook
        define_word "word-exit-hook", visible_flag
_word_exit_hook:
        push_tos
        li tos, word_exit_hook
        ret
        end_inlined

        ## The word end hook
        define_word "word-end-hook", visible_flag
_word_end_hook:
        push_tos
        li tos, word_end_hook
        ret
        end_inlined

        ## The word reset hook
        define_word "word-reset-hook", visible_flag
_word_reset_hook:
        push_tos
        li tos, word_reset_hook
        ret
        end_inlined

        ## The block beginning hook
        define_word "block-begin-hook", visible_flag
_block_begin_hook:
        push_tos
        li tos, block_begin_hook
        ret
        end_inlined
        
        ## The block exit hook
        define_word "block-exit-hook", visible_flag
_block_exit_hook:
        push_tos
        li tos, block_exit_hook
        ret
        end_inlined

        ## The block end hook
        define_word "block-end-hook", visible_flag
_block_end_hook:
        push_tos
        li tos, block_end_hook
        ret
        end_inlined

	## The finalize hook
	define_word "finalize-hook", visible_flag
_finalize_hook:
	push_tos
	li tos, finalize_hook
	ret
	end_inlined

        ## The reboot hook
        define_word "reboot-hook", visible_flag
_reboot_hook:
        push_tos
        li tos, reboot_hook
        ret
        end_inlined
        
	## The vector table address
	define_word "vector-table", visible_flag
_vector_table:
	push_tos
	li tos, vector_table
	ret
	end_inlined

	## The vector count
	define_word "vector-count", visible_flag
_vector_count:
	push_tos
	li tos, vector_count
	ret
	end_inlined

	## The flash mini-dictionary base address
	define_internal_word "flash-mini-dict", visible_flag
_flash_mini_dict:
	push_tos
	li tos, flash_mini_dict
	ret
	end_inlined

	## The flash mini-dictionary size
	define_internal_word "flash-mini-dict-size", visible_flag
_flash_mini_dict_size:
	push_tos
	li tos, flash_mini_dict_size
	ret
	end_inlined

        ## Get a pair of codes indicating the CPU
        define_word "chip", visible_flag
_chip:  addi dp, dp, -2*cell
        sc tos, cell(dp)
        li tos, chip1
        sc tos, 0(dp)
        li tos, chip0
        ret
        end_inlined

	## Get the CPU count
	define_word "cpu-count", visible_flag | inlined_flag
_cpu_count:
	push_tos
	movs tos, #cpu_count
	bx lr
	end_inlined

        ## Get the evaluation buffer index pointer address
        define_internal_word "eval-index-ptr", visible_flag
_eval_index_ptr:
        push_tos
        li tos, eval_index_ptr
        ret
        end_inlined

        ## Get the evaluation buffer count pointer address
        define_internal_word "eval-count-ptr", visible_flag
_eval_count_ptr:
        push_tos
        li tos, eval_count_ptr
        ret
        end_inlined

        ## Get the evaluatiaon buffer pointer address
        define_internal_word "eval-ptr", visible_flag
_eval_ptr:
        push_tos
        li tos, eval_ptr
        ret
        end_inlined

        ## Get the evaluation data value address
        define_internal_word "eval-data", visible_flag
_eval_data:
        push_tos
        li tos, eval_data
        ret
        end_inlined

        ## Get the evaluation refill word address
        define_internal_word "eval-refill", visible_flag
_eval_refill:
        push_tos
        li tos, eval_refill
        ret
        end_inlined

        ## Get the evaluation EOF word address
        define_internal_word "eval-eof", visible_flag
_eval_eof:
        push_tos
        li tos, eval_eof
        ret
        end_inlined

        ## Get the prompt disabled value address
        define_internal_word "prompt-disabled", visible_flag
_prompt_disabled:
        push_tos
        li tos, prompt_disabled
        ret
        end_inlined

        ## The current compilation unit (e.g. word, quotation) variable
        define_internal_word "current-unit-start", visible_flag
_current_unit_start:
        push_tos
        li tos, current_unit_start
        ret
        end_inlined

	## Get the sysclk variable
	define_word "sysclk", visible_flag
_sysclk:
	push_tos
	li tos, sysclk
	ret
	end_inlined
