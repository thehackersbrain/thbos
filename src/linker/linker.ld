ENTRY(_start)

/* Set the base load address for the kernel */
. = 0x00100000;

SECTIONS
{
  /* Put all code (including the header and _start) here */
  .text ALIGN(4K) : {
    *(.text*)
  }

  .rodata ALIGN(4K) : {
    *(.rodata*)
  }

  .data ALIGN(4K) : {
    *(.data*)
  }

  /* .bss section MUST be defined for the clear loop to work */
  .bss ALIGN(4K) : {
    bss_start = .;    /* Defines the bss_start symbol */
    *(.bss*)
    *(COMMON)
    bss_end = .;      /* Defines the bss_end symbol */
  }
  
  kernel_end = .;
}
