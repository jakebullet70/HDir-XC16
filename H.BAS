'-----------------------------------------------------------------------------------  
' HotDir for the CX16, Just for fun:     
'
'
' sadLogic / Steve De George SR.   Nov-Dec 2025, Kherson Ukraine
' Compile with nxtBasic: https://github.com/unartic/nxtBasic   Windows - CRLF
'-----------------------------------------------------------------------------------

#INCLUDE "CTRL_CODES.BAS" 
#INCLUDE "COLORS.BAS"

CONST COL_WIDTH = 39  'width of columns

'DIM VARS(9), DIM VARS$(9) '--- general purpose vars
'CONST vFILE_NAME = 0

DIM g_ExtColors$(15)  : DIM g_ExtExt$(15) : DIM g_ExtTTL AS INT '--- color map
DIM g_isISOorLowerCase AS INT : CheckIsISOorLowerCase()

'--- we try and store the default text foreground color and restore on exit
DIM g_DefaultColor AS INT : g_DefaultColor = PEEK(886)-96   
IF g_DefaultColor < 0 THEN PRINT "!!!!DEBUG!!!! COLOR TXT VAR IS WRONG": end

'--- print header
PRINT "" 
'PRINT REV_ON + strPadR("HOTDIR CX16 STYLE! V0.2 BETA",COL_WIDTH)  fails to compile
g_tmp1$ = strPadR("HOTDIR CX16 STYLE! V0.2 BETA",COL_WIDTH)               : PRINT REV_ON + g_tmp1$
g_tmp1$ = strPadR(("CURRENT DIR --> " + FixUpChars(CurDir$))  ,COL_WIDTH) : PRINT REV_ON + g_tmp1$

'--- prep
SetUpFileExtClrs()

'--- start it!
DIM fname$ 
DIM g_isDir AS INT
DIM clearLine$ : clearLine$ = RPT$(" ",COL_WIDTH)
DIM DirCount AS INT : DIM FileCount AS INT

'--- Print the folders
g_isDir = TRUE
cnt = DIRLIST("*","*",LIST_DIRS)  
FOR ii = 0 TO cnt - 1
	fname$ = DIRITEM()
	'PRINT UCASE$(fname$ )
	'-- HostFS does not return the . and .. items. hardware/sd card does
	if fname$ <> "." AND fname$ <> ".." then    
		fname$ = FixUpChars(fname$)   '--- lcase$ or PETSCII or ??
		IF LEN(fname$) = 0 THEN 
			CONTINUE
		END IF
		PrintLines(fname$)
		DirCount = DirCount + 1 '--- adjust count
	END IF
NEXT
CLOSEDIRLIST()


'--- Print the files 
FileCount = DIRLIST("*","*",LIST_FILES)
g_isDir = false
FOR ii = 0 to FileCount - 1
	fname$ = FixUpChars(DIRITEM())   '--- lcase$ or PETSCII or ??
	IF LEN(fname$) = 0 THEN 
		CONTINUE
	END IF
	PrintLines(fname$)
NEXT 
CLOSELIST()

'--- print footer
g_tmp1$ = REPLACE$("TTL FILES: <F> TTL DIRS: <D>","<F>",STR$(FileCount))
g_tmp1$ = REPLACE$(g_tmp1$,"<D>",STR$(DirCount))
PRINT REV_ON ; 
PRINT strPadR(g_tmp1$,COL_WIDTH) '--- print footer
END


SUB PrintLines(fn$ AS STRING)
	
	DIM txtColor AS INT
	txtColor = GetColor4Ext(fn$)  '--- get color depending on file ext
	COLOR txtColor 
	'COLOR GetColor4Ext(fn$) '--- set color based on file ext - ERRORS OUT ON COMPILE

	'--- clear line and print file name
	PRINT clearLine$ ; 
	SETCOL 1 : PRINT QUOTES_CHAR + fn$ + QUOTES_CHAR ;
	
	'SETCOL 20 : PRINT DIRITEMDATE() + " "; '--- not used
	'SETCOL 31 : PRINT DIRITEMTIME() + " "; '--- not used
	'--- print size or DIR
	SETCOL 26
	IF g_isDir THEN
		PRINT strPadL("<DIR>",10)
	ELSE
		PRINT FormatFileSize(STR$(DIRITEMSIZE()))
	END IF
	' TODO - add all file size together and show
	COLOR g_DefaultColor '--- restore default color
	
END SUB


'============================================================================================


SUB SetUpFileExtClrs()
	DIM fnumber AS INT
	'--- read from H.DAT if it exists  
	g_tmp1$ = "14!BAS,14!BL,5!BAT,10!PRG,4!DIR,13!SYM" '--- default colors
	g_tmp2$ = "/H.DAT" ' put it in the root for now
	IF FILEEXISTS(g_tmp2$) THEN
		fnumber = OPENFILE(g_tmp2$,FOR_READ)
		g_tmp1$ = LINPUT#(fnumber,chr$(13)) 
    ELSE
		fnumber = OPENFILE(g_tmp2$,FOR_WRITE)
		PRINT# fnumber,g_tmp1$     
    END IF   
	CLOSE fnumber
	
	g_ExtTTL = TALLY(g_tmp1$,",") + 1 
	
	FOR x = 1 TO g_ExtTTL
		g_tmp2$ = SPLITITEM$(g_tmp1$,",",x)
		'--- g_ExtColors should be an INT but is failing when used with SPLITITEM
		'--- so we make it a string and VAL it later. logged BUG in GitHub
		g_ExtColors$(x - 1) = SPLITITEM$(g_tmp2$,"!",1)
		g_ExtExt$(x - 1)    = SPLITITEM$(g_tmp2$,"!",2)  
	NEXT
END SUB

'=========================================================================
'=========================================================================



FUNCTION GetColor4Ext(g_tmp1$ AS STRING) AS INT
	GetColor4Ext = g_DefaultColor  '--- default to original normal color
	
	IF g_isDir THEN 
		g_tmp1$ = "DIR"
	ELSE
		g_tmp1$ = GetFileExt(UCASE$(g_tmp1$)) '--- this is now the file ext 
	END IF
	
	'--- find the color by file ext
	FOR x = 0 TO g_ExtTTL - 1
		IF g_tmp1$ <> "" THEN
			IF g_tmp1$ = g_ExtExt$(x) THEN
				GetColor4Ext = VAL(g_ExtColors$(x)) '--- found!
				BREAK 
			END IF
		END IF
	NEXT
END FUNCTION  


FUNCTION GetFileExt(g_tmp2$ AS STRING) as STRING
	'--- get a file ext if it exists
	x = INSTRREV(g_tmp2$,".")
	if x = 0 THEN 
		GetFileExt = "" :' no ext found
	ELSE
		GetFileExt = RIGHT$(g_tmp2$,LEN(g_tmp2$)-x)
	END IF	
END FUNCTION


Function FixUpChars(tmp$ as STRING) as string
	IF g_isISOorLowerCase then
		FixUpChars = tmp$
	ELSE
		FixUpChars = UCASE$(tmp$)
	END IF
End Function  


FUNCTION FormatFileSize(g_tmp1$ AS STRING) as STRING
	C = GETA()
	IF C = 0 THEN
		g_tmp2$ = "B "
	ELSEIF C = 1 THEN
		g_tmp2$ =  "KB"
	ELSEIF C = 2 THEN
		g_tmp2$ =  "MB"
	ELSE
		g_tmp2$ =  "GB"
	END IF
	FormatFileSize =  strPadL(g_tmp1$ + " " + g_tmp2$,10)
END FUNCTION  

#INCLUDE "STR.BAS" 
'#INCLUDE "box-btns.bas"
#INCLUDE "system.bas"


