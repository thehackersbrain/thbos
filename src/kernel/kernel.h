#ifndef KERNEL_H
#define KERNEL_H

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;

#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define BUFSIZE (VGA_WIDTH * VGA_HEIGHT)

uint16 *vga_buffer;

#define NULL 0

enum vga_color
{
  BLACK,
  BLUE,
  GREEN,
  CYAN,
  RED,
  MAGENTA,
  BROWN,
  GREY,
  DARK_GREY,
  BRIGHT_BLUE,
  BRIGHT_GREEN,
  BRIGHT_CYAN,
  BRIGHT_RED,
  BRIGHT_MAGENTA,
  YELLOW,
  WHITE,
};

// Function declarations
void init_vga(uint8 fore_color, uint8 back_color);
void clear_vga_buffer(uint16 **buffer, uint8 fore_color, uint8 back_color);
void print_char(char ch);
void print_string(char *str);
void print_int(int num);
void print_binary(uint32 num);
void print_new_line();
void cpuid(uint32 value, uint32 *eax, uint32 *ebx, uint32 *ecx, uint32 *edx);
int cpuid_available();
void cpuid_test();
void kernel_entry();
void zig_hello(void);
int zig_add(int a, int b);
void c_print_string(const char *str);

#endif
