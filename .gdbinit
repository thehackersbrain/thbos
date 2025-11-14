###############################################
#  THBoS Kernel Development GDB Environment   #
###############################################

set disassembly-flavor intel
set pagination off
set confirm off
set architecture i386
set auto-solib-add on
set print pretty on

# ---------------------------------------------------------
#   SHORTCUTS: REGISTERS, STACK, INSTRUCTIONS, SNAPSHOTS
# ---------------------------------------------------------

# Show registers
define regs
    echo \n---- REGISTERS ----\n
    info registers
end

# Dump current stack (raw)
define stack
    echo \n---- STACK (from $esp) ----\n
    x/64x $esp
end

# Dump EBP frame (locals + args)
define frame
    echo \n---- FRAME (EBP) ----\n
    x/24x $ebp
    echo \nargs:\n
    x/8x $ebp+8
    echo \nreturn address:\n
    x/x $ebp+4
end

# Instructions near EIP
define code
    echo \n---- CODE (around EIP) ----\n
    x/20i $eip
end

# Full system snapshot: regs + stack + code
define snap
    echo \n================ SNAPSHOT ================\n
    echo \n[REGISTERS]\n
    info registers
    echo \n[STACK]\n
    x/64x $esp
    echo \n[CODE]\n
    x/20i $eip
    echo \n==========================================\n
end

# ---------------------------------------------------------
#   MEMORY / PAGE UTILITIES
# ---------------------------------------------------------

# Dump a 4KB page
define pg
    if $argc == 1
        echo \n---- PAGE DUMP: \n
        x/1024x $arg0
    else
        echo Usage: pg <address>\n
    end
end

# Hexdump raw bytes
define dump
    if $argc == 1
        echo \n---- BYTE DUMP ----\n
        x/128bx $arg0
    else
        echo Usage: dump <address>\n
    end
end

# ---------------------------------------------------------
#   STEPPING SHORTCUTS
# ---------------------------------------------------------

define s1
    stepi
end

define s10
    stepi 10
end

define s100
    stepi 100
end

# ---------------------------------------------------------
#   Debug panic() immediately if symbol exists
# ---------------------------------------------------------

define runk
    break panic
    continue
end

# ---------------------------------------------------------
#   Quick position display
# ---------------------------------------------------------

define here
    echo \n---- CURRENT CONTEXT ----\n
    info registers eip esp ebp
    x/10i $eip
end