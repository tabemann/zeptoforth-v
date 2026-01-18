# Copyright (c) 2020-2026 Travis Bemann
# Copyright (c) 2024 Paul Koning
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

	.include "../common/expose.s"
	
	## Get the CPU index
	define_word "cpu-index", visible_flag | inlined_flag
_cpu_index:
	push_tos
	li tos, 0xD0000000
        lc tos, 0(tos)
	ret
	end_inlined

	## Get the CPU offset for a word value
	define_word "cpu-offset", visible_flag | inlined_flag
_cpu_offset:
	push_tos
	li tos, 0xD0000000
	lc tos, 0(tos)
        slli tos, tos, cell_bytes_power
        ret
	end_inlined

	## Get the SIO hook address
	define_word "sio-hook", visible_flag
_sio_hook:
	push ra
	call _cpu_offset
	li x15, sio_hook
	add tos, tos, x15
	pop ra
        ret
	end_inlined

	## Get the core 1 launched variable
	define_internal_word "core-1-launched", visible_flag
_core_1_launched:
	push_tos
	li tos, core_1_launched
	ret
	end_inlined

        ## Get the PSRAM size
        define_word "psram-size", visible_flag
_psram_size:
        push_tos
        li tos, psram_size
        lc tos, 0(tos)
        ret
        end_inlined

        ## PSRAM base address
        define_word "psram-base", visible_flag
_psram_base:
        push_tos
        li tos, psram_base
        ret
        end_inlined
