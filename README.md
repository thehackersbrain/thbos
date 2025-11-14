# THBOS

A minimal x86 operating system that displays CPU information using the CPUID instruction.

![THBOS Boot Demo](screenshots/cover.gif)

## Features

- Boots via GRUB using Multiboot specification
- VGA text mode display with color support
- Screen scrolling implementation
- CPUID instruction wrapper
- Displays CPU vendor, family, model, stepping
- Shows processor feature flags (SSE, AVX, etc.)
- Binary and hexadecimal number formatting

## Technical Details

### Architecture

- **Target**: x86 (32-bit protected mode)
- **Bootloader**: GRUB (Multiboot 0.6.96)
- **Display**: VGA text mode at 0xB8000
- **Memory**: 1MB kernel load address, 16KB stack

### Key Improvements Over Original

- Here's the previous repo [cpuinfo-os](https://github.com/thehackersbrain/cpuinfo-os)

1. Fixed VGA buffer size (2000 vs 2200)
2. Proper screen scrolling instead of clearing
3. Corrected bit masking in CPUID parsing
4. Fixed CPUID inline assembly with proper constraints
5. Added CPUID availability check
6. Displays CPU vendor string (leaf 0x00)
7. Shows ECX feature flags (SSE3, AVX, AES, etc.)
8. Added hexadecimal printing function
9. Fixed binary printing for zero values
10. Increased stack from 4KB to 16KB
11. Added zig in the mix for additional or expermental things
12. Added `-fno-omit-frame-pointer` flag for better debugging
13. Added `.gdbinit` file for quicker and easier debugging with gdb

## Requirements

- GCC (with 32-bit support)
- GNU Binutils (as, ld)
- GRUB utilities (grub-mkrescue)
- QEMU (for testing)
- xorriso (dependency for grub-mkrescue)
- zig (for experimental things)

### Ubuntu/Debian

```bash
sudo apt install build-essential gcc-multilib grub-pc-bin xorriso qemu-system-x86 qemu-ui zig
```

### Arch Linux

```bash
sudo pacman -S base-devel grub xorriso qemu-arch-extra qemu-ui-sdl zig
```

## Building

### Using Make (recommended)

```bash
make            # Build ISO
make run        # Build and run in QEMU
make clean      # Clean build artifacts
make debug      # Run with GDB debugging
```

### Manual Build

```bash
# Assemble bootloader
as --32 src/bootloader/boot.s -o build/boot.o

# Compile kernel
gcc -m32 -c src/kernel/kernel.c -o build/kernel.o -ffreestanding -O2 -Wall -Wextra

# compiling zig objects
zig build-obj -target x86-freestanding -O ReleaseFast build/zigtest/hello.zig -femit-bin=build/hello.o

# Link
ld -m elf_i386 -T src/linker/linker.ld -o build/THBOS.bin build/boot.o build/kernel.o build/hello.o

# Create ISO
mkdir -p build/isodir/boot/grub
cp build/THBOS.bin build/isodir/boot/
cp src/bootloader/grub.cfg build/isodir/boot/grub/
grub-mkrescue -o THBOS.iso build/isodir
```

## Running

### QEMU

```bash
qemu-system-x86_64 -cdrom THBOS.iso -m 512M -display sdl
```

### VirtualBox

1. Create new VM (Type: Other, Version: Other/Unknown)
2. Disable EFI
3. Mount THBOS.iso as CD
4. Boot

### Real Hardware

Write ISO to USB:

```bash
sudo dd if=THBOS.iso of=/dev/sdX bs=4M status=progress
```

## Code Structure

```bash
.
├── Makefile              # Build automation
├── README.md
└── src
    ├── bootloader
    │   ├── boot.s        # Assembly bootloader
    │   └── grub.cfg      # GRUB configuration
    ├── kernel
    │   ├── kernel.c      # Main kernel code
    │   └── kernel.h      # Type definitions and declarations
    ├── linker
    │   └── linker.ld     # Linker script
    └── zigtest
        └── hello.zig     # zig files (in testing)
```

## Memory Layout

```bash
0x00000000 - 0x000FFFFF: Real mode area (1MB)
0x00100000:              Kernel load address
0xB8000:                 VGA text buffer
```

## VGA Text Mode

- Resolution: 80×25 characters
- Format: 16-bit per character
  - Bits 0-7: ASCII character
  - Bits 8-11: Foreground color
  - Bits 12-15: Background color

## CPUID Information Displayed

### Leaf 0x00 (Basic Info)

- CPU vendor string (GenuineIntel, AuthenticAMD, etc.)
- Maximum supported CPUID leaf

### Leaf 0x01 (Features)

- **EAX**: Stepping, Model, Family IDs
- **EBX**: Brand index, Cache line size, APIC ID
- **ECX**: SSE3, SSSE3, SSE4.1/4.2, AES, AVX, etc.
- **EDX**: FPU, VME, TSC, MSR, PAE, MMX, SSE, SSE2, etc.

## Debugging

### With GDB

```bash
# Terminal 1
qemu-system-i386 -cdrom build/THBOS.iso -m 512M -s -S

# Terminal 2
gdb build/THBOS.bin
(gdb) target remote localhost:1234
(gdb) break kernel_entry
(gdb) continue
```

### 🚀 GDB Debugging Shortcuts

THBoS provides a set of custom GDB shortcut commands (auto-loaded from `.gdbinit`) to make kernel debugging faster and more intuitive.
These commands are designed for low-level OS development and work seamlessly with QEMU’s `-s -S` debug stub.

#### 🔧 Loading the Debug Environment

Start QEMU:

```sh
qemu-system-i386 -kernel build/THBOS.bin -m 512M -s -S
```

Start GDB:

```sh
gdb build/THBOS.bin
```

The custom `.gdbinit` in this project is auto-loaded and provides the commands documented below.

| Command       | Description                                                      |
| ------------- | ---------------------------------------------------------------- |
| `regs`        | Displays all CPU registers.                                      |
| `here`        | Shows execution context: EIP, ESP, EBP, and nearby instructions. |
| `code`        | Disassembles instructions around the current EIP.                |
| `stack`       | Dumps raw stack memory starting from `$esp`.                     |
| `frame`       | Prints the EBP frame: locals, args, and return address.          |
| `snap`        | Full system snapshot (registers + stack + instructions).         |
| `pg <addr>`   | Dumps a full 4KB page from the given address.                    |
| `dump <addr>` | Hexdump of 128 bytes at the address.                             |
| `s1`          | Step 1 CPU instruction.                                          |
| `s10`         | Step 10 CPU instructions.                                        |
| `s100`        | Step 100 CPU instructions.                                       |
| `runk`        | Breaks at `panic()` and continues execution.                     |

---

## 📝 Notes

- Add this: `set auto-load safe-path /` into your `~/.config/gdb/gdbinit` file
- These shortcuts only work when GDB loads the project’s `.gdbinit`.
- The kernel must be run with `qemu-system-i386` to avoid architecture mismatches.

---

### QEMU Monitor

```bash
qemu-system-x86_64 -cdrom THBOS.iso -monitor stdio
```

## Known Limitations

- No interrupt handling (IDT)
- No keyboard input
- No disk I/O
- Uses GRUB's GDT (no custom GDT)
- No memory management
- Single-threaded
- No floating point support

## Future Enhancements

1. IDT setup with interrupt handlers
2. Keyboard driver (IRQ1)
3. Timer (PIT) for scheduling
4. Custom GDT
5. Memory management (paging)
6. Shell interface
7. Extended CPUID leaves (cache info, thermal, etc.)
8. PCI device enumeration

## References

- [Intel® 64 and IA-32 Architectures Software Developer's Manual](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [OSDev Wiki](https://wiki.osdev.org/)
- [Multiboot Specification](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html)
