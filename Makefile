# === Build configuration ===
AS       := as
CC       := gcc
LD       := ld
ASFLAGS  := --32
CFLAGS   := -m32 -ffreestanding -O0 -Wall -Wextra -fno-stack-protector -nostdlib
LDFLAGS  := -m elf_i386 -T src/linker/linker.ld

BOOT_DIR   := src/bootloader
KERNEL_DIR := src/kernel
LINKER_DIR := src/linker

BUILD_DIR  := build
ISO_DIR    := $(BUILD_DIR)/isodir
OBJ_DIR    := $(BUILD_DIR)/obj
OBJECTS := $(OBJ_DIR)/boot.o $(OBJ_DIR)/kernel.o
BINARY  := $(BUILD_DIR)/THBOS.bin
ISO     := $(BUILD_DIR)/THBOS.iso

.PHONY: all clean run debug dirs

# === Targets ===
all: $(ISO)

# Ensure build directories exist
dirs:
	@mkdir -p $(OBJ_DIR) $(ISO_DIR)/boot/grub

# === Assembly and Compilation ===
$(OBJ_DIR)/boot.o: $(BOOT_DIR)/boot.s | dirs
	$(AS) $(ASFLAGS) $< -o $@

$(OBJ_DIR)/kernel.o: $(KERNEL_DIR)/kernel.c $(KERNEL_DIR)/kernel.h | dirs
	$(CC) $(CFLAGS) -c $< -o $@

# === Linking ===
$(BINARY): $(OBJECTS) $(LINKER_DIR)/linker.ld | dirs
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

# === ISO Creation ===
$(ISO): $(BINARY) $(BOOT_DIR)/grub.cfg | dirs
	cp $(BINARY) $(ISO_DIR)/boot/
	cp $(BOOT_DIR)/grub.cfg $(ISO_DIR)/boot/grub/
	grub-mkrescue -o $(ISO) $(ISO_DIR)

# === Run and Debug ===
run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO) -m 512M -display sdl

debug: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO) -m 512M -s -S &
	sleep 1
	gdb $(BINARY) -ex "target remote localhost:1234"

# === Clean ===
clean:
	rm -rf $(BUILD_DIR)