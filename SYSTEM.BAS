

SUB CheckIsISOorLowerCase()
	'--- see if we are is ISO mode or PETSCII lower case
	'--- this NEEDS WORK!!!  but for the moment...
	g_isISOorLowerCase = (((PEEK($372) AND %01000000) <> 0) = 0) OR ((PEEK($372) AND 1) = 1)
    'IF (((PEEK($372) AND %01000000) <> 0) = 0) OR ((PEEK($372) AND 1) = 1) THEN
	'	g_isISOorLowerCase = FALSE
	'ELSE
	'	g_isISOorLowerCase = TRUE
	'END IF
	'RETURN
END SUB

' FUNCTION SYSTEM_KEYBOARD_GET_PETSCIILOWER() as int
'     SYSTEM_KEYBOARD_GET_PETSCIILOWER = (PEEK($372) AND 1) = 1
' END FUNCTION

' FUNCTION SYSTEM_FONT_GET_IS_ISO_MODE() as int
'     SYSTEM_FONT_GET_IS_ISO_MODE = (PEEK($372) AND %01000000) <> 0
' END FUNCTION

