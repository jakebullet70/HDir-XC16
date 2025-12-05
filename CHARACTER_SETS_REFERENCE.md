# Commander X16 Character Sets Reference

Comprehensive guide to the 12 character sets available on Commander X16, with usage patterns and HDir implications.

## Quick Reference

| # | Name | Capitals | Lowercase | Graphics | Int'l | Language | Best For |
|---|------|----------|-----------|-----------|-------|----------|----------|
| 1 | ISO | ✓ | ✓ | ✗ | ✓ | English + most European | Text with accents, international |
| 2 | PETSCII Upper/Gfx | ✓ | ✗ | ✓ | ✗ | English | Retro aesthetic, box drawing |
| 3 | PETSCII Upper/Lower | ✓ | ✓ | ✗ | ✗ | English | Classic C64 feel |
| 4 | PETSCII Upper/Gfx (thin) | ✓ | ✗ | ✓ | ✗ | English | Compact retro look |
| 5 | PETSCII Upper/Lower (thin) | ✓ | ✓ | ✗ | ✗ | English | Compact text |
| 6 | ISO (thin) | ✓ | ✓ | ✗ | ✓ | English + European | Compact international |
| 7 | CP437 | ✓ | ✗ | ✓ | ✗ | English | DOS/BBS compatibility |
| 8 | Cyrillic ISO | ✓ | ✓ | ✗ | ✓ | Cyrillic languages | Russian, Bulgarian, Serbian |
| 9 | Cyrillic ISO (thin) | ✓ | ✓ | ✗ | ✓ | Cyrillic languages | Compact Cyrillic |
| 10 | Eastern Latin ISO | ✓ | ✓ | ✗ | ✓ | Eastern European | Polish, Hungarian, Romanian |
| 11 | Eastern ISO (thin) | ✓ | ✓ | ✗ | ✓ | Eastern European | Compact Eastern European |
| 12 | Katakana (thin) | Hiragana | Katakana | ✗ | ✓ | Japanese | Japanese text |

---

## Detailed Character Set Descriptions

### 1. ISO (Standard International)

**Characteristics:**
- Full ASCII/ISO-8859-1 support
- Both uppercase and lowercase letters
- International characters: àáâãäå, èéêë, ìíîï, ñ, òóôõöø, ùúûü, ý, ÿ
- Plus French/German/Spanish/Italian symbols
- No graphics characters (just text)

**Use Case:**
- Multi-language text (English, French, German, Spanish, Italian, Portuguese, etc.)
- Modern, clean aesthetic
- Professional text display

**HDir Implication:**
```basic
'ISO mode allows lowercase filenames to display correctly
'HDir detects ISO and preserves case:
IF g_isISOorLowerCase THEN
    'ISO mode - keep filenames as-is
    display_name$ = filename$
ELSE
    'PETSCII mode - convert to uppercase
    display_name$ = UCASE$(filename$)
END IF
```

---

### 2. PETSCII Upper/Graphics (Default)

**Characteristics:**
- **Uppercase letters only** (A-Z, no lowercase a-z)
- **Graphics mode**: Includes box-drawing characters, Commodore symbols
- Common graphics glyphs:
  - Box corners: `┌ ┐ └ ┘`
  - Lines: `─ │ ┼ ├ ┤ ┬ ┴`
  - Blocks: `█ ▀ ▄ ◀ ▶`
  - Symbols: `♠ ♥ ♦ ♣ ◆ ●`
- Native to Commodore 64 and X16

**Use Case:**
- Retro/classic look (Commodore aesthetic)
- Text-based graphics and UI layouts
- File browsers (like HDir) that use box drawing
- Backward compatibility with C64 programs

**HDir Implication:**
```basic
'HDir uses this mode by default
'Box drawing in DrawBox() subroutine:
SUB DrawBox(top, left, height, width)
    PRINT "+"                    'Top-left corner
    PRINT "-"                    'Horizontal line
    PRINT "+"                    'Top-right corner
    PRINT "|"                    'Vertical line
    'etc...
END SUB

'Filenames shown in UPPERCASE
```

---

### 3. PETSCII Upper/Lowercase

**Characteristics:**
- Both uppercase AND lowercase letters
- **No graphics characters** - graphics replaced by lowercase letters (a-z)
- Otherwise compatible with PETSCII uppercase/graphics
- Allows traditional two-case text

**Use Case:**
- Programs that need both cases but no graphics
- Readable mixed-case filenames/text
- C64 compatibility when case matters

**HDir Implication:**
```basic
'HDir can display filenames in mixed case
'But box-drawing requires PETSCII graphics mode
'May need to switch modes or use ASCII alternatives (+ - |)
```

---

### 4-6. Thin Font Variants

**Characteristics:**
- Thinner character rendering (0.8-0.9× width)
- Same content as base versions
- Allows more text per line
- Useful when screen real estate is limited

**Variants:**
- **#4**: PETSCII Upper/Graphics (thin) - compact retro
- **#5**: PETSCII Upper/Lowercase (thin) - compact text
- **#6**: ISO (thin) - compact international

**HDir Implication:**
```basic
'Thin fonts allow more columns on screen:
'Default (80 columns) could show ~88 columns with thin font
'Useful for very long filenames
```

---

### 7. CP437 (IBM PC/DOS)

**Characteristics:**
- IBM PC/ASCII Extended character set
- Uppercase letters, lowercase letters
- Graphics block elements similar to PETSCII
- Box drawing: `┌─┐│└┘├┤┬┴┼` (same positions as PETSCII)
- Math symbols: `±×÷√∞`
- Misc: `Σπ∞∆ΣΦΩ`

**Use Case:**
- DOS/BBS compatibility
- Displaying text from DOS systems
- Cross-platform file browser tools
- Exact line-by-line DOS output

**HDir Implication:**
```basic
'Good for displaying CP437 text files
'Box drawing works similarly to PETSCII graphics
'Filenames display in mixed case
```

---

### 8-9. Cyrillic ISO (Russian, Bulgarian, Serbian, etc.)

**Characteristics:**
- Full Cyrillic alphabet (uppercase + lowercase)
- ISO-8859-5 standard
- Russian: А Б В Г Д Е Ё Ж З И Й К Л М Н О П Р С Т У Ф Х Ц Ч Ш Щ Ъ Ы Ь Э Ю Я
- Bulgarian: Same alphabet with 30 letters (no Ё)
- Serbian, Macedonian compatible

**Variants:**
- **#8**: Standard weight
- **#9**: Thin font

**Use Case:**
- Russian text, Bulgarian, Serbian, Macedonian
- Cyrillic documentation
- International file browsers

**HDir Implication:**
```basic
'For Cyrillic filenames:
'Switch to Cyrillic ISO charset
'HDir will display Cyrillic text correctly
'Still detect ISO mode for proper lowercase handling
```

---

### 10-11. Eastern Latin ISO (Central/Eastern European)

**Characteristics:**
- ISO-8859-16 (Latin 10) standard
- Supports: Polish, Hungarian, Romanian, Slovenian, Croatian, Albanian, German, French, Italian
- Additional characters:
  - Ą Ć Č Ď Đ Ę Ě Ğ İ Ł Ń Ň Ó Ő Ř Ś Š Ş Ť Ţ Ů Ú Ű Ź Ż Ž
  - With lowercase variants

**Variants:**
- **#10**: Standard weight
- **#11**: Thin font

**Use Case:**
- Central/Eastern European languages
- Polish: ąćęłńóśźż
- Hungarian: gyűőú
- Romanian: țș
- Croatian/Slovenian: čđšž

**HDir Implication:**
```basic
'For Eastern European filenames:
'Switch to Eastern Latin ISO charset
'Preserves all diacritical marks correctly
'ISO mode for proper case handling
```

---

### 12. Katakana (thin)

**Characteristics:**
- Japanese syllabary (katakana + hiragana glyphs)
- Thin rendering
- Supports Japanese text
- Alternative syllabary representations
- Also supports Ainu language

**Use Case:**
- Japanese text and filenames
- Ainu language
- Multi-language X16 systems targeting Japanese market

**HDir Implication:**
```basic
'For Japanese SD cards or files:
'Switch to Katakana charset
'HDir will display Japanese filenames correctly
'System becomes fully internationalized
```

---

## Character Set Selection in Code

### Detecting Current Character Set

```basic
'System byte at $372 contains character mode flags
mode_byte = PEEK($372)

'Check specific flags:
is_petscii_lowercase = (mode_byte AND 1) = 1          'Bit 0
is_iso_mode = (mode_byte AND %01000000) <> 0         'Bit 6

'HDir detection pattern:
g_isISOorLowerCase = (((mode_byte AND %01000000) <> 0) OR _
                      ((mode_byte AND 1) = 1))
```

### Switching Character Sets (via KERNAL)

Character set switching is typically done through system utilities rather than direct nxtBasic code. The selected charset:
- Affects all text display immediately
- Persists until changed
- Doesn't require program restart
- System handles VRAM updates

---

## Practical Patterns for HDir

### Pattern 1: Multi-Language Support

```basic
FUNCTION DisplayFileName(filename$) AS STRING
    'Detect character mode
    mode_byte = PEEK($372)
    is_iso_or_lower = (((mode_byte AND %01000000) <> 0) OR _
                       ((mode_byte AND 1) = 1))
    
    IF is_iso_or_lower THEN
        'ISO/lowercase mode: preserve case
        DisplayFileName = filename$
    ELSE
        'PETSCII graphics: uppercase
        DisplayFileName = UCASE$(filename$)
    END IF
END FUNCTION
```

### Pattern 2: International File Browser

```basic
'HDir could detect charset and adapt display:
'- PETSCII graphics: Use box-drawing for UI
'- ISO/Cyrillic/Eastern: Use ASCII alternatives (+ - |)
'- Katakana: Use appropriate line characters

SUB DrawBoxAdaptive(top, left, height, width)
    mode_byte = PEEK($372)
    is_graphics = (((mode_byte AND %01000000) = 0) AND _
                   ((mode_byte AND 1) = 0))
    
    IF is_graphics THEN
        'Use PETSCII graphics
        LOCATE top, left : PRINT "┌"
    ELSE
        'Use ASCII alternatives
        LOCATE top, left : PRINT "+"
    END IF
END SUB
```

### Pattern 3: Detecting Language for Formatting

```basic
SUB ConfigureForLanguage(charset_type AS INT)
    SELECT charset_type
    CASE 1          'ISO
        'Setup for European languages
        COL_WIDTH = 40
    CASE 8, 9       'Cyrillic
        'Cyrillic font narrower, adjust layout
        COL_WIDTH = 35
    CASE 10, 11     'Eastern Latin
        COL_WIDTH = 40
    CASE 12         'Katakana
        'Kanji/Kana narrower
        COL_WIDTH = 30
    CASE ELSE       'PETSCII variants
        COL_WIDTH = 39
    END SELECT
END SUB
```

---

## String Comparison Across Charsets

### Case-Insensitive Matching

```basic
'In PETSCII graphics mode (no lowercase):
'Comparison is inherently case-insensitive
IF filename$ = "TEST.BAS" THEN ...

'In ISO/other modes with lowercase:
'Use UCASE$ for comparison
IF UCASE$(filename$) = "TEST.BAS" THEN ...
```

### Character Set-Safe String Functions

```basic
FUNCTION SafeCompare(str1$, str2$ AS STRING) AS INT
    'Compare strings accounting for character set
    mode_byte = PEEK($372)
    is_iso_or_lower = (((mode_byte AND %01000000) <> 0) OR _
                       ((mode_byte AND 1) = 1))
    
    IF is_iso_or_lower THEN
        'Use uppercase comparison for consistency
        SafeCompare = (UCASE$(str1$) = UCASE$(str2$))
    ELSE
        'PETSCII already uppercase
        SafeCompare = (str1$ = str2$)
    END IF
END FUNCTION
```

---

## Summary for HDir Development

### Default Behavior
- HDir works best with **PETSCII Upper/Graphics** for classic look
- Shows uppercase filenames, uses box-drawing for UI

### International Support
- Detect `PEEK($372)` to handle ISO and lowercase variants
- Conditionally apply `UCASE$()` only in PETSCII mode
- Allow system charset switching without HDir modification

### Future Enhancement Opportunities
- Add language pack system for CP437, Cyrillic, Eastern Latin
- Implement character set detection and adaptive UI rendering
- Create multi-language file descriptions or comments system
- Support Unicode-like presentation for international markets

---

## Related Documentation
- Commander X16 Hardware Reference: `X16_HARDWARE_REFERENCE.md`
- X16 Full Character Set Docs: `docs/xc16/X16 Reference - Appendix I - Character Sets.md`
- nxtBasic Reference: `NXTBASIC_REFERENCE.md`
- HDir Copilot Instructions: `.github/copilot-instructions.md`
