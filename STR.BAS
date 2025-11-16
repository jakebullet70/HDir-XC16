'-----------------------------------------------------------------------------------  
' for the CX16
'
' Strings methods
'
' sadLogic / Steve De George SR.   Nov 2025, Kherson Ukraine
' Compile with nxtBasic: https://github.com/unartic/nxtBasic   Windows - CRLF
'-----------------------------------------------------------------------------------


'DIM params$(4)



FUNCTION strPadL(tmp0$,count AS INT) AS STRING
    mTMP = LEN(tmp0$)
	IF mTMP > count THEN
		strPadL = LEFT$(tmp0$,count)
	ELSE
		strPadL = (RPT$(" ",count - mTMP) + tmp0$)
	END IF
END FUNCTION 

FUNCTION strPadR(tmp0$,count AS INT) AS STRING
    mTMP = LEN(tmp0$)
	IF mTMP > count THEN
		strPadR = LEFT$(tmp0$,count)
	ELSE
		strPadR = tmp0$ + RPT$(" ",count - mTMP)
	END IF
END FUNCTION 

' FUNCTION strCenterString(tmp0$ AS STRING, xWidth AS INT) AS STRING
	' mTMP = (xWidth - LEN(tmp0$)) / 2
	' strCenterString = (RPT$(" ",mTMP) + tmp0$ + RPT$(" ",mTMP))                                                        
' END FUNCTION  


' FUNCTION strBoolToStr(bool AS int) AS INT
	' if bool = FALSE THEN 
		' strBoolToStr = "false"
	' else
		' strBoolToStr = "true"
	' end if
' END FUNCTION

' FUNCTION strStrToBool(strbool AS STRING)
    ' strStrToBool = (LCASE$(strbool) <> "false")
' END FUNCTION  

' FUNCTION strContains AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
    ' RETURN strInstr(searchme, findme)
' END FUNCTION

' FUNCTION strContains AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE)
	' IF IgnoreCase THEN RETURN strInstr(LCASE$(searchme), LCASE$(findme))
	' RETURN strInstr(searchme, findme)
' END FUNCTION

' FUNCTION strStartsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96)
	' RETURN (strInstr(searchme, findme) = 1)                                       
' END FUNCTION

' FUNCTION strStartsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE)
	' IF IgnoreCase THEN RETURN (strInstr(LCASE$(searchme), LCASE$(findme)) = 1)
	' RETURN (strInstr(searchme, findme) = 1)
' END FUNCTION  

' FUNCTION strEndsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96)
	' RETURN (RIGHT$(searchme,LEN(findme)) = findme)
' END FUNCTION 

' FUNCTION strEndsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE)
	' IF IgnoreCase THEN RETURN (LCASE$(RIGHT$(searchme,LEN(findme))) = LCASE$(findme))
	' RETURN (RIGHT$(searchme,LEN(findme)) = findme) 
' END FUNCTION        











