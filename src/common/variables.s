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

        
	## The stack base offset
	.equ stack_base_offset, 0*cell

	## The stack end offset
	.equ stack_end_offset, 1*cell

	## The return stack base offset
	.equ rstack_base_offset, 2*cell

	## The return stack end offset
	.equ rstack_end_offset, 3*cell

	## The RAM HERE offset
	.equ ram_here_offset, 4*cell

	## The base offset
	.equ base_offset, 5*cell

	## The handler offset
	.equ handler_offset, 6*cell

        ## The key-hook offset
        .equ key_hook_offset, 7*cell

        ## The key?-hook offset
        .equ key_q_hook_offset, 8*cell

        ## The emit-hook offset
        .equ emit_hook_offset, 9*cell

        ## The emit?-hook offset
        .equ emit_q_hook_offset, 10*cell

	## The initial USER offset
	.equ user_offset, 11*cell

        ## The vector table in RAM
	allot vector_table, vector_table_size

	## Pointer to the current Flash HERE location
	allot flash_here, cell

	## Pointer to the base of HERE space
	allot dict_base, cell * cpu_count

	## Flag to determine whether compilation is going to Flash
	allot compiling_to_flash, cell

	## Flash buffers
	allot flash_buffers_start, flash_buffer_size * flash_buffer_count	

	## The word being currently compiled
	allot current_compile, cell

	## The current deferred literal
	allot deferred_literal, cell

	## Whether there is a deferred literal
	allot literal_deferred_q, cell

        ## Whether to postpone a literal
        allot postpone_literal_q, cell
        
	## The last word compiled
	allot latest, cell

	## The last word compiled to RAM
	allot ram_latest, cell

	## The last word compiled to flash
	allot flash_latest, cell

	## The compilation wordlist
	allot wordlist, cell

	## The current <BUILDS target address
	allot build_target, cell

	## The flags for the word being currently compiled
	allot current_flags, cell

	## Suppress inlining
	allot suppress_inline, cell

	## The evaluation buffer index pointer
	allot eval_index_ptr, cell

	## The evaluation buffer count pointer
	allot eval_count_ptr, cell

	## The evaluation buffer pointer
	allot eval_ptr, cell

        ## The evaluation data value
        allot eval_data, cell

        ## The evaluation refill word
        allot eval_refill, cell

        ## The evaluation EOF word
        allot eval_eof, cell
        
	## The current input buffer index
	allot input_buffer_index, cell

	## The input buffer count
	allot input_buffer_count, cell

	## The input buffer
	allot input_buffer, input_buffer_size + 1

	## Are we in compilation state
	allot state, cell

        ## Is the prompt disabled (disabled > 0)
        allot prompt_disabled, cell

	## Is PAUSE enabled (enabled > 0)
	allot pause_enabled, cell * cpu_count

	## Is compress flash enabled
	allot compress_flash_enabled, cell

	## Is XON/XOFF enabled
	allot xon_xoff_enabled, cell

	## Is ACK/NAK enabled
	allot ack_nak_enabled, cell

        ## Is color enabled
        allot color_enabled, cell
        
	## Is BEL enabled
	allot bel_enabled, cell

        ## Are UART special keys enabled
        allot uart_special_enabled, cell

	## The prompt hook
	allot prompt_hook, cell

	## The number parser hook
	allot handle_number_hook, cell

	## The failed parse hook
	allot failed_parse_hook, cell

	## The refill hook
	allot refill_hook, cell

	## The pause hook
	allot pause_hook, cell

	## The dictionary size validation hook
	allot validate_dict_hook, cell

	## The wordlist count
	allot order_count, cell

        ## The parse hook
        allot parse_hook, cell
        
	## The find hook
	allot find_hook, cell

        ## The find raw hook
        allot find_raw_hook, cell

        ## The word (including quotation) beginning hook
        allot word_begin_hook, cell

        ## The word exit hook
        allot word_exit_hook, cell

        ## The word end hook
        allot word_end_hook, cell

        ## The word reset hook
        allot word_reset_hook, cell

        ## The block beginning hook
        allot block_begin_hook, cell

        ## The block exit hook
        allot block_exit_hook, cell

        ## THe block end hook
        allot block_end_hook, cell
        
        ## The finalize hook
	allot finalize_hook, cell

        ## The error hook
        allot error_hook, cell

        ## The reboot hook
        allot reboot_hook, cell
        
	## The wordlist order
	allot order, 2 * max_order_size
	
	## The flash mini-dictionary
	allot flash_mini_dict, flash_mini_dict_size
	
        ## The syntax stack
        allot syntax_stack, syntax_stack_size

        ## The syntax stack pointer
        allot syntax_stack_ptr, cell

        ## The start of the current compilation unit (e.g. word, quotation)
        allot current_unit_start, cell

        ## The system clock speed in Hz
        allot sysclk, cell
