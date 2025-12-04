

SUB CheckIsISOorLowerCase()
	'--- see if we are is ISO mode or PETSCII lower case
	'--- this NEEDS WORK!!!  but for the moment...
	g_isISOorLowerCase = (((PEEK($372) AND %01000000) <> 0) = 0) OR ((PEEK($372) AND 1) = 1)
	RETURN
    'IF (((PEEK($372) AND %01000000) <> 0) = 0) OR ((PEEK($372) AND 1) = 1) THEN
	'	g_isISOorLowerCase = FALSE
	'ELSE
	'	g_isISOorLowerCase = TRUE
	'END IF
	'RETURN
END SUB

SUB SYSTEM_KEYBOARD_GET_PETSCIILOWER()
    SYSTEM_KEYBOARD_GET_PETSCIILOWER = (PEEK($372) AND 1) = 1
END SUB

SUB SYSTEM_FONT_GET_IS_ISO_MODE()
    SYSTEM_FONT_GET_IS_ISO_MODE = (PEEK($372) AND %01000000) <> 0
END SUB

