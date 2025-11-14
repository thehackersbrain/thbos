# boot.s - Bootloader assembly code

.section .text

# Multiboot header
.align 4
.long 0x1BADB002           # MAGIC
.long 0x0                  # FLAGS
.long -(0x1BADB002 + 0x0)  # CHECKSUM

# Kernel entry point
.global _start
.type _start, @function

_start:
    cli

    # --- NEW BSS CLEARING LOOP (Byte-by-Byte) ---
    mov $bss_start, %edi      # Get start of .bss
    mov $bss_end, %ecx        # Get end of .bss
    sub %edi, %ecx            # Calculate size of .bss in bytes
    
    xor %eax, %eax            # Set EAX to 0 (AL will be 0)
    cld                       # Clear direction flag (so stosb increments EDI)
    
    # rep stosb: Store AL (0) at [EDI], increment EDI, repeat ECX times
    rep stosb                 
    # --- END BSS CLEARING LOOP ---

    # Now we can safely set up the stack (which is inside .bss)
    mov $stackTop, %esp
    
    # And call our C kernel
    call kernel_entry

halt:
    hlt
    jmp halt

.size _start, . - _start

# Stack - increased to 16KB
# This is in .bss and will be cleared by the loop above
.section .bss
.align 16
stackBottom:
    .skip 16384
stackTop:
