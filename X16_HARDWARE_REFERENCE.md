# Commander X16 Hardware Reference for HDir Development

Quick reference for Commander X16 hardware capabilities relevant to HDir and other nxtBasic applications.

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Memory Map & Banking](#memory-map--banking)
3. [I/O Registers](#io-registers)
4. [VERA Video Controller](#vera-video-controller)
5. [Sound System](#sound-system)
6. [Character Sets](#character-sets)

---

## System Architecture

### CPU
- **65C02S** at 8 MHz (6502-compatible with enhanced instruction set)
- Future upgrade path: 65C816 (32-bit, nearly 100% compatible)
- **Caution**: Avoid `BBRx`, `BBSx`, `RMBx`, `SMBx` instructions (not in 65C02)

### Memory
- **512 KB RAM** (expandable to 2 MB on Developer Edition)
- **512 KB ROM**
- Banked architecture for RAM and ROM access
- Expansion cards: up to 3.5 MB additional RAM/ROM

### Peripherals
- PS/2 keyboard and mouse
- 4× NES/SNES controller ports
- SD card interface (FAT32)
- Commodore Serial Bus (IEC)
- User port (GPIO)

---

## Memory Map & Banking

### Fixed Memory Layout

| Address | Size | Description |
|---------|------|-------------|
| `$0000-$9EFF` | 40 KB | Fixed RAM (zero page, stack, KERNAL, BASIC variables) |
| `$9F00-$9FFF` | 256 B | I/O Area (VERA, YM2151, VIA, expansion cards) |
| `$A000-$BFFF` | 8 KB | **Banked RAM Window** (255 banks available) |
| `$C000-$FFFF` | 16 KB | **Banked ROM/Cartridge Window** |

### Banking Registers (Zero Page)

```basic
'Set current RAM bank (0-255)
POKE $0000, bank_number

'Set current ROM/Cartridge bank
'ROM banks: 0-31 (KERNAL, BASIC, etc.)
'Cartridge banks: 32-255
POKE $0001, bank_number

'Read current banks
current_ram_bank = PEEK($0000)
current_rom_bank = PEEK($0001)
```

**Default on startup:** Both banks set to 0

### Fixed RAM Layout

| Address | Size | Description |
|---------|------|-------------|
| `$0000-$0001` | 2 B | Banking registers |
| `$0002-$0021` | 32 B | 16 × 16-bit registers (r0-r15) for KERNAL API |
| `$0022-$007F` | 94 B | Available to user |
| `$0080-$009C` | 29 B | Used by KERNAL/DOS |
| `$009D-$00A8` | 12 B | Reserved for DOS/BASIC |
| `$00A9-$00D3` | 43 B | Math library (and BASIC) |
| `$00D4-$00FF` | 44 B | Used by BASIC |
| `$0100-$01FF` | 256 B | CPU stack |
| `$0200-$03FF` | 512 B | KERNAL/BASIC variables, vectors |
| `$0400-$07FF` | 1 KB | **Available for user machine code/data** |
| `$0800-$9EFF` | 39 KB | **BASIC program/variables (user)** |

### Banked RAM (via `$A000-$BFFF`)

Each bank is 8 KB. Available banks:
- **Bank 0**: Used by KERNAL/CMDR-DOS
  - `$A000-$BEFF`: System reserved
  - `$BF00-$BFFF`: **Parameter passing space** (32 bytes, zero-initialized)
- **Banks 1-255**: Available to user (512 KB on base system, 2 MB on Developer Edition)

### ROM Bank Allocation

| Bank | Name | Description |
|------|------|-------------|
| 0 | KERNAL | Operating system, drivers |
| 1 | KEYBD | Keyboard layout tables |
| 2 | CMDRDOS | FAT32 DOS for SD cards |
| 3 | FAT32 | FAT32 driver |
| 4 | BASIC | BASIC interpreter |
| 5 | MONITOR | Machine language monitor |
| 6 | CHARSET | PETSCII/ISO character sets (uploaded to VRAM) |
| 7 | DIAG | Memory diagnostic |
| 8 | GRAPH | Graph/font routines |
| 9 | DEMO | Demo routines |
| 10 | AUDIO | Audio API |
| 11 | UTIL | System config (date/time, display) |
| 12 | BANNEX | BASIC extensions |
| 13-14 | X16EDIT | Built-in text editor |
| 15 | BASLOAD | BASLOAD dialect transpiler |
| 16-31 | — | Currently unused |
| 32-255 | — | Cartridge RAM/ROM |

---

## I/O Registers

The I/O Area (`$9F00-$9FFF`) contains memory-mapped I/O for hardware control:

| Address | Size | Description | Speed |
|---------|------|-------------|-------|
| `$9F00-$9F0F` | 16 B | VIA #1 (I/O controller) | 8 MHz |
| `$9F10-$9F1F` | 16 B | VIA #2 (I/O controller) | 8 MHz |
| `$9F20-$9F3F` | 32 B | **VERA video controller** | 8 MHz |
| `$9F40-$9F41` | 2 B | **YM2151 audio** | 2 MHz |
| `$9F60-$9F7F` | 32 B | Expansion Card MMIO3 | 8 MHz |
| `$9F80-$9F9F` | 32 B | Expansion Card MMIO4 | 8 MHz |
| `$9FA0-$9FBF` | 32 B | Expansion Card MMIO5 | 2 MHz |
| `$9FC0-$9FDF` | 32 B | Expansion Card MMIO6 | 2 MHz |
| `$9FE0-$9FFF` | 32 B | Cartridge/Expansion MMIO7 | 2 MHz |

### Accessing I/O Registers

```basic
'VERA register example (select address for reading/writing)
POKE $9F20, addr_low
POKE $9F21, addr_high

'Read from VERA
data = PEEK($9F22)

'Write to VERA
POKE $9F22, data
```

---

## VERA Video Controller

### Capabilities
- Up to **640×480** resolution
- **256 colors** from a palette of 4096
- **128 sprites** (hardware-accelerated)
- **2 layers** (Layer 0 and Layer 1)
- Per-layer config: bitmap or tilemap mode
- Color depths: 2, 4, 16, or 256 colors per pixel

### Text Mode Resolutions (available via SCREEN command)

| Mode | Resolution | Columns × Rows |
|------|------------|-----------------|
| 0 | 80×60 | 80 × 60 |
| 1 | 80×30 | 80 × 30 |
| 2 | 40×60 | 40 × 60 |
| 3 | 40×30 | 40 × 30 |
| 4 | 40×15 | 40 × 15 |
| 5 | 20×30 | 20 × 30 |
| 6 | 20×15 | 20 × 15 |
| 7 | 22×23 | 22 × 23 |
| 8 | 64×50 | 64 × 50 |
| 9 | 64×25 | 64 × 25 |
| 10 | 32×50 | 32 × 50 |
| 11 | 32×25 | 32 × 25 |
| 128 | 320×240 + 40×30 text | Dual-layer mode |

### HDir Context: Text Mode Display

HDir uses text mode (default SCREEN 0: 80×60) for directory listing. The 80-column format allows:
- Filename display with padding
- Size/type indicators
- Color-coded entries by file type

```basic
SCREEN 0              'Set to 80×60 text mode
COLOR fg, bg          'Set text colors (0-15)
LOCATE row, col       'Position cursor
PRINT "text"          'Display text
```

---

## Sound System

### Three Independent Sound Sources

#### 1. Yamaha YM2151 FM Synthesizer
- **8 channels** with 4-operator FM synthesis
- Professional-grade sound design
- Address: `$9F40-$9F41`
- Speed: 2 MHz

#### 2. VERA PSG (Programmable Sound Generator)
- **16 channels**
- **4 waveforms**: pulse, sawtooth, triangle, noise
- Built into VERA video chip
- Address: Via VERA registers

#### 3. VERA PCM (Pulse Code Modulation)
- **16-bit stereo audio**
- Up to **48 kHz** sample rate
- Direct audio output
- Via VERA

---

## Character Sets

### Available Character Sets (12 total)

The X16 includes 12 character sets for text display. Switching between them allows different visual styles and language support.

#### Standard Sets

| # | Name | Description | Use Case |
|---|------|-------------|----------|
| 1 | **ISO** | International letters + glyphs | Non-English text, modern aesthetic |
| 2 | **PETSCII Upper/Graphics** | Uppercase + drawing glyphs | Default (like C64), retro look |
| 3 | **PETSCII Upper/Lower** | Upper + lowercase (fewer glyphs) | Readable text with mixed case |
| 4-6 | **Thin variants** | All above with thinner fonts | Compact display |

#### Specialty Sets

| # | Name | Description | Language |
|---|------|-------------|----------|
| 7 | **CP437** | IBM PC character set | DOS/BBS compatibility |
| 8-9 | **Cyrillic ISO** | ISO-8859-5 | Russian, Bulgarian, etc. |
| 10-11 | **Eastern Latin ISO** | ISO-8859-16 | Polish, Hungarian, Romanian, etc. |
| 12 | **Katakana** | Japanese syllabary | Japanese text |

### HDir Character Set Handling

HDir detects and handles character sets via system byte:

```basic
'Detect ISO mode or PETSCII lowercase
'System byte at $372:
'  Bit 0: PETSCII lowercase flag
'  Bit 6: ISO mode flag

FUNCTION CheckIsISOorLowerCase() AS INT
    'Read system byte
    mode_byte = PEEK($372)
    
    'Check for ISO mode OR PETSCII lowercase
    is_iso_or_lower = (((mode_byte AND %01000000) <> 0) OR ((mode_byte AND 1) = 1))
    RETURN is_iso_or_lower
END FUNCTION

'Use in display logic
IF is_iso_or_lower THEN
    'Keep filenames as-is (ISO supports lowercase)
    display_name$ = filename$
ELSE
    'Convert to uppercase (PETSCII graphics mode)
    display_name$ = UCASE$(filename$)
END IF
```

### Character Set Selection (via KERNAL)

The character set affects visual output but doesn't require code changes in nxtBasic—it's managed by the system. To switch sets, use system utilities or KERNAL calls.

---

## Key Takeaways for HDir

### Memory Optimization
- Use zero-page addresses `$0022-$007F` (94 bytes) for custom variables in performance-critical code
- Avoid conflicts with BASIC by staying in `$0400-$07FF` range for helper code
- Banked RAM (`$A000-$BFFF`) available for large data structures

### I/O Access
- VERA registers at `$9F20-$9F3F` for advanced graphics
- YM2151 at `$9F40-$9F41` for sound (2 MHz speed—allow delays)
- VIA controllers at `$9F00-$9F1F` for hardware I/O

### Display Features
- 16-color palette (0-15) for text mode
- Multiple text resolutions; HDir uses 80-column default
- 12 character sets; HDir handles PETSCII vs ISO automatically
- VERA supports sprites and bitmap layers for future enhancements

### Compatibility Notes
- SD card is FAT32-based via CMDRDOS
- KERNAL API is Commodore-compatible (except video/audio)
- Parameter passing via `$BF00-$BFFF` for inter-program communication
- Banking allows programs to exceed 64 KB (native 65C02 limit)

---

## Related Documentation
- Full X16 hardware reference: `docs/xc16/`
- nxtBasic reference: `NXTBASIC_REFERENCE.md`
- HDir copilot instructions: `.github/copilot-instructions.md`
