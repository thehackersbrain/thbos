#include "kernel.h"

// index for video buffer array
uint32 vga_index;

// counter to store new lines
static uint32 next_line_index = 1;

// fore & back color values
uint8 g_fore_color = WHITE, g_back_color = BLUE;

// digit ascii code for printing integers
int digit_ascii_codes[10] = {0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39};

// 16 bit video buffer elements(register ax)
// 8 bits(ah) higher :
//  lower 4 bits - fore color
//  higher 4 bits - back color
//
// 8 bits(al) lower :
//  8 bits : ASCII character to print
//

uint16 vga_entry(unsigned char ch, uint8 fore_color, uint8 back_color) {
  uint16 ax = 0;
  uint8 ah = 0, al = 0;

  ah = back_color;
  ah <<= 4;
  ah |= fore_color;
  ax = ah;
  ax <<= 8;
  al = ch;
  ax |= al;

  return ax;
}

// clear video buffer array
void clear_vga_buffer(uint16 **buffer, uint8 fore_color, uint8 back_color) {
  uint32 i;
  for (i = 0; i < BUFSIZE; i++) {
    (*buffer)[i] = vga_entry(NULL, fore_color, back_color);
  }
  next_line_index = 1;
  vga_index = 0;
}

// Initialize vga buffer
void init_vga(uint8 fore_color, uint8 back_color) {
  vga_buffer = (uint16*)VGA_ADDRESS;
  clear_vga_buffer(&vga_buffer, fore_color, back_color);
  g_fore_color = fore_color;
  g_back_color = back_color;
}

// Scroll screen up by one line
void scroll_up() {
  uint32 i;
  // Move all lines up
  for (i = 0; i < BUFSIZE - VGA_WIDTH; i++) {
    vga_buffer[i] = vga_buffer[i + VGA_WIDTH];
  }
  // Clear last line
  for (i = BUFSIZE - VGA_WIDTH; i < BUFSIZE; i++) {
    vga_buffer[i] = vga_entry(NULL, g_fore_color, g_back_color);
  }
}

// Increase vga_index by width of row(80)
void print_new_line() {
  if (next_line_index >= VGA_HEIGHT) {
    scroll_up();
    vga_index = VGA_WIDTH * (VGA_HEIGHT - 1);
  } else {
    vga_index = VGA_WIDTH * next_line_index;
    next_line_index++;
  }
}

//assign ascii character to video buffer
void print_char(char ch) {
  if (ch == '\n') {
    print_new_line();
  } else if (ch == '\t') {
    // 2 spaces for horizontal tab(9)
    vga_buffer[vga_index] = vga_entry(9, g_back_color, g_back_color);
    vga_index++;
    vga_buffer[vga_index] = vga_entry(9, g_back_color, g_back_color);
    vga_index++;
  } else {
    vga_buffer[vga_index] = vga_entry(ch, g_fore_color, g_back_color);
    vga_index++;
  }
}

uint32 strlen(const char* str) {
  uint32 length = 0;
  while (str[length]) {
    length++;
  }
  return length;
}

uint32 digit_count(int num) {
  uint32 count = 0;
  if (num == 0) {
    return 1;
  }
  while(num > 0) {
    count++;
    num = num/10;
  }
  return count;
}

void itoa(int num, char *number) {
  int dgcount = digit_count(num);
  int index = dgcount - 1;
  char x;
  if (num == 0 && dgcount == 1) {
    number[0] = '0';
    number[1] = '\0';
  } else {
    while (num != 0) {
      x = num % 10;
      number[index] = x + '0';
      index--;
      num = num / 10;
    }
    number[dgcount] = '\0';
  }
}

// print string by calling print_char
void print_string(char *str) {
  uint32 index = 0;
  while(str[index]) {
    print_char(str[index]);
    index++;
  }
}

// print int by converting it into string
// & then printing string
void print_int(int num) {
  char str_num[digit_count(num) + 1];
  itoa(num, str_num);
  print_string(str_num);
}

void print_binary(uint32 num) {
  uint32 i;
  
  // Handle zero case
  if (num == 0) {
    for (i = 0; i < 32; i++) {
      print_char('0');
    }
    return;
  }
  
  char bin_arr[32];
  uint32 index = 31;
  
  while (num > 0) {
    if (num & 1) {
      bin_arr[index] = '1';
    } else {
      bin_arr[index] = '0';
    }
    index--;
    num >>= 1;
  }

  for (i = 0; i < 32; ++i) {
    if (i <= index) {
      print_char('0');
    } else {
      print_char(bin_arr[i]);
    }
  }
}

void print_hex(uint32 num) {
  char hex_chars[] = "0123456789ABCDEF";
  print_string("0x");
  
  int i;
  int started = 0;
  for (i = 28; i >= 0; i -= 4) {
    uint8 digit = (num >> i) & 0xF;
    if (digit != 0 || started || i == 0) {
      print_char(hex_chars[digit]);
      started = 1;
    }
  }
}

// Check if CPUID is available
int cpuid_available() {
  uint32 flag;
  asm volatile(
    "pushfl\n"
    "pushfl\n"
    "xorl $0x00200000, (%%esp)\n"
    "popfl\n"
    "pushfl\n"
    "popl %0\n"
    "popfl\n"
    : "=r"(flag)
  );
  
  uint32 original;
  asm volatile("pushfl\n popl %0" : "=r"(original));
  
  return ((flag ^ original) & 0x00200000) != 0;
}

void cpuid(uint32 value, uint32 *eax, uint32 *ebx, uint32 *ecx, uint32 *edx) {
  asm volatile(
    "cpuid"
    : "=a"(*eax), "=b"(*ebx), "=c"(*ecx), "=d"(*edx)
    : "a"(value)
  );
}

void print_vendor_string() {
  uint32 eax, ebx, ecx, edx;
  char vendor[13];
  
  cpuid(0x00, &eax, &ebx, &ecx, &edx);
  
  // EBX, EDX, ECX contain vendor string
  *((uint32*)vendor) = ebx;
  *((uint32*)(vendor + 4)) = edx;
  *((uint32*)(vendor + 8)) = ecx;
  vendor[12] = '\0';
  
  print_string("\n\nCPU Vendor: ");
  print_string(vendor);
  print_string("\nMax CPUID Value: ");
  print_int(eax);
}

void print_eax(uint32 eax) {
  uint32 step_id, model, family_id, proc_type, ext_mod_id, ext_fam_id;
  
  step_id = eax & 0xF;  // bits 0-3
  model = (eax >> 4) & 0xF;  // bits 4-7
  family_id = (eax >> 8) & 0xF;  // bits 8-11
  proc_type = (eax >> 12) & 0x3;  // bits 12-13
  ext_mod_id = (eax >> 16) & 0xF;  // bits 16-19
  ext_fam_id = (eax >> 20) & 0xFF;  // bits 20-27

  print_string("\n\nEAX (Version Information):");
  print_string("\n  Stepping ID: ");
  print_int(step_id);
  print_string("\n  Model: ");
  print_int(model);
  print_string("\n  Family ID: ");
  print_int(family_id);
  print_string("\n  Processor Type: ");
  print_int(proc_type);
  print_string("\n  Extended Model ID: ");
  print_int(ext_mod_id);
  print_string("\n  Extended Family ID: ");
  print_int(ext_fam_id);
}

void print_ebx(uint32 ebx) {
  uint32 brand_index, cache_line_size, max_addr_id, init_apic_id;
  
  brand_index = ebx & 0xFF;  // bits 0-7
  cache_line_size = (ebx >> 8) & 0xFF;  // bits 8-15
  max_addr_id = (ebx >> 16) & 0xFF;  // bits 16-23
  init_apic_id = (ebx >> 24) & 0xFF;  // bits 24-31
  
  print_string("\n\nEBX (Additional Information):");
  print_string("\n  Brand Index: ");
  print_int(brand_index);
  print_string("\n  Cache Line Size: ");
  print_int(cache_line_size * 8);
  print_string(" bytes");
  print_string("\n  Max Addressable IDs: ");
  print_int(max_addr_id);
  print_string("\n  Initial APIC ID: ");
  print_int(init_apic_id);
}

void print_ecx(uint32 ecx) {
  print_string("\n\nECX (Feature Flags):");
  print_string("\n  ");
  print_binary(ecx);
  print_string("\n  Bit 0:  SSE3");
  print_string("\n  Bit 1:  PCLMULQDQ");
  print_string("\n  Bit 3:  MONITOR/MWAIT");
  print_string("\n  Bit 9:  SSSE3");
  print_string("\n  Bit 19: SSE4.1");
  print_string("\n  Bit 20: SSE4.2");
  print_string("\n  Bit 23: POPCNT");
  print_string("\n  Bit 25: AES");
  print_string("\n  Bit 28: AVX");
}

void print_edx(uint32 edx) {
  print_string("\n\nEDX (Feature Flags):");
  print_string("\n  ");
  print_binary(edx);
  print_string("\n  Bit 0:  FPU - x87 FPU on Chip");
  print_string("\n  Bit 1:  VME - Virtual-8086 Mode Enhancement");
  print_string("\n  Bit 2:  DE  - Debugging Extensions");
  print_string("\n  Bit 3:  PSE - Page Size Extensions");
  print_string("\n  Bit 4:  TSC - Time Stamp Counter");
  print_string("\n  Bit 5:  MSR - RDMSR/WRMSR Support");
  print_string("\n  Bit 6:  PAE - Physical Address Extensions");
  print_string("\n  Bit 7:  MCE - Machine Check Exception");
  print_string("\n  Bit 8:  CX8 - CMPXCHG8B Instruction");
  print_string("\n  Bit 9:  APIC - APIC on Chip");
  print_string("\n  Bit 11: SEP - SYSENTER/SYSEXIT");
  print_string("\n  Bit 15: CMOV - Conditional Move");
  print_string("\n  Bit 23: MMX - MMX Technology");
  print_string("\n  Bit 25: SSE - SSE Extensions");
  print_string("\n  Bit 26: SSE2 - SSE2 Extensions");
  print_string("\n\nBy - Gaurav Raj (@thehackersbrain) - https://thehackersbrain.xyz");
}

void cpuid_test() {
  uint32 eax, ebx, ecx, edx;

  print_string("========================================");
  print_string("\n    CPU Information (CPUID)");
  print_string("\n========================================");

  // Check if CPUID is available
  if (!cpuid_available()) {
    print_string("\n\nCPUID instruction not available!");
    return;
  }

  // Get vendor string
  print_vendor_string();

  // Get feature information
  cpuid(0x01, &eax, &ebx, &ecx, &edx);

  print_eax(eax);
  print_ebx(ebx);
  print_ecx(ecx);
  print_edx(edx);
  
  print_string("\n\n=================================================================");
}

void kernel_entry() {
  // first init vga with fore & back color
  init_vga(WHITE, BLUE);
  cpuid_test();
}
