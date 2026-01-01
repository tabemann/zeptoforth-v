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

# Without this make can start in the wrong source directory
.OBJDIR: ./

export TOOLCHAIN?=riscv64-linux-gnu
export IDIR=src/include
export AS=$(TOOLCHAIN)-as
export LD=$(TOOLCHAIN)-ld
export COPY=$(TOOLCHAIN)-objcopy
export DUMP=$(TOOLCHAIN)-objdump
export ASFLAGS=-g
export PREFIX=/usr/local
export PLATFORM=rp2350
export VERSION=0.0.1-dev

KERNEL_INFO=src/common/kernel_info.s

all: rp2350 rp2350_16mib rp2350_1core rp2350_1core_16mib

install:
	$(MAKE) -C src/rp2350 install
	$(MAKE) -C src/rp2350_16mib install
	$(MAKE) -C src/rp2350_1core install
	$(MAKE) -C src/rp2350_1core_16mib install

rp2350:
	$(MAKE) -C src/rp2350

rp2350_16mib:
	$(MAKE) -C src/rp2350_16mib

rp2350_1core:
	$(MAKE) -C src/rp2350_1core

rp2350_1core_16mib:
	$(MAKE) -C src/rp2350_1core_16mib

.PHONY: all install rp2350 rp2350_16mib rp2350_1core rp2350_1core_16mib clean html epub

html:
	cd docs ; sphinx-build -b html . ../html

epub:
	cd docs ; sphinx-build -b epub . ../epub

clean:
	$(MAKE) -C src/rp2350 clean
	$(MAKE) -C src/rp2350_16mib clean
	$(MAKE) -C src/rp2350_1core clean
	$(MAKE) -C src/rp2350_1core_16mib clean
	$(MAKE) -C src/common clean
