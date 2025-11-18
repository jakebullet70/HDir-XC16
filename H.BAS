'-----------------------------------------------------------------------------------  
' HotDir for the CX16, Just for fun:     
'
'
' sadLogic / Steve De George SR.   Nov 2025, Kherson Ukraine
' Compile with nxtBasic: https://github.com/unartic/nxtBasic   Windows - CRLF
'-----------------------------------------------------------------------------------


'GETCOLS: 
#INCLUDE "CTRL_CODES.BAS" 
#INCLUDE "COLORS.BAS" 
CONST COL_WIDTH = 39  'width of columns

DIM g_DirCount AS INT : DIM g_DirList$(100) '--- array to store the directory listing. (max 100 in this case)
DIM g_ExtColors$(15)  : DIM g_ExtExt$(15) : DIM g_ExtTTL AS INT '--- color map
DIM g_isISOorLowerCase AS INT : CheckIsISOorLowerCase()

'--- we try and store the default text foreground color and restore on exit
DIM g_DefaultColor AS INT : g_DefaultColor = PEEK(886)-96   
if g_DefaultColor < 0 then print "!!!!DEBUG!!!! COLOR TXT VAR IS WRONG": end

'--- print header
PRINT "" 
tmp1$ = strPadR("HOTDIR CX16 STYLE! V0.1 BETA",COL_WIDTH)   : PRINT REV_ON + tmp1$
tmp1$ = strPadR(("CURRENT DIR --> " + FixUpChars(CurDir$))  ,COL_WIDTH) : PRINT REV_ON + tmp1$

'--- prep
SetUpFileExtClrs()
GrabDirs()

'--- start it!
DIM fname$ : DIM txtColor AS INT
DIM clearLine$ : clearLine$ = RPT$(" ",COL_WIDTH)

'--- Print the files and folders
g_FileCount = DIRLIST("*","*",LIST_ALL)
FOR ii = 1 to g_FileCount
	
	fname$ = FixUpChars(DIRITEM())   '--- lcase$ or PETSCII or ??
	IF LEN(fname$) = 0 THEN 
		CONTINUE
	END IF
	
	txtColor = GetColor4Ext(fname$)  '--- get color depending on file ext
	
	'--- clear line and print file name
	COLOR txtColor : PRINT clearLine$ ; 
	SETCOL 1 : PRINT QUOTES_CHAR + fname$ + QUOTES_CHAR ;
	
	
	'SETCOL 20 : PRINT DIRITEMDATE() + " "; '--- not used
	'SETCOL 31 : PRINT DIRITEMTIME() + " "; '--- not used
	'--- print size or DIR
	SETCOL 22
	IF g_isDir THEN
		PRINT strPadL("<DIR>",10)
	ELSE
		PRINT FormatFileSize(STR$(DIRITEMSIZE()))
	END IF
	' TODO - add all file size together and show
	COLOR g_DefaultColor '--- restore default color
	
NEXT 
CLOSELIST()


tmp1$ = REPLACE$("TTL FILES: <F> TTL DIRS: <D>","<F>",STR$(GetTtlFileCount()))
tmp1$ = REPLACE$(tmp1$,"<D>",STR$(GetTtlDirCount()))
PRINT REV_ON ; 
PRINT strPadR(tmp1$,COL_WIDTH) '--- print footer
END


FUNCTION GetTtlFileCount() AS INT
	IF g_FileCount = 0 AND g_DirCount = 0 THEN 
		GetTtlFileCount = 0
	ELSE
		GetTtlFileCount = g_FileCount-g_DirCount-1
	END IF
END FUNCTION
FUNCTION GetTtlDirCount() AS INT
	GetTtlDirCount = 0
	IF g_DirCount > 0 THEN 
		GetTtlDirCount = g_DirCount + 1
	END IF
END FUNCTION


'============================================================================================

SUB GrabDirs()
	'--- stuff the DIR's in an array to compare to later
	g_DirCount = 0
	cnt = DIRLIST("*","*",LIST_DIRS)  
    IF cnt > 0 THEN
        FOR i = 1 TO cnt
            NewItem$ = DIRITEM()
			'-- HostFS does not return the . and .. items. hardware/sd card does
            if NewItem$ <> "." AND NewItem$ <> ".." then    
                g_DirList$(g_DirCount) = UCASE$(NewItem$)
                g_DirCount = g_DirCount + 1
            END IF
        NEXT
		g_DirCount = g_DirCount - 1
    END IF
    CLOSEDIRLIST()
END SUB


SUB SetUpFileExtClrs()
	'--- read from H.DAT if it exists  
	tmp1$ = "14!BAS,14!BL,7!BAT,10!PRG,4!DIR" '--- default colors
	tmp2$ = "/H.DAT" ' put it in the root for now
	IF FILEEXISTS(tmp2$) THEN
		fnumber = OPENFILE(tmp2$,FOR_READ)
		tmp1$ = LINPUT#(fnumber,chr$(13)) 
    ELSE
		fnumber = OPENFILE(tmp2$,FOR_WRITE)
		PRINT# fnumber,tmp1$     
    END IF   
	CLOSE fnumber
	
	g_ExtTTL = TALLY(tmp1$,",") + 1 
	
	FOR x = 1 TO g_ExtTTL
		tmp2$ = SPLITITEM$(tmp1$,",",x)
		'--- g_ExtColors should be an INT but is failing when used with SPLITITEM
		'--- so we make it a string and VAL it later. logged BUG in GitHub
		g_ExtColors$(x - 1) = SPLITITEM$(tmp2$,"!",1)
		g_ExtExt$(x - 1)    = SPLITITEM$(tmp2$,"!",2)  
	NEXT
	'g_ExtColors$(0) = 14   : g_ExtExt$(0) = "BAS"
END SUB

'=========================================================================
'=========================================================================


SUB isDir(tmp2$ AS STRING)
	g_isDir = False '--- default to false
	FOR y = 0 to g_DirCount 
		'--- compare to DIRs grabbed earlier
		IF tmp2$ = g_DirList$(y) THEN
			g_isDir = TRUE
			BREAK
		END IF
	NEXT
END SUB


FUNCTION GetColor4Ext(tmp1$ AS STRING) AS INT
	GetColor4Ext = g_DefaultColor  '--- default to original normal color
	
	isDir(tmp1$)
	IF g_isDir THEN 
		tmp1$ = "DIR"
	ELSE
		tmp1$ = GetFileExt(UCASE$(tmp1$)) '--- this is now the file ext 
	END IF
	
	'--- find the color by file ext
	FOR x = 0 TO g_ExtTTL - 1
		IF tmp1$ <> "" THEN
			IF tmp1$ = g_ExtExt$(x) THEN
				GetColor4Ext = VAL(g_ExtColors$(x)) '--- found!
				BREAK 
			END IF
		END IF
	NEXT
END FUNCTION  


FUNCTION GetFileExt(tmp2$ AS STRING) as STRING
	'--- get a file ext if it exists
	x = INSTRREV(tmp2$,".")
	if x = 0 THEN 
		GetFileExt = "" :' no ext found
	ELSE
		GetFileExt = RIGHT$(tmp2$,LEN(tmp2$)-x)
	END IF	
END FUNCTION


Function FixUpChars(tmp$ as STRING) as string
	IF g_isISOorLowerCase then
		FixUpChars = tmp$
	ELSE
		FixUpChars = UCASE$(tmp$)
	END IF
End Function  


SUB CheckIsISOorLowerCase()
	'--- see if we are is ISO mode or PETSCII lower case
	'--- this NEEDS WORK!!!  but for the moment...
	'SYSTEM.KEYBOARD.IS.PETSCIILOWER = (PEEK($372) AND 1) = 1
	'SYSTEM.FONT.GET.IS.ISO.MODE = (PEEK($372) AND %01000000) <> 0)
	g_isISOorLowerCase = (((PEEK($372) AND %01000000) <> 0) = 0) OR ((PEEK($372) AND 1) = 1)
	RETURN
    'IF (((PEEK($372) AND %01000000) <> 0) = 0) OR ((PEEK($372) AND 1) = 1) THEN
	'	g_isISOorLowerCase = FALSE
	'ELSE
	'	g_isISOorLowerCase = TRUE
	'END IF
	'RETURN
END SUB



FUNCTION FormatFileSize(tmp1$ AS STRING) as STRING
	C = GETA()
	IF C = 0 THEN
		tmp2$ = "B "
	ELSEIF C = 1 THEN
		tmp2$ =  "KB"
	ELSEIF C = 2 THEN
		tmp2$ =  "MB"
	ELSE
		tmp2$ =  "GB"
	END IF
	FormatFileSize =  strPadL(tmp1$ + " " + tmp2$,10)
END FUNCTION  

#INCLUDE "STR.BAS" 

