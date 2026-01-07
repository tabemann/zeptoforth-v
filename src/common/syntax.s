# Copyright (c) 2023-2026 Travis Bemann
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

        # Dump the syntax stack
        define_internal_word "dump-syntax", visible_flag
_dump_syntax:
        li x15, syntax_stack + syntax_stack_size - 1
        li x14, syntax_stack_ptr
        lc x14, 0(x14)
1:      bltu x15, x14, 2f
        push_tos
        lbu tos, 0(x15)
        addi x15, x15 -1
        j 1b
2:      push_tos
        li tos, syntax_stack + syntax_stack_size
        sub tos, tos, x14
        ret
        end_inlined
        
        # Push a syntax onto the syntax stack
        # ( syntax -- )
        define_internal_word "push-syntax", visible_flag
_push_syntax:
        push ra
        li x15, syntax_stack_ptr
        lc x14, 0(x15)
        li x13, syntax_stack
        bne x14, x13, 1f
        li tos, _syntax_overflow
        call _raise
1:      addi x14, x14, -1
        sb tos, 0(x14)
        sc x14, 0(x15)
        pull_tos
        pop ra
        ret
        end_inlined

        # Verify a syntax on the syntax stack against one syntax
        # ( syntax -- )
        define_internal_word "verify-syntax", visible_flag
_verify_syntax:
        push ra
        li x15, syntax_stack_ptr
        lc x14, 0(x15)
        li x13, syntax_stack + syntax_stack_size
        bne x14, x13, 1f
        li tos, _syntax_underflow
        call _raise
1:      lbu x12, 0(x14)
        beq tos, x12, 2f
        li tos, _unexpected_syntax
        call _raise
2:      pull_tos
        pop ra
        ret
        end_inlined

        # Get the topmost syntax
        define_internal_word "get-syntax", visible_flag
_get_syntax:
        li x15, syntax_stack_ptr
        lc x14, 0(x15)
        li x13, syntax_stack + syntax_stack_size
        push_tos
        bne x14, x13, 1f
        li tos, _syntax_underflow
        call _raise
1:      lbu tos, 0x(14)
        ret
        end_inlined
        
        # Verify a syntax on the syntax stack against two syntaxes
        # ( syntax1 syntax0 -- )
        define_internal_word "verify-syntax-2", visible_flag
_verify_syntax_2:
        push ra
        li x15, syntax_stack_ptr
        lc x14, 0(x15)
        li x13, syntax_stack + syntax_stack_size
        bne x14, x13, 1f
        li tos, _syntax_underflow
        call _raise
1:      lbu x12, 0(x14)
        bne tos, x12, 2f
        lc tos, cell(dp)
        addi dp, dp, 2*cell
        pop ra
        ret
2:      pull_tos
        beq tos, x12, 3f
        li tos, _unexpected_syntax
        call _raise
3:      pull_tos
        pop ra
        ret
        end_inlined
        
        # Drop a syntax on the syntax stack
        # ( -- )
        define_internal_word "drop-syntax", visible_flag
_drop_syntax:
        push ra
        li x15, syntax_stack_ptr
        lc x14, 0(x15)
        li x13, syntax_stack + syntax_stack_size
        bne x14, x13, 1f
        push_tos
        li tos, _syntax_underflow
        call _raise
1:      addi x14, x14, 1
        sc x14, 0(x15)
        pop ra
        ret
        end_inlined

        # Unexpected syntax exception
        define_internal_word "x-unexpected-syntax", visible_flag
_unexpected_syntax:
        push ra
        string_ln "unexpected syntax"
        call _type
        pop ra
        ret
        end_inlined

        # Syntax underflow
        define_internal_word "x-syntax-underflow", visible_flag
_syntax_underflow:
        push ra
        string_ln "syntax underflow"
        call _type
        pop ra
        ret
        end_inlined

        # Syntax overflow
        define_internal_word "x-syntax-overflow", visible_flag
_syntax_overflow:
        push ra
        string_ln "syntax overflow"
        call _type
        pop ra
        ret
        end_inlined

        .ltorg
        
