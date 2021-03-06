CC_ASM = nasm
CC_CPP = g++ 
CC_C = gcc

ASM_Flags = -f elf32
C_Flags = -fno-stack-protector -w -std=c99 -fno-builtin -m32 $(EXTRA)
CPP_Flags = -m32 -ffreestanding -O2 -Wall -Wextra -fno-builtin -fno-exceptions -fno-rtti $(EXTRA)
LNK_Flags = -m elf_i386 

SOURCEDIR = src
BUILDDIR = build
EXECUTABLEDIR = bin

C_SOURCES = $(wildcard $(SOURCEDIR)/**/*.c)
CPP_SOURCES = $(wildcard $(SOURCEDIR)/**/*.cpp)
ASM_SOURCES = $(wildcard $(SOURCEDIR)/**/*.s)

C_OBJECTS = $(C_SOURCES:.c=.o)
CPP_OBJECTS = $(CPP_SOURCES:.cpp=.o)
ASM_OBJECTS = $(ASM_SOURCES:.s=.o)

EXECUTABLE = FluxOS.bin

all: init compile create_grub

compile: $(C_OBJECTS) $(CPP_OBJECTS) $(ASM_OBJECTS)
	@echo "Linking the Object files..."
	@ld -T linker.ld $(LNK_Flags) $(foreach file,$(^F),$(BUILDDIR)/$(file)) -o $(EXECUTABLEDIR)/$(EXECUTABLE) 

debug: all
	objcopy --only-keep-debug $(EXECUTABLEDIR)/$(EXECUTABLE) $(BUILDDIR)/kernel.sym

.cpp.o:
	@echo "Compiling C++ File" $<
	$(CC_CPP) $(CPP_Flags) -c $< -o $(BUILDDIR)/$(@F)

.c.o:
	@echo "Compiling C File" $< 
	@$(CC_C) $(C_Flags) -c $< -o $(BUILDDIR)/$(@F) 

.s.o:
	@echo "Compiling Assembly File" $<
	@$(CC_ASM) $(ASM_Flags) $< -o $(BUILDDIR)/$(@F)

init:
	@echo "Creating Build Directories" $<
	@mkdir -p $(BUILDDIR)
	@mkdir -p $(EXECUTABLEDIR)

create_grub:
	@echo "Creating Bootable Image" $<
	@mkdir -p $(BUILDDIR)/isodir/boot/grub
	@cp $(EXECUTABLEDIR)/$(EXECUTABLE) $(BUILDDIR)/isodir/boot/myos.bin
	@cp grub.cfg $(BUILDDIR)/isodir/boot/grub/grub.cfg
	grub-mkrescue -o myos.iso $(BUILDDIR)/isodir

run:
	@echo "Running..." $<
	@qemu-system-i386 -cdrom myos.iso

run_debug:
	@echo "Running in Debug Mode..." $<
	@qemu-system-i386 -s -S -cdrom myos.iso

clean:
	@echo "Cleaning Build Directories and Files..." $<
	@rm -R -f $(BUILDDIR)
	@rm -R -f $(EXECUTABLEDIR)

