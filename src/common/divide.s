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

	## Signed division of two two's complement integers
	define_word "/", visible_flag | inlined_flag
_div:	mv x15, tos
	pull_tos
        div tos, tos, x15
        ret
	end_inlined

	## Unsigned division of two integers
	define_word "u/", visible_flag | inlined_flag
_udiv:	mv x15, tos
        pull_tos
        divu tos, tos, x15
        ret
	end_inlined

	## Signed modulus of two two's complement integers
	define_word "mod", visible_flag | inlined_flag
_mod:	mv x15, tos
	pull_tos
        rem tos, tos, x15
        ret
	end_inlined

	## Unsigned modulus of two unsigned integers
	define_word "umod", visible_flag | inlined_flag
_umod:	mv x15, tos
	pull_tos
        remu tos, tos, x15
        ret
	end_inlined

	## Signed division and modulus of two two's complement integers
	## ( n1 n2 -- remainder quotient )
	define_word "/mod", visible_flag | inlined_flag
_divmod:
        mv x15, tos
        lc x14, 0(dp)
        div tos, x14, x15
        mul x13, tos, x15
        sub x14, x14, x13
        sc x14, 0(dp)
        ret
	end_inlined

	## Unsigned division and modulus of two unsigned integers
	## ( u1 u2 -- remainder quotient )
	define_word "u/mod", visible_flag | inlined_flag
_udivmod:
        mv x15, tos
        lc x14, 0(dp)
        divu tos, x14, x15
        mul x13, tos, x15
        sub x14, x14, x13
        sc x14, 0(dp)
        ret
	end_inlined

	
