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

	## Raise an exception with the exception type in the TOS register
	define_word "?raise", visible_flag
_raise: beq tos, zero, 1f
        call _cpu_offset
        li x15, dict_base
        add x15, x15, tos
        lc x15, 0(x15)
        addi x15, handler_offset
        pull_tos
        lc sp, 0(x15)
        lcsp x14, 0(sp)
        sc x14, 0(x15)
        lcsp dp, 1*cell(sp)
        lcsp ra, 2*cell(sp)
        addi sp, sp, 3*cell
        ret
1:      pull_tos
        ret
        end_inlined

	## Try to see if an exception occurs
	define_word "try", visible_flag
_try:   addi sp, sp, -3*cell
        scsp ra, 2*cell(sp)
        call _cpu_offset
        li x14, dict_base
        add x14, x14, tos
        lc x14, 0(x14)
        addi x14, x14, handler_offset
        pull_tos
        scsp dp, 1*cell(sp)
        lc x15, 0(x14)
        scsp x15, 0(sp)
        sc sp, 0(x14)
        mv x15, tos
        pull_tos
        jalr ra, x15
        call _cpu_offset
        li x15, dict_base
        add x15, x15, tos
        lc x15, 0(x15)
        addi x15, x15, handler_offset
        pull_tos
        lcsp x14, 0(sp)
        lc x14, 0(x15)
        push_tos
        li tos, 0
        lcsp ra, 2*cell(sp)
        addi sp, sp, 3*cell
        ret
        end_inlined
