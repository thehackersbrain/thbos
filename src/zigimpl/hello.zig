export fn zig_hello() callconv(.c) void {
    c_print_string("\nHello from Zig!");
}

export fn zig_add(a: i32, b: i32) callconv(.c) i32 {
    return a + b;
}

extern fn c_print_string(str: [*:0]const u8) void;
extern fn print_int(num: i32) void;
