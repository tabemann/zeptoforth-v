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

        ## Test whether a register is a compressed register
        ## ( reg -- compressed? )
        define_internal_word "c-reg?", visible_flag
_asm_q_c_reg:
        li x15, 7
        sltu x14, x15, tos
        li x15, 16
        sltu x13, tos, x15
        and tos, x13, x14
        srai tos, tos, sign_shift
        ret
        end_inlined

        ## Compress a register
        ## ( reg -- c-reg )
        define_internal_word ">c-reg", visible_flag
_asm_to_c_reg:
        addi tos, tos, -8
        ret
        end_inlined

        ## Compute immediate field of c.j and c.jal -- transform PC-relative
        ## offset into imm[11 | 4 | 9:8 | 10 | 6 | 7 | 3:1 | 5 ] | 00
        ## ( offset -- imm-field )
        define_internal_word "transform-c.j-imm", visible_flag
_asm_transform_c_j_imm:
        srli x15, tos, 11
        andi x15, x15, 1
        slli x15, x15, 12
        srli x14, tos, 4
        andi x14, x14, 1
        slli x14, x14, 11
        or x15, x15, x14
        srli x14, tos, 8
        andi x14, x14, 3
        slli x14, x14, 9
        or x15, x15, x14
        srli x14, tos, 10
        andi x14, x14, 1
        slli x14, x14, 8
        or x15, x15, x14
        srli x14, tos, 6
        andi x14, x14, 1
        slli x14, x14, 7
        or x15, x15, x14
        srli x14, tos, 7
        andi x14, x14, 1
        slli x14, x14, 6
        or x15, x15, x14
        srli x14, tos, 1
        andi x14, x14, 7
        slli x14, x14, 3
        or x15, x15, x14
        srli x14, tos, 5
        andi x14, x14, 1
        slli x14, x14, 2
        or tos, x15, x14
        ret
        end_inlined

        ## Compile a c.j instruction -- imm is a PC relative offset, lowest
        ## bit is ignored.
        ## ( imm -- )
        define_internal_word "c.j," visible_flag
_asm_c_j:
        push ra
        call _asm_transform_c_j_imm
        li x15, (5 << 13) | (1 << 0) # C.J
        or tos, tos, x15
        call _current_comma_2
        pop ra
        ret
        end_inlined

        ## Compile a c.jal instruction -- imm is a PC relative offset, lowest
        ## bit is ignored.
        ## ( imm -- )
        define_internal_word "c.jal," visible_flag
_asm_c_jal:
        push ra
        call _asm_transform_c_j_imm
        li x15, (1 << 13) | (1 << 0) # C.JAL
        or tos, tos, x15
        call _current_comma_2
        pop ra
        ret
        end_inlined

        ## Build a jal instruction -- imm is a PC relative offset, lowest bit
        ## is ignored
        ## ( imm reg -- instr )
        define_internal_word "build-jal", visible_flg
_asm_build_jal:
        slli tos, tos, 7
        lc x15, 0(dp)
        addi dp, dp, cell
        srli x14, x15, 20
        andi x14, x14, 1
        slli x14, x14, 31
        or tos, tos, x14
        srli x14, x15, 12
        andi x14, x14, 0xFF
        slli x14, x14, 12
        or tos, tos, x14
        srli x14, x15, 11,
        andi x14, x14, 1
        slli x14, x14, 20
        or tos, tos, x14
        srli x14, x15, 1
        andi x14, x14, 0x3FF
        slli x14, x14, 21
        or tos, tos, x14
        ori tos, tos, 0x6F
        ret
        end_inlined

        ## Build a c.beqz reg, offset instruction
        ## ( offset reg -- instr )
        define_internal_word "build-c.beqz", visible_flag
_asm_build_c_beqz:
        push ra
        call _asm_to_c_reg
        lc x15, 0(dp)
        addi dp, dp, cell
        slli tos, tos, 7
        srli x14, x15, 8
        andi x14, x14, 1
        slli x14, x14, 12
        or tos, tos, x14
        srli x14, x15, 6
        andi x14, x14, 3
        slli x14, x14, 5
        or tos, tos, x14
        srli x14, x15, 5
        andi x14, x14, 1
        slli x14, x14, 2
        or tos, tos, x14
        srli x14, x15, 3
        andi x14, x14, 3
        slli x14, x14, 10
        or tos, tos, x14
        srli x14, x15, 1
        andi x14, x14, 3
        slli x14, x14, 3
        or tos, tos, x14
        li x15, 0xC001
        or tos, tos, x15
        pop ra
        ret
        end_inlined

        ## Build a beq reg, zero, offset instruction
        ## ( offset reg -- instr )
        define_internal_word "build-beq-zero", visible_flag
_asm_build_beq_zero:
        lc x15, 0(dp)
        addi dp, dp, cell
        slli tos, tos, 15
        srli x14, x15, 12
        andi x14, x14, 1
        slli x14, x14, 31
        or tos, tos, x14
        srli x14, x15, 11
        andi x14, x14, 1
        slli x14, x14, 7
        or tos, tos, x14
        srli x14, x15, 5
        andi x14, x14, 0x3F
        slli x14, x14, 25
        or tos, tos, x14
        srli x14, x15, 1
        andi x14, x14, 0xF
        slli x14, x14, 8
        or tos, tos, x14
        ori tos, tos, 0x63
        ret
        end_inlined
        
        ## Compile a mv instruction
        ## ( src-reg dest-reg -- )
        define_internal_word "mv,", visible_flag
_asm_mv:
        push ra
        lc x15, 0(dp)
        addi dp, dp, cell
        slli tos, tos, 7
        slli x15, x15, 2
        or tos, x15
        li x15, 0x8002 # C.MV
        or tos, x15
        call _current_comma_2
        pop ra
        ret
        end_inlined

        ## Compile an addi instruction
        ## ( imm rs1 rd -- instr )
        define_internal_word "build-addi" visible_flag
_asm_build_addi:
        lc x15, 0(dp)
        lc x14, cell(dp)
        addi dp, dp, 2*cell
        slli tos, tos, 7
        slli x15, x15, 15
        or tos, tos, x15
        slli x14, x14, 20
        or tos, tos, x14
        li x15, 0x13 # ADDI
        or tos, tos, x15
        ret
        end_inlined

        ## Compile a lui instruction -- note that the lower 12 bits of imm
        ## are ignored.
        ## ( imm rd -- instr )
        define_internal_word "build-lui" visible_flag
_asm_build_lui:
        lc x15, 0(dp)
        addi dp, dp, cell
        slli tos, tos, 7
        li x14, 0xFFFFF000
        and x15, x15, x14
        or tos, tos, x15
        ori tos, tos, 0x37
        ret
        end_inlined

        ## Compile a c.addi instruction -- nzimm is a sign-extended 6 bit value
        ## that cannot be zeror.
        ## ( nzimm rd -- )
        define_internal_word "c.addi," visible_flag
_asm_c_addi:
        push ra
        lc x14, 0(dp)
        addi dp, dp, cell
        slli tos, tos, 7
        srai x15, x14, 5
        andi x15, x15, 0x01
        slli x15, x15, 12
        andi x14, x14, 0x1F
        slli x14, x14, 2
        or tos, tos, x14
        or tos, tos, x15
        ori tos, tos, 0x01
        call _current_comma_2
        pop ra
        ret
        end_inlined

        ## Compile a c.li instruction -- imm is a sign-extended 6 bit value
        ## ( imm rd -- )
        define_internal_word "c.li", visible_flag
_asm_c_li:
        push ra
        lc x14, 0(dp)
        addi dp, dp, cell
        slli tos, tos, 7
        srai x15, x14, 5
        andi x15, x15, 0x01
        slli x15, x15, 12
        andi x14, x14, 0x1F
        slli x14, x14, 2
        or tos, tos, x14
        or tos, tos, x15
        li x15, (2 << 13) | (1 << 0) # C.LI
        or tos, tos, x15
        call _current_comma_2
        pop ra
        ret
        end_inlined

        ## Compile a c.lui instruction -- note that the lower 12 bits and the
        ## upper 14 bits of imm are ignored.
        ## ( imm rd -- )
        define_internal_word "c.lui", visible_flag
_asm_c_lui:
        push ra
        lc x15, 0(dp)
        addi dp, dp, cell
        slli tos, tos, 7
        li x14, 0x0003F000
        and x15, x15, x14
        srli x14, x15, 5
        or tos, tos, x14
        slli x15, x15, sign_shift - 16
        srli x15, x15, sign_shift - 6
        or tos, tos, x15
        li x15, (3 << 13) | (1 << 0) # C.LUI
        or tos, tos, x15
        call _current_comma_2
        pop ra
        ret
        end_inlined

        ## Test a literal and adjust the upper bits need be
        ## ( n -- n' )
        define_internal_word "adjust-upper" visible_flag
_asm_adjust_upper:
        li x15, 0x800
        and x14, tos, x15
        bne x14, zero, 1f
        ret
1:      li x15, 0x1000
        add tos, tos, x15
        ret
        end_inlined
        
        ## Compile a literall
        ## ( u rd -- )
        define_internal_word "literal,", visible_flag
_asm_literal:
        lc x15, 0(dp)
        li x14, 0x1F
        blt x14, x15, 1f
        li x14, -0x20
        blt x15, x14, 1f
        j _asm_c_li
        ret
1:      push ra
        call _swap
        call _asm_adjust_upper
        call _swap
        lc x15, 0(dup)
        li x14, 0x1FFFF
        blt x14, x15, 2f
        li x14, -0x20000
        blt x15, x14, 2f
        call _2dup
        call _asm_c_lui
        j 3f
2:      call _2dup
        call _asm_build_lui
        call _current_comma_4
3:      lc x15, 0(dp)
        slli x15, x15, cell_bits - 12
        srai x15, x15, cell_bits - 12
        bne x15, zero, 4f
        call _2drop
        j 6f
4:      li x14, 0x1F
        blt x14, x15, 5f
        blt x15, zero, 5f
        call _asm_c_addi
        j 6f
5:      push_tos
        call _asm_build_addi
        call _current_comma_4
6:      pop ra
        ret
        end_inlined
        
        ## Compile:
        ##
        ## c.lwsp ra, 0(sp)
        ## c.addi sp, sp, cell
        ## c.jr ra
        define_internal_word "exit,", visible_flag
_asm_exit:
        push ra
        # Note: the instructions are loaded onto the stack in reverse order.
        addi dp, dp, -3*cell
        sc tos, 2*cell(dp)
        li tos, (4 << 13) | (1 << 7) | (2 << 0) # c.jr ra
        sc tos, 1*cell(dp)
        li tos, (0 << 13) | (2 << 7) | (4 << 2) | (1 << 0) # c.addi sp, sp, 4
        sc tos, 0(dp)
        li tos, (2 << 13) | (1 << 7) | (2 << 0) # c.lwsp ra, 0(sp)
        call _current_comma_2
        call _current_comma_2
        call _current_comma_2
        pop ra
        ret
        end_inlined

        ## Compile:
        ##
        ## c.addi dp, dp, -cell
        ## (c.)sw reg, 0(dp)
        ##
        ## ( reg -- )
        define_internal_word "push,", visible_flag
_asm_push:
        push ra
        push_tos
        # c.addi dp, dp, -cell
        li tos, (1 << 12) | (8 << 7) | ((-4 & 0x1F) << 2) | (1 << 0)
        call _current_comma_2
        call _dup
        call _asm_q_c_reg
        beq tos, zero, 1f
        pull_tos
        call _asm_to_c_reg
        slli tos, tos, 2
        li x15, (6 << 13) | ((8 - 8) << 7) # c.sw reg, 0(dp)
        or tos, tos, x15
        call _current_comma_2
        pop ra
        ret
1:      pull_tos
        slli tos, tos, 20
        li x15, (8 << 15) | (2 << 12) | (0x23 << 0) # sw reg, 0(dp)
        or tos, tos, x15
        call _current_comma_4
        pop ra
        ret
        end_inlined

        ## Compile:
        ##
        ## (c.)lw reg, 0(dp)
        ## c.addi dp, dp, -cell
        ##
        ## ( reg -- )
        define_internal_word "push,", visible_flag
_asm_push:
        push ra
        call _dup
        call _asm_q_c_reg
        beq tos, zero, 1f
        pull_tos
        call _asm_to_c_reg
        slli tos, tos, 2
        li x15, (2 << 13) | ((8 - 8) << 7) # c.lw reg, 0(dp)
        or tos, tos, x15
        call _current_comma_2
        j 2f
1:      pull_tos
        slli tos, tos, 7
        li x15, (8 << 15) | (2 << 12) | (0x03 << 0) # lw reg, 0(dp)
        or tos, tos, x15
        call _current_comma_4
2       push_tos
        li tos, (8 << 7) | (4 << 2) | (1 << 0) # c.addi dp, dp, cell
        call _current_comma_2

        end_inlined
        
	## Compile the header of a word
	define_internal_word "start-compile-header", visible_flag
_asm_start_header:
	push {lr}
	bl _asm_undefer_lit
        push_tos
        movs tos, #syntax_word
        bl _push_syntax
	movs r0, #0
	ldr r1, =suppress_inline
	str r0, [r1]
	push_tos
	movs tos, #4
	bl _current_comma_align
	bl _current_here
	ldr r0, =current_compile
	str tos, [r0]
	ldr r0, =current_flags
	movs r1, #0
	str r1, [r0]
	movs tos, #2
	bl _current_allot
	bl _get_current
	bl _current_comma_2
	bl _asm_link
	bl _current_comma_cstring
	bl _current_here
	movs r0, #1
	tst tos, r0
	beq 1f
	movs tos, #0
	bl _current_comma_1
        bl _current_here
1:      ldr r0, =current_unit_start
        str tos, [r0]
        pull_tos
        pop {pc}
	end_inlined

	## Compile the start of a word without the push {lr}
        define_internal_word "start-compile-no-push", visible_flag
_asm_start_no_push:
        push {lr}
	bl _asm_start_header
        ldr r0, =word_begin_hook
        ldr r0, [r0]
        cmp r0, #0
        beq 1f
        movs r1, #1
        orrs r0, r1
        blx r0
1:      pop {pc}
        end_inlined

	## Compile the start of a word
	define_internal_word "start-compile", visible_flag
_asm_start:
	push {lr}
	bl _asm_start_header
	push_tos
	ldr tos, =0xB500	## push {lr}
	bl _current_comma_2
        ldr r0, =word_begin_hook
        ldr r0, [r0]
        cmp r0, #0
        beq 1f
        movs r1, #1
        orrs r0, r1
        blx r0
1:      pop {pc}
	end_inlined

	## Compile a link field
	define_internal_word "current-link,", visible_flag
_asm_link:
	push {lr}
	push_tos
	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	beq 1f
	ldr r0, =flash_latest
	b 2f
1:	ldr r0, =ram_latest
2:	ldr tos, [r0]
	bl _current_comma_4
	pop {pc}
	end_inlined

	## Finalize the compilation of a word
	define_internal_word "finalize,", visible_flag
_asm_finalize:
	push {lr}
	bl _asm_undefer_lit
        push_tos
        movs tos, #syntax_word
        bl _verify_syntax
        bl _drop_syntax
	bl _asm_word_align
	push_tos
	ldr tos, =current_flags
	ldr tos, [tos]
	ldr r0, =suppress_inline
	ldr r0, [r0]
	ldr r1, =inlined_flag
	ands r0, r1
	bics tos, r0
	ldr r0, =current_flags
	str tos, [r0]
	push_tos
	ldr tos, =current_compile
	ldr tos, [tos]
	bl _store_current_1
1:	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	beq 1f
	ldr r0, =compress_flash_enabled
	ldr r0, [r0]
	cmp r0, #0
	bne 3f
	push_tos
	ldr r0, =current_compile
	ldr tos, [r0]
	bl _current_comma_4
	push_tos
	ldr tos, =0xDEADBEEF
	bl _current_comma_4
	bl _flash_block_align
3:	ldr r0, =current_compile
	ldr r1, [r0]
	ldr r2, =flash_latest
	str r1, [r2]
	b 2f
1:	ldr r0, =current_compile
	ldr r1, [r0]
	ldr r2, =ram_latest
	str r1, [r2]
2:	ldr r2, =latest
	str r1, [r2]
	movs r1, #0
	str r1, [r0]
        push_tos
        ldr tos, =finalize_hook
	ldr tos, [tos]
	bl _execute_nz
        ldr r0, =current_unit_start
        movs r1, #0
        str r1, [r0]
	pop {pc}
	end_inlined
	
	## Finalize the compilation of a word without aligning
	define_internal_word "finalize-no-align,", visible_flag
_asm_finalize_no_align:
	push {lr}
	bl _asm_undefer_lit
        push_tos
        movs tos, #syntax_word
        bl _verify_syntax
        bl _drop_syntax
	bl _asm_word_align
	push_tos
	ldr tos, =current_flags
	ldr tos, [tos]
	ldr r0, =suppress_inline
	ldr r0, [r0]
	ldr r1, =inlined_flag
	ands r0, r1
	bics tos, r0
	ldr r0, =current_flags
	str tos, [r0]
	push_tos
	ldr tos, =current_compile
	ldr tos, [tos]
	bl _store_current_1
1:	ldr r0, =compiling_to_flash
	ldr r0, [r0]
	cmp r0, #0
	beq 1f
	ldr r0, =compress_flash_enabled
	ldr r0, [r0]
	cmp r0, #0
	bne 3f
	push_tos
	ldr r0, =current_compile
	ldr tos, [r0]
	bl _current_comma_4
	push_tos
	ldr tos, =0xDEADBEEF
	bl _current_comma_4
3:	ldr r0, =current_compile
	ldr r1, [r0]
	ldr r2, =flash_latest
	str r1, [r2]
	b 2f
1:	ldr r0, =current_compile
	ldr r1, [r0]
	ldr r2, =ram_latest
	str r1, [r2]
2:	ldr r2, =latest
	str r1, [r2]
	movs r1, #0
	str r1, [r0]
        push_tos
	ldr tos, =finalize_hook
	ldr tos, [tos]
	bl _execute_nz
        ldr r0, =current_unit_start
        movs r1, #0
        str r1, [r0]
	pop {pc}
	end_inlined

	## Compile the end of a word
	define_internal_word "end-compile,", visible_flag
_asm_end:
	push {lr}
	bl _asm_undefer_lit
        ldr r0, =word_exit_hook
        ldr r0, [r0]
        cmp r0, #0
        beq 1f
        movs r1, #1
        orrs r0, r1
        blx r0
1:	ldr r0, =word_end_hook
        ldr r0, [r0]
        cmp r0, #0
        beq 2f
        movs r1, #1
        orrs r0, r1
        blx r0
2:      bl _asm_undefer_lit
	push_tos
	ldr tos, =0xBD00	## pop {pc}
	bl _current_comma_2
	push_tos
	ldr tos, =0x003F        ## movs r7, r7
	bl _current_comma_2
	bl _asm_finalize
	pop {pc}
	end_inlined

	## End flash compression
	define_word "end-compress-flash", visible_flag
_asm_end_compress_flash:
	push {lr}
	bl _asm_undefer_lit
	ldr r0, =compress_flash_enabled
	ldr r1, [r0]
	cmp r1, #0
	beq 1f
	movs r1, #0
	str r1, [r0]
	bl _asm_word_align
	push_tos
	ldr r0, =flash_latest
	ldr tos, [r0]
	bl _flash_comma_4
	push_tos
	ldr tos, =0xDEADBEEF
	bl _flash_comma_4
	bl _flash_block_align
1:	pop {pc}
	end_inlined

	## Commit code to flash without finishing compressing it
	define_word "commit-flash", visible_flag
_asm_commit_flash:
	push {lr}
	bl _asm_undefer_lit
	ldr r0, =compress_flash_enabled
	ldr r1, [r0]
	cmp r1, #0
	beq 1f
	bl _asm_word_align
	bl _flash_block_align
1:	pop {pc}
	end_inlined

	## Assemble a move immediate instruction
	define_internal_word "mov-imm,", visible_flag
_asm_mov_imm:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, #7
	ands r0, r1
	movs r1, #0xFF
	ands tos, r1
	lsls r0, r0, #8
	orrs tos, r0
	ldr r0, =0x2000
	orrs tos, r0
	bl _current_comma_2
	pop {pc}
	end_inlined

	## Assemble an reverse subtract immediate from zero instruction
	define_internal_word "neg,", visible_flag
_asm_neg:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, #7
	ands tos, r1
	ands r0, r1
	lsls tos, tos, #3
	orrs tos, r0
	ldr r0, =0x4240
	orrs tos, r0
	bl _current_comma_2
	pop {pc}
	end_inlined

	## Compile a blx (register) instruction
	define_internal_word "blx-reg,", visible_flag
_asm_blx_reg:
	push {lr}
	movs r0, #0xF
	ands tos, r0
	lsls tos, tos, #3
	ldr r0, =0x4780
	orrs tos, r0
	bl _current_comma_2
	pop {pc}
	end_inlined
	
	## Compile an unconditional branch
        ## ( branch-addr -- )
	define_internal_word "branch,", visible_flag
_asm_branch:
        push ra
        call _current_here
        lc x15, 0(dp)
        sub tos, x15, tos
        li x15, -0x800
        blt tos, x15, 1f
        li x15, 0x7FF
        blt x15, tos, 1f
        call _asm_c_j
        j 2f
1:      li x15, -0x100000
        blt tos, x15, 3f
        li x15, 0xFFFFF
        blt x15, tos, 3f
        push_tos
        li tos, 0
        call _asm_build_jal
        call _current_comma_4
2:      pull_tos
        pop ra
        ret
3:      li tos, _out_of_range_branch
        call _raise
        ret # Dummy instruction
	end_inlined

	## Compile a branch on equal to zero
        # ( branch-dest reg -- )
	define_internal_word "0branch,", visible_flag
_asm_branch_zero:
        push ra
        call _current_here
        call _over
        call _asm_q_c_reg
        beq tos, zero, 1f
        pull_tos
        lc x15, cell(dp)
        sub tos, x15, tos
        li x15, -0x100
        blt tos, x15, 2f
        li x15, 0xFF
        blt x15, tos, 2f
        call _swap
        call _asm_to_c_reg
        call _asm_build_c_beqz
        call _current_comma_2
        j 3f
1:      pull_tos
        lc x15, cell(dp)
        sub tos, x15, tos
2:      li x15, -0x1000
        blt tos, x15, 4f
        li x15, 0xFFF
        blt x15, tos, 4f
        call _swap
        call _asm_build_beq_zero
        call _current_comma_4
3:      pull_tos
        pop ra
        ret
4:      li tos, _out_of_range_branch
        call _raise
        ret # Dummy instruction
        end_inlined

	## Compile a back-referenced unconditional branch
        ## ( branch-dest addr -- )
	define_internal_word "branch-back!", visible_flag
_asm_branch_back:
        push ra
        call _current_here
        lc x15, cell(dp)
        sub tos, x15, tos
        li x15, -0x100000
        blt tos, x15, 1f
        li x15, 0xFFFFF
        blt x15, tos, 1f
        push_tos
        li tos, 0
        call _asm_build_jal
        call _swap
        call _store_current_4
        pull_tos
        pop ra
        ret
1:      li tos, _out_of_range_branch
        call _raise
        ret # Dummy instruction
	end_inlined

	## Compile a back-referenced branch on equal to zero
        ## ( branch-dest reg addr -- )
	define_internal_word "0branch-back!", visible_flag
_asm_branch_zero_back:
        push ra
        call _current_here
        lc x15, 2*cell(dp)
        sub tos, x15, tos
        li x15, -0x1000
        blt tos, x15, 1f
        li x15, 0xFFF
        blt x15, tos, 1f
        push_tos
        lc tos, 2*cell(dp)
        call _swap
        call _build_beq_zero
        call _swap
        call _store_current_4
        lc tos, 2*cell(dp)
        addi dp, dp, 2*cell
        pop ra
        ret
1:      li tos, _out_of_range_branch
        call _raise
        ret # Dummy instruction
	end_inlined

	## Extract the value of a constant
	define_internal_word "extract-constant", visible_flag
_asm_extract_constant:
	push {lr}
	ldrh r0, [tos]
	ldr r1, =0xB500
	cmp r0, r1
	beq 1f
3:	movs tos, #0
	push_tos
	pop {pc}
1:	adds tos, #2
	ldrh r0, [tos]
	ldr r1, =0xF847
	cmp r0, r1
	bne 3b
	adds tos, #2
	ldrh r0, [tos]
	ldr r1, =0x6D04
	cmp r0, r1
	bne 3b
	adds tos, #2
	ldrh r0, [tos]
	ldr r1, =0xFF00
	movs r2, r0
	ands r2, r1
	ldr r1, =0x2600
	cmp r2, r1
	beq 2f
	ldr r1, =0xFBF0
	movs r2, r0
	ands r2, r1
	ldr r1, =0xF240
	cmp r2, r1
	bne 3b
	movs r2, r0
	movs r1, #0xF
	ands r2, r1
	lsrs r0, r0, #10
	movs r1, #1
	ands r0, r1
	adds tos, #2
	ldrh r3, [tos]
	ldr r1, =0x8F00
	movs r4, r3
	ands r4, r1
	ldr r1, =0x0600
	cmp r4, r1
	bne 3b
	lsls r2, r2, #12
	lsls r0, r0, #11
	orrs r2, r0
	ldr r1, =0x7000
	movs r4, r3
	ands r4, r1
	lsrs r4, r4, #4
	orrs r2, r4
	ldr r1, =0x00FF
	movs r4, r3
	ands r4, r1
	orrs r4, r2
	adds tos, #2
	ldrh r0, [tos]
	ldr r1, =0xBD00
	cmp r0, r1
	beq 5f
	ldr r1, =0xFBF0
	movs r2, r0
	ands r2, r1
	ldr r1, =0xF2C0
	cmp r2, r1
	bne 3b
	movs r2, r0
	movs r1, #0xF
	ands r2, r1
	lsrs r0, r0, #10
	movs r1, #1
	ands r0, r1
	adds tos, #2
	ldrh r3, [tos]
	ldr r1, =0x8F00
	movs r5, r3
	ands r5, r1
	ldr r1, =0x0600
	cmp r5, r1
	bne 3b
	lsls r2, r2, #12
	lsls r0, r0, #11
	orrs r2, r0
	ldr r1, =0x7000
	movs r5, r3
	ands r5, r1
	lsrs r5, r5, #4
	orrs r2, r5
	ldr r1, =0x00FF
	movs r5, r3
	ands r5, r1
	orrs r5, r2
	lsls r0, r5, #16
	orrs r0, r4
	b 4f
2:	ldr r1, =0x00FF
	ands r0, r1
4:	adds tos, #2
	ldrh r2, [tos]
	ldr r1, =0xBD00
	cmp r2, r1
	bne 3b
	movs tos, r0
	push_tos
	ldr tos, =-1
	pop {pc}
5:	movs tos, r4
	push_tos
	ldr tos, =-1
	pop {pc}
	end_inlined

	## This only folds words in M0
	define_internal_word "fold,", visible_flag
_asm_fold:
	b _asm_inline
	bx lr
	end_inlined

	## Inline a word
	define_internal_word "inline,", visible_flag
_asm_inline:
	push {lr}
	push_tos
	bl _asm_extract_constant
	cmp tos, #0
	beq 1f
	pull_tos
	bl _asm_undefer_lit
	ldr r0, =-1
	ldr r1, =literal_deferred_q
	str r0, [r1]
	ldr r1, =deferred_literal
	str tos, [r1]
	adds dp, #4
	pull_tos
	pop {pc}	
1:	adds dp, #4
	pull_tos
	ldr r1, =literal_deferred_q
	ldr r0, [r1]
	cmp r0, #0
	bne 1f
	bl _asm_do_inline
	pop {pc}
1:	ldr r0, =_add
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_add
	pop {pc}
1:	ldr r0, =_sub
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_sub
	pop {pc}
1:	ldr r0, =_mul
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_mul
	pop {pc}
1:	ldr r0, =_div
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_div
	pop {pc}
1:	ldr r0, =_udiv
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_udiv
	pop {pc}
1:	ldr r0, =_and
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_and
	pop {pc}
1:	ldr r0, =_or
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_or
	pop {pc}
1:	ldr r0, =_xor
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_xor
	pop {pc}
1:	ldr r0, =_lshift
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_lshift
	pop {pc}
1:	ldr r0, =_rshift
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_rshift
	pop {pc}
1:	ldr r0, =_arshift
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_arshift
	pop {pc}
1:	ldr r0, =_store_1
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_store_1
	pop {pc}
1:	ldr r0, =_store_2
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_store_2
	pop {pc}
1:	ldr r0, =_store_4
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_store_4
	pop {pc}
1:	ldr r0, =_pick
	cmp tos, r0
	bne 1f
	pull_tos
	bl _asm_fold_pick
	pop {pc}
1:	bl _asm_undefer_lit
	bl _asm_do_inline
	pop {pc}
	end_inlined

	## Constant fold +
	define_internal_word "fold+", visible_flag
_asm_fold_add:
	push {lr}
	ldr r0, =deferred_literal
	ldr r1, [r0]
	ldr r2, =255
	cmp r1, r2
	bgt 2f
	cmp r1, #0
	blt 1f
	push_tos
	movs tos, r1
	push_tos
	movs tos, #6
	bl _asm_add_imm
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
1:	mvns r3, r1
	adds r3, #1
	cmp r3, r2
	bhi 2f
	push_tos
	movs tos, r3
	push_tos
	movs tos, #6
	bl _asm_sub_imm
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
2:	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x1836
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold -
	define_internal_word "fold-", visible_flag
_asm_fold_sub:
	push {lr}
	ldr r0, =deferred_literal
	ldr r1, [r0]
	ldr r2, =255
	cmp r1, r2
	bgt 2f
	cmp r1, #0
	blt 1f
	push_tos
	movs tos, r1
	push_tos
	movs tos, #6
	bl _asm_sub_imm
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
1:	mvns r3, r1
	adds r3, #1
	cmp r3, r2
	bhi 2f
	push_tos
	movs tos, r3
	push_tos
	movs tos, #6
	bl _asm_add_imm
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
2:	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x1A36
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold *
	define_internal_word "fold*", visible_flag
_asm_fold_mul:
	push {lr}
	push_tos
	ldr r0, =deferred_literal
	ldr tos, [r0]
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x4346
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold /
	define_internal_word "fold/", visible_flag
_asm_fold_div:
	push {lr}
	push_tos
	ldr r0, =deferred_literal
	ldr tos, [r0]
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0xFB96
	bl _current_comma_2
	push_tos
	ldr tos, =0xF6F0
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold u/
	define_internal_word "foldu/", visible_flag
_asm_fold_udiv:
	push {lr}
	push_tos
	ldr r0, =deferred_literal
	ldr tos, [r0]
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0xFBB6
	bl _current_comma_2
	push_tos
	ldr tos, =0xF6F0
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold AND
	define_internal_word "fold-and", visible_flag
_asm_fold_and:
	push {lr}
	ldr r0, =deferred_literal
	ldr r1, [r0]
	ldr r2, =255
	cmp r1, r2
	bhi 1f
	push_tos
	ldr tos, =0xF006
	push {r1}
	bl _current_comma_2
	pop {r1}
	push_tos
	ldr tos, =0x0600
	orrs tos, r1
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
1:	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x4006
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold OR
	define_internal_word "fold-or", visible_flag
_asm_fold_or:
	push {lr}
	ldr r0, =deferred_literal
	ldr r1, [r0]
	ldr r2, =255
	cmp r1, r2
	bhi 1f
	push_tos
	ldr tos, =0xF046
	push {r1}
	bl _current_comma_2
	pop {r1}
	push_tos
	ldr tos, =0x0600
	orrs tos, r1
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
1:	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x4306
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold XOR
	define_internal_word "fold-xor", visible_flag
_asm_fold_xor:
	push {lr}
	ldr r0, =deferred_literal
	ldr r1, [r0]
	ldr r2, =255
	cmp r1, r2
	bhi 1f
	push_tos
	ldr tos, =0xF086
	push {r1}
	bl _current_comma_2
	pop {r1}
	push_tos
	ldr tos, =0x0600
	orrs tos, r1
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
1:	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x4046
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold LSHIFT
	define_internal_word "fold-lshift", visible_flag
_asm_fold_lshift:
	push {lr}
	ldr r0, =deferred_literal
	ldr r1, [r0]
	ldr r2, =31
	cmp r1, r2
	bhi 1f
	push_tos
	ldr tos, =0x0036
	lsls r1, #6
	orrs tos, r1
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
1:	push_tos
	movs tos, #0
	push_tos
	movs tos, #6
	bl _asm_mov_imm
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold RSHIFT
	define_internal_word "fold-rshift", visible_flag
_asm_fold_rshift:
	push {lr}
	ldr r0, =deferred_literal
	ldr r1, [r0]
	ldr r2, =31
	cmp r1, r2
	bhi 1f
	push_tos
	ldr tos, =0x0836
	lsls r1, #6
	orrs tos, r1
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
1:	push_tos
	movs tos, #0
	push_tos
	movs tos, #6
	bl _asm_mov_imm
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold ARSHIFT
	define_internal_word "fold-arshift", visible_flag
_asm_fold_arshift:
	push {lr}
	ldr r0, =deferred_literal
	ldr r1, [r0]
	ldr r2, =32
	cmp r1, r2
	blo 1f
	movs r1, #31
1:	push_tos
	ldr tos, =0x1036
	lsls r1, #6
	orrs tos, r1
	bl _current_comma_2
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold B!
	define_internal_word "fold-c!", visible_flag
_asm_fold_store_1:
	push {lr}
	push_tos
	ldr r0, =deferred_literal
	ldr tos, [r0]
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x7006
	bl _current_comma_2
	push_tos
	movs tos, #6
	bl _asm_pull
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold H!
	define_internal_word "fold-h!", visible_flag
_asm_fold_store_2:
	push {lr}
	push_tos
	ldr r0, =deferred_literal
	ldr tos, [r0]
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x8006
	bl _current_comma_2
	push_tos
	movs tos, #6
	bl _asm_pull
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold !
	define_internal_word "fold-!", visible_flag
_asm_fold_store_4:
	push {lr}
	push_tos
	ldr r0, =deferred_literal
	ldr tos, [r0]
	push_tos
	movs tos, #0
	bl _asm_literal
	push_tos
	ldr tos, =0x6006
	bl _current_comma_2
	push_tos
	movs tos, #6
	bl _asm_pull
	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
	end_inlined

	## Constant fold PICK
	define_internal_word "fold-pick", visible_flag
_asm_fold_pick:
	push {lr}
	ldr r0, =deferred_literal
	ldr r0, [r0]
	cmp r0, #0x1F
	bhi 1f
	push_tos
	movs tos, #6
	push {r0}
	bl _asm_push
	pop {r0}
	cmp r0, #0
	beq 2f
	push_tos
	lsls tos, r0, #2
	push_tos
	movs tos, #7
	push_tos
	movs tos, #6
	bl _asm_ldr_imm
2:	ldr r1, =literal_deferred_q
	movs r2, #0
	str r2, [r1]
	pop {pc}
1:	bl _asm_undefer_lit
	push_tos
	ldr tos, =_pick
	bl _asm_do_inline
	pop {pc}
	end_inlined
	
	## Actually inline a word
	define_internal_word "do-inline,", visible_flag
_asm_do_inline:
	push {lr}
	ldrh r0, [tos]
	ldr r1, =0xB500
	cmp r0, r1
	bne 1f
	adds tos, #2
1:	ldrh r0, [tos]
	ldr r1, =0xBD00
	cmp r0, r1
	beq 3f
	ldr r1, =0x4770
	cmp r0, r1
	beq 3f
2:	movs r1, tos
	push_tos
	movs tos, r0
	bl _current_comma_2
	adds tos, #2
	b 1b
3:	ldrh r2, [tos, #2]
	ldr r1, =0x003F
	cmp r2, r1
	bne 2f
	pull_tos
	pop {pc}
	end_inlined

	## Call a word at an address
	define_internal_word "call,", visible_flag
_asm_call:	
	push {lr}
	bl _asm_undefer_lit
	movs r0, #-1
	ldr r1, =suppress_inline
	str r0, [r1]
	bl _current_here
	movs r0, tos
	pull_tos
	movs r1, tos
	subs tos, tos, r0
	ldr r2, =0x00FFFFFF
	cmp tos, r2
	bgt 1f
	ldr r2, =0xFF000000
	cmp tos, r2
	blt 1f
	bl _asm_bl
	pop {pc}
1:	movs tos, r1
	adds tos, #1
	push_tos
	movs tos, #1
	bl _asm_literal
	push_tos
	movs tos, #1
	bl _asm_blx_reg
	pop {pc}
	end_inlined
	
	## Undefer a literal
	define_word "undefer-lit", visible_flag
_asm_undefer_lit:
	push {lr}
	ldr r1, =literal_deferred_q
	ldr r0, [r1]
	cmp r0, #0
	beq 1f
	push_tos
	movs tos, #6
	push {r1}
	bl _asm_push
	push_tos
	ldr r0, =deferred_literal
	ldr tos, [r0]
	push_tos
	movs tos, #6
	bl _asm_literal
	pop {r1}
	movs r0, #0
	str r0, [r1]
1:	pop {pc}
	end_inlined

	## Reserve space for a literal
        ## ( -- addr )
	define_internal_word "reserve-literal", visible_flag
_asm_reserve_literal:
        j _current_reserve_double
        ret # Dummy instruction
	end_inlined

	## Store a literal ( x reg addr -- )
	define_internal_word "literal!", visible_flag
_asm_store_literal:
        push ra
        lc x15, cell(dp)
        push_tos
        mv tos, x15
        call _asm_adjust_upper
        push_tos
        lc tos, 2*cell(dp)
        call _asm_build_lui
        call _over
        call _store_current_4
        addi dp, dp, -3*cell
        sc tos, 2*cell(dp)
        lc tos, 4*cell(dp)
        sc tos, cell(dp)
        lc tos, 3*cell(dp)
        sc tos, 0(dp)
        call _asm_build_addi
        call _swap
        addi tos, tos, 4
        call _store_current_4
        lc tos, 2*cell(dp)
        addi dp, dp, 2*cell
        pop ra
        ret
	end_inlined

	## Reserve space for a branch
        ## ( -- addr )
	define_internal_word "reserve-branch", visible_flag
_asm_reserve_branch:
        j _current_reserve_4
        ret # Dummy instruction
	end_inlined

	## Out of range branch exception
	define_internal_word "x-out-of-range-branch", visible_flag
_out_of_range_branch:
        push ra
	string_ln "out of range branch"
	call _type
	pop ra
        ret
        end_inlined

	## Already building exception
	define_internal_word "x-already-building", visible_flag
_already_building:
        push ra
	string_ln "already building"
	call _type
	pop ra
        ret
	end_inlined

	## Not building exception
	define_internal_word "x-not-building", visible_flag
_not_building:
	push ra
	string_ln "not building"
	call _type
	pop ra
        ret
	end_inlined

	## Word-align an address
	define_word "word-align,", visible_flag
_asm_word_align:
        push ra
        call _current_here
        andi tos, tos, 2
        beq tos, zero, 1f
        li tos, 1 # C.NOP
        call _current_comma_2
        j 2f
1:      pull_tos
2:      pop ra
        ret
        end_inlined
        
