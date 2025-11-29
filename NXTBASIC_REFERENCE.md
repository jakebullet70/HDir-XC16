# nxtBasic Reference for HDir Development

Quick reference for nxtBasic keywords and functions used in HDir and common Commander X16 programming patterns.

## Table of Contents
1. [Variables & Arrays](#variables--arrays)
2. [String Handling](#string-handling)
3. [File I/O](#file-io)
4. [Screen & Display](#screen--display)
5. [Control Flow](#control-flow)
6. [Functions & Subroutines](#functions--subroutines)
7. [Directory Listing API](#directory-listing-api)
8. [Miscellaneous](#miscellaneous)

---

## Variables & Arrays

### Variable Types

nxtBasic supports three variable types: **integers** (16-bit signed, -32,768 to 32,767), **strings** (dynamic, up to 1024 bytes), and **floating-point**.

```basic
DIM g_DirCount AS INT           'Declare integer (used in H.BAS)
DIM g_DirList$(100)             'Declare string array (max 100 items)
DIM g_ExtColors$(15)            'String array for color codes
CONST COL_WIDTH = 39            'Constant declaration
```

**Key points:**
- Variables don't need declaration but can be explicitly typed with `DIM ... AS TYPE`
- Strings end with `$`: `name$`, arrays use parentheses: `array$(index)`
- Globals should be prefixed with `g_` for visibility
- Constants defined with `CONST` are compile-time replacements

### Variable Scope
- nxtBasic uses **global variable scope** - all variables exist globally
- Function/subroutine parameters are also global variables
- For recursion, use `PushVar()` and `PullVar()` to save/restore values

```basic
v = 5
PushVar(v)
MySub()              'which modifies v
v = PullVar()        'retrieve original value
```

---

## String Handling

### Core String Functions

| Function | Syntax | Returns | Example |
|----------|--------|---------|---------|
| **LEN** | `LEN(string)` | Length | `PRINT LEN("HELLO")` → 5 |
| **LEFT$** | `LEFT$(string, length)` | Left substring | `LEFT$("HELLO", 2)` → "HE" |
| **RIGHT$** | `RIGHT$(string, length)` | Right substring | `RIGHT$("HELLO", 2)` → "LO" |
| **MID$** | `MID$(string, start, len)` | Middle substring | `MID$("HELLO", 2, 3)` → "ELL" |
| **UCASE$** | `UCASE$(string)` | Uppercase | `UCASE$("hello")` → "HELLO" |
| **LCASE$** | `LCASE$(string)` | Lowercase | `LCASE$("HELLO")` → "hello" |
| **RPT$** | `RPT$(string, count)` | Repeated string | `RPT$("*", 5)` → "*****" |
| **STR$** | `STR$(number)` | Number to string | `STR$(123)` → "123" |
| **VAL** | `VAL(string)` | String to number | `VAL("123")` → 123 |
| **CHR$** | `CHR$(code)` | ASCII/PETSCII char | `CHR$(65)` → "A" |
| **INSTRREV** | `INSTRREV(string, char)` | Last position of char | `INSTRREV("HELLO", "L")` → 4 |
| **SPC** | `SPC(count)` | Spaces | Used in PRINT: `"A" + SPC(5) + "B"` |

### String Patterns in HDir

```basic
'Padding strings (STR.BAS utilities)
FUNCTION strPadL(tmp0$, count AS INT) AS STRING
    mTMP = LEN(tmp0$)
    IF mTMP > count THEN
        strPadL = LEFT$(tmp0$, count)
    ELSE
        strPadL = (RPT$(" ", count - mTMP) + tmp0$)
    END IF
END FUNCTION

'Extract file extension
FUNCTION GetFileExt(tmp2$ AS STRING) AS STRING
    x = INSTRREV(tmp2$, ".")
    IF x = 0 THEN
        GetFileExt = ""
    ELSE
        GetFileExt = RIGHT$(tmp2$, LEN(tmp2$) - x)
    END IF
END FUNCTION

'Conditional string formatting (PETSCII vs ISO)
FUNCTION FixUpChars(tmp$ AS STRING) AS STRING
    IF g_isISOorLowerCase THEN
        FixUpChars = tmp$
    ELSE
        FixUpChars = UCASE$(tmp$)
    END IF
END FUNCTION
```

### HDir-Specific Functions
- `SPLITITEM$(string, delimiter, index)` - Parse delimited strings from config
- `TALLY(string, char)` - Count character occurrences
- `REPLACE$(string, old, new)` - String substitution

---

## File I/O

### Opening Files

```basic
'Simpler method with OPENFILE
fileNumber = OPENFILE("H.DAT", FOR_READ)      'Read mode
fileNumber = OPENFILE("H.DAT", FOR_WRITE)     'Write mode
fileNumber = OPENFILE("$", COMMAND)           'Command channel

'Alternative: full control with OPEN
OPEN fileNumber, deviceNumber, channel, "filename"
'  channel: 0 for read, 1 for write
'  device: 8 for disk/SD card
```

### Reading from Files

```basic
'LINPUT# - read until specific character (usually CHR$(13) for line break)
fnumber = OPENFILE("/H.DAT", FOR_READ)
line$ = LINPUT#(fnumber, CHR$(13))

'INPUT# - read until linefeed
text$ = INPUT#(fnumber)

'GET# - read single byte
byte$ = GET#(fnumber)

'BINPUT# - read block of bytes
block$ = BINPUT#(fnumber, 15)
```

### Writing to Files

```basic
fnumber = OPENFILE("/H.DAT", FOR_WRITE)
PRINT# fnumber, "14!BAS,14!BL,7!BAT,10!PRG,4!DIR"
'Without semicolon: includes CHR$(13) linefeed
'With semicolon: no linefeed
PRINT# fnumber, "text"; 
CLOSE fnumber
```

### File Operations

```basic
IF FILEEXISTS("H.DAT") THEN
    '... file exists ...
ELSE
    '... file doesn't exist ...
END IF

status = EOF                'Check end-of-file after read
CLOSE fileNumber            'Always close when done
```

### HDir Config File Pattern

```basic
SUB SetUpFileExtClrs()
    tmp1$ = "14!BAS,14!BL,7!BAT,10!PRG,4!DIR"  'Default
    tmp2$ = "/H.DAT"
    IF FILEEXISTS(tmp2$) THEN
        fnumber = OPENFILE(tmp2$, FOR_READ)
        tmp1$ = LINPUT#(fnumber, CHR$(13))
    ELSE
        fnumber = OPENFILE(tmp2$, FOR_WRITE)
        PRINT# fnumber, tmp1$
    END IF
    CLOSE fnumber
    
    'Parse config: COLOR!EXT,COLOR!EXT,...
    g_ExtTTL = TALLY(tmp1$, ",") + 1
    FOR x = 1 TO g_ExtTTL
        tmp2$ = SPLITITEM$(tmp1$, ",", x)
        g_ExtColors$(x - 1) = SPLITITEM$(tmp2$, "!", 1)
        g_ExtExt$(x - 1) = SPLITITEM$(tmp2$, "!", 2)
    NEXT
END SUB
```

---

## Screen & Display

### Text Output

```basic
PRINT "Hello, World!"         'Print with newline
PRINT "Text"; "More text"     'Semicolon = no newline
? "Hello"                     'Shorthand for PRINT
```

### Cursor Positioning

```basic
LOCATE row, col              'Position cursor
SETCOL col                   'Set column on current row (useful for multi-line layouts)
SETINDENT value              'Set default indent for all PRINT commands
CLS                          'Clear screen
```

### Color Management

```basic
'Color codes: 0-15 (see COLORS.BAS)
COLOR foreground              'Set foreground only
COLOR foreground, background  'Set foreground and background

'Example from H.BAS
COLOR 14              'Light blue text
PRINT "File name"
COLOR g_DefaultColor  'Restore default
```

### Control Codes

```basic
REV_ON = CHR$($12)           'Reverse video
QUOTES_CHAR = CHR$(34)       'Quote character
BELL = CHR$($07)             'Bell sound

'Usage
PRINT REV_ON + "HEADER"      'Reverse video header
PRINT QUOTES_CHAR + fname$ + QUOTES_CHAR
```

### HDir Display Pattern

```basic
DIM clearLine$ : clearLine$ = RPT$(" ", COL_WIDTH)

FOR ii = 1 TO g_FileCount
    fname$ = FixUpChars(DIRITEM())
    txtColor = GetColor4Ext(fname$)
    
    COLOR txtColor
    PRINT clearLine$;          'Clear line with color
    SETCOL 1
    PRINT QUOTES_CHAR + fname$ + QUOTES_CHAR;
    
    SETCOL 22
    IF g_isDir THEN
        PRINT strPadL("<DIR>", 10)
    ELSE
        PRINT FormatFileSize(STR$(DIRITEMSIZE()))
    END IF
    
    COLOR g_DefaultColor
NEXT
```

---

## Control Flow

### Conditional Statements

```basic
'IF/THEN/END IF
IF condition THEN
    'code
END IF

'IF/ELSEIF/ELSE/END IF
IF x > 10 THEN
    PRINT "Greater"
ELSEIF x = 10 THEN
    PRINT "Equal"
ELSE
    PRINT "Less"
END IF
```

### Looping

```basic
'FOR/NEXT loop
FOR i = 1 TO count
    'code
    IF condition THEN
        BREAK           'Exit loop immediately
    END IF
    IF condition2 THEN
        CONTINUE        'Skip to next iteration
    END IF
NEXT

'DO/LOOP
DO WHILE condition
    'code
LOOP

DO UNTIL condition
    'code
LOOP

DO
    'code (infinite until BREAK)
LOOP
```

### Goto (Legacy)

```basic
Loop:
    'code
    IF condition THEN GOTO EndLoop
GOTO Loop
EndLoop:
```

---

## Functions & Subroutines

### Defining Functions

```basic
FUNCTION GetColor4Ext(fname$ AS STRING) AS INT
    GetColor4Ext = g_DefaultColor  'Return via function name assignment
    
    isDir(fname$)
    IF g_isDir THEN
        fname$ = "DIR"
    ELSE
        fname$ = GetFileExt(UCASE$(fname$))
    END IF
    
    FOR x = 0 TO g_ExtTTL - 1
        IF fname$ <> "" AND fname$ = g_ExtExt$(x) THEN
            GetColor4Ext = VAL(g_ExtColors$(x))
            BREAK
        END IF
    NEXT
END FUNCTION
```

### Defining Subroutines

```basic
SUB GrabDirs()
    g_DirCount = 0
    cnt = DIRLIST("*", "*", LIST_DIRS)
    IF cnt > 0 THEN
        FOR i = 1 TO cnt
            NewItem$ = DIRITEM()
            IF NewItem$ <> "." AND NewItem$ <> ".." THEN
                g_DirList$(g_DirCount) = UCASE$(NewItem$)
                g_DirCount = g_DirCount + 1
            END IF
        NEXT
    END IF
    CLOSEDIRLIST()
END SUB
```

### Exiting Early

```basic
SUB MySub()
    FOR i = 1 TO 100
        IF i = 50 THEN
            EXIT SUB        'Exit before END SUB
        END IF
    NEXT
END SUB
```

---

## Directory Listing API

### Directory Enumeration

```basic
'List directories, files, or all
count = DIRLIST("*", "*", LIST_DIRS)       'Directories only
count = DIRLIST("*", "*", LIST_FILES)      'Files only
count = DIRLIST("*", "*", LIST_ALL)        'Both

'Get each item (must call sequentially)
FOR i = 1 TO count
    item$ = DIRITEM()               'File/directory name
    size = DIRITEMSIZE()            'File size in bytes
    date$ = DIRITEMDATE()           'Date string
    time$ = DIRITEMTIME()           'Time string
    '... process item ...
NEXT

CLOSELIST()                         'Clean up after files
CLOSEDIRLIST()                      'Clean up after directories
```

### HDir Directory Scanning Pattern

```basic
SUB GrabDirs()
    'Pre-scan all directories at startup
    'Used later to identify if item is directory
    g_DirCount = 0
    cnt = DIRLIST("*", "*", LIST_DIRS)
    IF cnt > 0 THEN
        FOR i = 1 TO cnt
            NewItem$ = DIRITEM()
            'HostFS doesn't return . and .. (SD card does)
            IF NewItem$ <> "." AND NewItem$ <> ".." THEN
                g_DirList$(g_DirCount) = UCASE$(NewItem$)
                g_DirCount = g_DirCount + 1
            END IF
        NEXT
    END IF
    CLOSEDIRLIST()
END SUB

SUB isDir(tmp2$ AS STRING)
    g_isDir = FALSE
    FOR y = 0 TO g_DirCount
        IF tmp2$ = g_DirList$(y) THEN
            g_isDir = TRUE
            BREAK
        END IF
    NEXT
END SUB
```

### Current Directory

```basic
path$ = CurDir$              'Get current directory as string
'In PETSCII/lowercase mode, may need UCASE$(CurDir$) for display
```

---

## Miscellaneous

### Program Control

```basic
END                          'Exit program, return to BASIC
CHAIN "program.prg"          'Load and run another program
```

### System Information

```basic
t = TI                       'Jiffy timer (1/60 second units)
time$ = TI$                  'Current time "HHMMSS"
date$ = DA$                  'Current date "MMDDYY"
```

### Timing

```basic
SLEEP jiffys                 'Pause execution (60 jiffies = 1 second)
SLEEP 60                     'Wait 1 second
```

### Memory Access

```basic
value = PEEK(address)        'Read byte from memory
POKE address, value          'Write byte to memory
POKEN address, "STRING"      'Write string to memory

'HDir example: detect character mode
SYSTEM.KEYBOARD.IS.PETSCIILOWER = (PEEK($372) AND 1) = 1
SYSTEM.FONT.GET.IS.ISO.MODE = (PEEK($372) AND %01000000) <> 0
```

### Utility Functions

```basic
'Hex/Binary conversion
hex$ = HEX$(255)             'Returns "FF"
bin$ = BIN$(15)              'Returns "00001111"

'Keyboard input (non-blocking)
key$ = GET                   'Get key if pressed, empty string if none
IF key$ = "" THEN
    PRINT "No key pressed"
END IF

'Check if key is held down (not ASCII, use keycodes)
IF KEYDOWN($53) THEN
    PRINT "Arrow Up is pressed"
END IF
```

### Comments

```basic
'This is a comment
REM This is also a comment
PRINT "Code" REM Inline comment works too
```

---

## Include System (Project Organization)

```basic
#INCLUDE "COLORS.BAS"        'Include at program start
#INCLUDE "STR.BAS"           'Can include utility modules
#INCLUDE "file.bas", FORCE   'FORCE re-includes even if already included

'Includes are recursive and unlimited depth
'Duplicate includes prevented unless FORCE specified
```

**HDir include pattern:**
```basic
'H.BAS start
#INCLUDE "CTRL_CODES.BAS"
#INCLUDE "COLORS.BAS"
'... rest of program ...
#INCLUDE "STR.BAS"           'Often at end for function definitions
```

---

## nxtBasic Compilation Notes

- **Line endings**: Windows CRLF required for `c.bat`
- **Filenames**: Use UPPERCASE for files unless in ISO mode
- **Performance**: Integer operations are fastest; avoid floats when possible
- **Arrays**: Single-dimension arrays (e.g., `corX(100)`, `corY(100)`) faster than multi-dimensional
- **File I/O**: Test with actual SD card image in emulator, not just HOSTFS (different `.` and `..` behavior)
- **String memory**: Limited by reserved RAM banks ($05-$0F); large strings may fragment memory

---

## Related Files

- Full docs: `docs/nxtbasic/`
- HDir main: `H.BAS`
- Utility modules: `COLORS.BAS`, `CTRL_CODES.BAS`, `STR.BAS`
- Alternative browser: `browse-dir.bas`
