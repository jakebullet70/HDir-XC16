# HDir - Copilot Instructions

## Project Overview
HDir (HotDir) is a **colored directory listing program** for the Commander X16 retro computer, written in nxtBasic. It displays file and directory contents with syntax highlighting based on file extensions and displays file metadata (size, type).

**Key Files:**
- `H.BAS` - Main program entry point; manages directory display, colors, and file listing
- `COLORS.BAS` - Color constants for Commander X16 (16-color palette)
- `CTRL_CODES.BAS` - Control codes (reverse video, quotes, bell)
- `STR.BAS` - String utility functions (padding, truncation)
- `browse-dir.bas` - Alternative directory browser with keyboard navigation

## Architecture & Data Flow

### Main Program Flow (H.BAS)
1. **Initialization**: Loads color configuration from `H.DAT` (or creates default)
2. **Directory scanning**: Builds array `g_DirList$()` of directories for type detection
3. **File enumeration**: Uses `DIRLIST()` API to get files/folders
4. **Display loop**: For each item, determines color based on extension, then prints with formatting

### Color Mapping System
- **Configuration File**: `H.DAT` stores color rules as: `{COLOR}!{EXT},{COLOR}!{EXT},...`
  - Default: `"14!BAS,14!BL,7!BAT,10!PRG,4!DIR"`
  - Format: nxtBasic color number (0-15) + file extension
- **Lookup**: `GetColor4Ext()` function matches extensions to colors; returns default if no match
- **Special handling**: Directories detected by comparing against pre-scanned `g_DirList$()` array

### Character Set Handling
- **PETSCII detection**: `CheckIsISOorLowerCase()` reads system byte `$372` to detect ISO mode or PETSCII lowercase
- **Conditional formatting**: `FixUpChars()` applies `UCASE$()` only when in PETSCII mode (not ISO)
- **File names**: Wrapped in quotes for visibility; uses `RPT$()` for padding

## nxtBasic Specific Patterns

### Include System
- Use `#INCLUDE "filename.BAS"` to load utility modules
- Must be at program start (after CONST declarations)
- Example: `#INCLUDE "CTRL_CODES.BAS"` loads constants

### Global State Management
- Prefix globals with `g_` (e.g., `g_DirList$`, `g_ExtColors$`)
- Use `DIM ... AS TYPE` for typed declarations (essential for nxtBasic compiler)
- Global arrays for configuration (colors) and caching (directory listings)

### File I/O
- Use `OPENFILE(path, FOR_READ|FOR_WRITE)` returning handle
- `LINPUT#(handle, CHR$(13))` reads until carriage return
- `PRINT# handle, data` writes data
- `CLOSE handle` or implicit close via `CLOSELIST()/CLOSEDIRLIST()`

### Directory Listing API
- `DIRLIST("*","*", LIST_DIRS|LIST_FILES|LIST_ALL)` returns count
- `DIRITEM()` retrieves each item (must call sequentially in loop)
- `CLOSELIST()/CLOSEDIRLIST()` cleans up
- Note: HostFS doesn't return `.` and `..` entries; hardware SD card does

### String Functions
- `INSTRREV()` - reverse string search (used for file extension detection)
- `SPLITITEM$(string, delim, index)` - parse delimited strings
- `TALLY(string, char)` - count occurrences
- `REPLACE$(string, old, new)` - string substitution

### Display Primitives
- `COLOR {fg},{bg}` sets foreground and background
- `SETCOL {n}` moves cursor to column n
- `LOCATE {row},{col}` positions cursor
- `REV_ON` constant = reverse video toggle
- `RPT$(string, count)` repeats string
- `CurDir$` returns current directory path

## Compilation & Execution

### Build Environment
- **Compiler**: nxtBasic (https://github.com/unartic/nxtBasic)
- **Platform**: Windows with CRLF line endings
- **Output format**: .PRG file (Commander X16 native)

### Workflow Scripts
- `c.bat` - Compile script (builds from .BAS to .PRG)
- `LOCAL.BAT` - Local testing/debugging
- `x16noCard1x.bat`, `x16noCard2x.bat` - Run in X16 emulator without SD card
- **Distribution**: Rename `H.PRG` to `H` and place in SD card root for system-wide access (`^/H` from any directory)

### Testing Locations
- `test dir/` - Test directory with mixed files for development
- `COLOR TEST` - Directory for color palette verification

## Common Conventions

### Naming
- **Config file**: Root directory `/H.DAT` (editable by user)
- **File extensions**: Uppercase (.BAS, .PRG, .BL, etc.)
- **Variables**: Snake_case for multi-word; single-letter loop counters (i, x, y, tmp1$)

### Error Handling
- Minimal error checking (retro platform constraint)
- DEFAULT color fallback for unknown file types
- System byte read (`PEEK($372)`) for mode detection may require platform-specific tuning

### Performance Notes
- Directory listing limited to max 100-500 items (array size constraint, see DIM statements)
- Pre-scan directories once at startup to optimize type detection
- File sizes use abbreviated format (B, KB, MB, GB)

## When Modifying Code

**Before adding features:**
1. Check `H.DAT` structure for configuration compatibility
2. Verify DIRLIST() API usage matches nxtBasic version
3. Test with both PETSCII and ISO character modes
4. Validate color codes are 0-15 range

**Common extension points:**
- Add more file types to `SetUpFileExtClrs()` config logic
- Extend `browse-dir.bas` for interactive directory navigation
- Modify `FormatFileSize()` for different unit display
- Add new string utilities to `STR.BAS`
