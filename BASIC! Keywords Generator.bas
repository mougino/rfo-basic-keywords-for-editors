
' Extract all BASIC! and GW-Lib keywords as taken from the official
' documentation and format them for a variety of different editors

#COMPILE EXE "BASIC! Keywords Generator.exe"
#DIM ALL

$EXE = "BASIC! Keywords Generator"
$VBA = "1.92" ' Version of BASIC!
$VGW = "4.8"  ' Version of GW-Lib
'------------------------------------------------------
$WEB = "http://mougino.free.fr"
$RFO = "http://rfo-basic.com/manual/#_Toc5236339"
$GWL = "http://mougino.free.fr/tmp/GW/cheatsheet.html"
'------------------------------------------------------
$KWBA = "rfo keywords v1.92.txt"
$KWGW = "gw keywords v4.8.txt"

#RESOURCE ICON   AICO, "res\rfo-editor.ico"
'#RESOURCE MANIFEST, 1, "res\XPTheme.xml"
#RESOURCE MANIFEST, 1, "res\Admin.xml"
'------------------------------------------------------
#RESOURCE RCDATA, KWBA, $KWBA ' Keywords for BASIC!
#RESOURCE RCDATA, KWGW, $KWGW ' Keywords for GW-Lib
'------------------------------------------------------
#RESOURCE RCDATA  NPP, "res\npp.png"
#RESOURCE RCDATA  SCI, "res\SciTE.png"
#RESOURCE RCDATA  NTZ, "res\920.png"
#RESOURCE RCDATA  NT2, "res\920V2.png"
#RESOURCE RCDATA  JOT, "res\jota.png"
#RESOURCE RCDATA  GNY, "res\geany.png"
#RESOURCE RCDATA  SBL, "res\sublime.png"
'------------------------------------------------------
#RESOURCE RCDATA, NPX0, "res\npp_udl_0.xml"
#RESOURCE RCDATA, NPX1, "res\npp_udl_1.xml"
#RESOURCE RCDATA, SCI0, "res\scite_0.properties"
#RESOURCE RCDATA, SCI1, "res\scite_1.properties"
#RESOURCE RCDATA, NTZ0, "res\920_0.conf"
#RESOURCE RCDATA, NTZ1, "res\920_1.conf"
#RESOURCE RCDATA, NTT0, "res\920v2_0.xml"
#RESOURCE RCDATA, NTT1, "res\920v2_1.xml"
#RESOURCE RCDATA, JOT0, "res\jot0.conf"
#RESOURCE RCDATA, JOT1, "res\jot1.conf"
#RESOURCE RCDATA, GNY0, "res\geany0.rfobasic"
#RESOURCE RCDATA, GNY1, "res\geany1.rfobasic"

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#INCLUDE ONCE "WINDOWS.INC"
#PBFORMS END INCLUDES
#INCLUDE ONCE "inc\gdiplus.inc"
#INCLUDE ONCE "inc\BASIC! keywords.inc"
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
%NPP          = 1
%SCITE        = 2
%NINEONEO     = 3
%NINEONEOV2   = 4
%JOTA         = 5
%GEANY        = 6
%SUBLIME      = 7
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1  =  101
%IDC_GRAPHIC1 = 1001
%IDC_LABEL1   = 1002
%IDC_TEXTBOX1 = 1003
%IDC_BUTTON1  = 1004
%IDC_LABEL2   = 1005
%IDC_BUTTON2  = 1006
%IDC_LABEL3   = 1007
%IDC_GRAPHIC2 = 1008
%IDC_GRAPHIC3 = 1009
%IDC_GRAPHIC4 = 1010
%IDC_GRAPHIC5 = 1011
%IDC_GRAPHIC6 = 1012
%IDC_GRAPHIC7 = 1013
%IDC_OPTION1  = 1014
%IDC_OPTION2  = 1015
%IDC_OPTION3  = 1016
%IDC_OPTION4  = 1017
%IDC_OPTION5  = 1018
%IDC_OPTION6  = 1019
%IDC_OPTION7  = 1020
%IDC_BUTTON3  = 1021
%IDC_LABEL4   = 1022
%IDC_LABEL5   = 1023
%IDC_LABEL6   = 1024
%IDC_LABEL7   = 1025
%IDC_LABEL8   = 1026
%IDC_TEXTBOX2 = 1027
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()

    ' Dump BASIC! keywords if needed
    IF NOT EXIST(EXE.PATH$ + $KWBA) THEN
        DumpFile RESOURCE$(RCDATA, "KWBA"), EXE.PATH$ + $KWBA
    END IF

    ' Dump GW keywords if needed
    IF NOT EXIST(EXE.PATH$ + $KWGW) THEN
        DumpFile RESOURCE$(RCDATA, "KWGW"), EXE.PATH$ + $KWGW
    END IF

    ' Escalate privileges
    ' Show main dialog
    GdipInitialize()
    ShowDlg %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ProcDlg()
    STATIC basin AS STRING ' list of basic! keywords
    STATIC gwlin AS STRING ' list of gw-lib keywords
    STATIC allin AS STRING ' consolidated list of keywords (bas+gwl)
    STATIC edout AS LONG   ' editor to make output for
    LOCAL e AS STRING
    LOCAL ff AS LONG

    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
            ' Initialization handler
            CONTROL SET OPTION CB.HNDL, %IDC_OPTION1, %IDC_OPTION1, %IDC_OPTION7
            GdipFitBitmapFromResourceInControl CB.HNDL, %IDC_GRAPHIC1, "NPP"
            GdipFitBitmapFromResourceInControl CB.HNDL, %IDC_GRAPHIC2, "SCI"
            GdipFitBitmapFromResourceInControl CB.HNDL, %IDC_GRAPHIC3, "NTZ"
            GdipFitBitmapFromResourceInControl CB.HNDL, %IDC_GRAPHIC4, "NT2"
            GdipFitBitmapFromResourceInControl CB.HNDL, %IDC_GRAPHIC5, "JOT"
            GdipFitBitmapFromResourceInControl CB.HNDL, %IDC_GRAPHIC6, "GNY"
            GdipFitBitmapFromResourceInControl CB.HNDL, %IDC_GRAPHIC7, "SBL" : CONTROL DISABLE CB.HNDL, %IDC_GRAPHIC7 : CONTROL DISABLE CB.HNDL, %IDC_OPTION7
            basin = EXE.PATH$ + $KWBA : CONTROL SET TEXT CB.HNDL, %IDC_TEXTBOX1, basin
            gwlin = EXE.PATH$ + $KWGW : CONTROL SET TEXT CB.HNDL, %IDC_TEXTBOX2, gwlin
            edout = %NPP

        CASE %WM_SETCURSOR ' Change cursor to link-hand when hovering over links
            IF GetDlgCtrlId(CB.WPARAM) = %IDC_LABEL5 OR _     ' http://mougino.free.fr
               GetDlgCtrlId(CB.WPARAM) = %IDC_LABEL6 OR _     ' BASIC! keywords (Appendix A)
               GetDlgCtrlId(CB.WPARAM) = %IDC_LABEL7 THEN     ' GW-lib keywords (GW APIs cheat sheet)
                SetCursor LoadCursor(%NULL, BYVAL %IDC_HAND)
                SetWindowLong CB.HNDL, %dwl_msgresult, 1
                FUNCTION = 1
            END IF

        CASE %WM_COMMAND
            ' Process control notifications
            SELECT CASE AS LONG CB.CTL
                CASE %IDC_BUTTON1       ' Open BASIC! keywords file
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                        DISPLAY OPENFILE CB.HNDL, , , EXE.NAME$, "", CHR$("Text (*.txt)", 0, "*.TXT", 0), "", "", %OFN_FILEMUSTEXIST TO e
                        IF e <> "" THEN
                            basin = e
                            CONTROL SET TEXT CB.HNDL, %IDC_TEXTBOX1, basin
                            IF gwlin <> "" THEN CONTROL ENABLE CB.HNDL, %IDC_BUTTON3
                        END IF
                    END IF

                CASE %IDC_BUTTON2       ' Open GW-lib keywords file
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                        DISPLAY OPENFILE CB.HNDL, , , EXE.NAME$, "", CHR$("Text (*.txt)", 0, "*.TXT", 0), "", "", %OFN_FILEMUSTEXIST TO e
                        IF e <> "" THEN
                            gwlin = e
                            CONTROL SET TEXT CB.HNDL, %IDC_TEXTBOX2, gwlin
                            IF basin <> "" THEN CONTROL ENABLE CB.HNDL, %IDC_BUTTON3
                        END IF
                    END IF

                CASE %IDC_BUTTON3       ' Generate!
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                        CONTROL DISABLE CB.HNDL, %IDC_BUTTON3 ' Generate Config File(s)
                        CONTROL DISABLE CB.HNDL, %IDC_BUTTON2 ' Browse list of GW-lib keywords (*.txt)
                        CONTROL DISABLE CB.HNDL, %IDC_BUTTON1 ' Browse list of BASIC! keywords (*.txt)

                        ' Consolidate all keywords (BAS + GW) into 1 single file
                        allin = EXE.PATH$ + "all_kw.txt"
                        Consolidate basin, gwlin, allin

                        SELECT CASE edout

                        '============================================================================================
                        CASE %NPP
                        '============================================================================================
                            LOCAL ac, sy AS STRING

                            ' Generate Autocomplete file
                            SplitAfter  = 1                               ' Split all lines
                            SplitChr    = $DQ + " />"                     ' Add this when splitting
                            ShowFn      = 0                               ' Differentiate functions
                            NewLine     = "<KeyWord name=" + $DQ          ' Start all lines with this
                            NewLineFn   = """ func=""yes"                 ' ..and add that if it's a function
                            RmvArgs     = 1                               ' Do not remove arguments
'                            StartFnArgs = "  <Overload retVal=" _         ' Start listing function arguments with this
'                                        + """"" descr="""">"
'                            NewArg      = "    <Param name=" + $DQ        ' Start all function arguments with this
'                            EndFnArgs   = "  </Overload>" + $crlf _       ' End listing function arguments with this
'                                        + "</KeyWord>"
                            KwCase      = 0                               ' Keywords in lower case
                            ac = ParseKWFile (allin)
                            ' Save it
                            e = RTRIM$(ENVIRON$("PROGRAMFILES"), "\") + "\Notepad++\autoCompletion"
                            IF NOT EXIST(e) THEN e = REMOVE$(e, " (x86)")
                            DISPLAY SAVEFILE CB.HNDL, 40, 0, "Save as (1/2)", e, "", e + "\RfoBasic.xml", "", %OFN_PATHMUSTEXIST TO e
                            e = TRIM$(e)
                            IF e = "" THEN GOTO cancelled
                            IF EXIST(e) THEN
                                IF MessageBox (CB.HNDL, "File already exists." + $CR + "Replace it?", _
                                    EXE.NAME$, %MB_ICONQUESTION + %MB_OKCANCEL) = %IDCANCEL THEN GOTO cancelled
                            END IF
                            ff = FREEFILE
                            OPEN e FOR OUTPUT AS #ff
                                PRINT #ff, "<?xml version=""1.0"" encoding=""Windows-1252"" ?>"
                                PRINT #ff, "<NotepadPlus>"
                                PRINT #ff, "<AutoComplete language=""RfoBasic"">"
                                PRINT #ff, "<Environment ignoreCase=""yes"" startFunc=""("" " _
                                         + "stopFunc="")"" paramSeparator="","" additionalWordChar="".$""/>"
                                PRINT #ff, ac
                                PRINT #ff, "</AutoComplete>"
                                PRINT #ff, "</NotepadPlus>"
                            CLOSE #ff

                            ' Generate Syntax file
                            SplitAfter = 2^31 - 1     ' Don't split
                            SplitChr   = ""           ' Add this when splitting
                            ShowFn     = 0            ' Do not differentiate functions
                            NewLine    = ""           ' Start all lines with this
                            RmvArgs    = 1            ' Remove arguments
                            KwCase     = 0            ' Keywords in lower case
                            sy = ParseKWFile (allin)

                            ' Save it
                            e = RTRIM$(ENVIRON$("APPDATA"), "\") + "\Notepad++"
                            DISPLAY SAVEFILE CB.HNDL, 40, 0, "Save as (2/2)", e, "", e + "\userDefineLang.xml", "", %OFN_PATHMUSTEXIST TO e
                            e = TRIM$(e)
                            IF e = "" THEN GOTO cancelled
                            IF EXIST(e) THEN
                                IF MessageBox (CB.HNDL, "File already exists." + $CR + "Replace it?", _
                                    EXE.NAME$, %MB_ICONQUESTION + %MB_OKCANCEL) = %IDCANCEL THEN GOTO cancelled
                            END IF
                            ff = FREEFILE
                            OPEN e FOR OUTPUT AS #ff
                                PRINT #ff, RESOURCE$(RCDATA, "NPX0") + sy + RESOURCE$(RCDATA, "NPX1")
                            CLOSE #ff
                            MessageBox CB.HNDL, "Done!", EXE.NAME$, %MB_ICONINFORMATION

                        '============================================================================================
                        CASE %SCITE
                        '============================================================================================
                            LOCAL s AS STRING

                            ' Generate file
                            SplitAfter = 128    ' Split line after 128 characters
                            SplitChr   = "\"    ' Add a backslash when splitting
                            ShowFn     = 0      ' Do not differentiate functions
                            NewLine    = ""     ' Start all lines with nothing
                            KwCase     = 0      ' Keywords in lower case
                            RmvArgs    = 1      ' Remove arguments
                            s = ParseKWFile (allin)

                            ' Save it
                            e = "vb.properties"
                            DISPLAY SAVEFILE CB.HNDL, 40, 0, "Save as (1/1)", "", "", e, "", %OFN_PATHMUSTEXIST TO e
                            e = TRIM$(e)
                            IF e = "" THEN GOTO cancelled
                            IF EXIST(e) THEN
                                IF MessageBox (CB.HNDL, "File already exists." + $CR + "Replace it?", _
                                    EXE.NAME$, %MB_ICONQUESTION + %MB_OKCANCEL) = %IDCANCEL THEN GOTO cancelled
                            END IF
                            ff = FREEFILE
                            OPEN e FOR OUTPUT AS #ff
                                PRINT #ff, RESOURCE$(RCDATA, "SCI0") + s + RESOURCE$(RCDATA, "SCI1")
                            CLOSE #ff

                            ' OK!
                            MessageBox CB.HNDL, "Done!" + $CR + $CR + "Copy this file near your SciTE.exe or Sc1.exe.", EXE.NAME$, %MB_ICONINFORMATION

                        '============================================================================================
                        CASE %NINEONEO
                        '============================================================================================

                            ' Generate file
                            SplitAfter = 80                         ' Split line after 80 characters
                            SplitChr   = ""                         ' Add nothing when splitting
                            ShowFn     = 0                          ' Do not differentiate functions
                            NewLine    = "syn keyword rfoKeyword "  ' Start all lines with this
                            KwCase     = 2                          ' Keywords in mixed case
                            RmvArgs    = 1                          ' Remove arguments
                            s = ParseKWFile (allin)

                            ' Save it
                            e = "rfo.conf"
                            DISPLAY SAVEFILE CB.HNDL, 40, 0, "Save as (1/1)", "", "", e, "", %OFN_PATHMUSTEXIST TO e
                            e = TRIM$(e)
                            IF e = "" THEN GOTO cancelled
                            IF EXIST(e) THEN
                                IF MessageBox (CB.HNDL, "File already exists." + $CR + "Replace it?", _
                                    EXE.NAME$, %MB_ICONQUESTION + %MB_OKCANCEL) = %IDCANCEL THEN GOTO cancelled
                            END IF
                            ff = FREEFILE
                            OPEN e FOR OUTPUT AS #ff
                                PRINT #ff, RESOURCE$(RCDATA, "NTZ0") + s + RESOURCE$(RCDATA, "NTZ1")
                            CLOSE #ff

                            ' OK!
                            MessageBox CB.HNDL, "Done!" + $CR + $CR + _
                                "Copy this file to your Android device" + $CR + _
                                "inside ""sdcard/.920TextEditor/syntax"" folder", EXE.NAME$, %MB_ICONINFORMATION

                        '============================================================================================
                        CASE %NINEONEOV2
                        '============================================================================================
                            LOCAL jmf, buf AS STRING
                            LOCAL i AS LONG

                            ' Generate jedit mode file
                            SplitAfter = 1                                  ' Split all lines
                            SplitChr   = "</KEYWORD1>"                      ' Add this when splitting
                            ShowFn     = 1                                  ' Differentiate functions by adding '()' after their name
                            NewLine    = $TAB + $TAB + $TAB + "<KEYWORD1>"  ' Start all lines with this
                            KwCase     = 0                                  ' Keywords in lower case
                            RmvArgs    = 1                                  ' Remove arguments
                            jmf = ParseKWFile (allin)
                            REPLACE " </" WITH "</" IN jmf
                            buf = jmf : jmf = ""
                            FOR i = 1 TO PARSECOUNT(buf, $CRLF)
                              e = PARSE$(buf, $CRLF, i)
                              IF INSTR(e, "()") > 0 THEN
                                REPLACE "()" WITH "" IN e
                                REPLACE "KEYWORD1" WITH "FUNCTION" IN e
                              END IF
                              jmf += e + $CRLF
                            NEXT

                            ' Save it
                            e = "rfobasic.xml"
                            DISPLAY SAVEFILE CB.HNDL, 40, 0, "Save as (1/1)", "", "", e, "", %OFN_PATHMUSTEXIST TO e
                            e = TRIM$(e)
                            IF e = "" THEN GOTO cancelled
                            IF EXIST(e) THEN
                                IF MessageBox (CB.HNDL, "File already exists." + $CR + "Replace it?", _
                                    EXE.NAME$, %MB_ICONQUESTION + %MB_OKCANCEL) = %IDCANCEL THEN GOTO cancelled
                            END IF
                            ff = FREEFILE
                            OPEN e FOR OUTPUT AS #ff
                                PRINT #ff, RESOURCE$(RCDATA, "NTT0") + jmf + RESOURCE$(RCDATA, "NTT1")
                            CLOSE #ff

                            ' OK!
                            MessageBox CB.HNDL, "Done!" + $CR + $CR + _
                                "Copy this file to the 920 Editor V2 Android Studio project" + $CR + _
                                "in ""920-text-editor-v2-master\app\src\main\assets\syntax""", EXE.NAME$, %MB_ICONINFORMATION

                        '============================================================================================
                        CASE %JOTA
                        '============================================================================================
                            LOCAL str, sta, sta2 AS STRING

                            ' Generate config file
                            SplitAfter = 1          ' Split all lines
                            SplitChr   = ""         ' Add nothing when splitting
                            ShowFn     = 1          ' Differentiate functions by adding '()' after their name
                            NewLine    = ""         ' Start all lines with nothing
                            KwCase     = 0          ' Keywords in lower case
                            RmvArgs    = 1          ' Remove arguments
                            buf = ParseKWFile (allin)
                            FOR i = 1 TO PARSECOUNT(buf, $CRLF)
                              e = TRIM$(PARSE$(buf, $CRLF, i))
                              e = UCASE$(e) + "|" + e + "|"
                              IF INSTR(e, "$") > 0 THEN       ' string
                                REPLACE "$" WITH "" IN e
                                REPLACE "()" WITH "" IN e
                                str  += e
                              ELSEIF INSTR(e, "()") > 0 THEN  ' function
                                REPLACE "()" WITH "" IN e
                                sta2 += e
                              ELSE                            ' statement
                                sta  += e
                              END IF
                            NEXT
                            str  = "# Built-in variables:" + $CRLF + "string=\b("     + RTRIM$(str,  "|") + ")\b" + $CRLF + $CRLF
                            sta  = "# Keywords:"           + $CRLF + "statement=\b("  + RTRIM$(sta,  "|") + ")\b" + $CRLF + $CRLF
                            sta2 = "# Built-in functions:" + $CRLF + "statement2=\b(" + RTRIM$(sta2, "|") + ")\b" + $CRLF + $CRLF
                            s = str + sta + sta2

                            ' Save it
                            e = "rfobasic.conf"
                            DISPLAY SAVEFILE CB.HNDL, 40, 0, "Save as (1/1)", "", "", e, "", %OFN_PATHMUSTEXIST TO e
                            e = TRIM$(e)
                            IF e = "" THEN GOTO cancelled
                            IF EXIST(e) THEN
                                IF MessageBox (CB.HNDL, "File already exists." + $CR + "Replace it?", _
                                    EXE.NAME$, %MB_ICONQUESTION + %MB_OKCANCEL) = %IDCANCEL THEN GOTO cancelled
                            END IF
                            ff = FREEFILE
                            OPEN e FOR OUTPUT AS #ff
                                PRINT #ff, RESOURCE$(RCDATA, "JOT0") + s + RESOURCE$(RCDATA, "JOT1")
                            CLOSE #ff

                            ' OK!
                            MessageBox CB.HNDL, "Done!" + $CR + $CR + _
                                "Copy this file to your Android device" + $CR + _
                                "inside ""sdcard/.jota/keyword/user"" folder", EXE.NAME$, %MB_ICONINFORMATION

                        '============================================================================================
                        CASE %GEANY
                        '============================================================================================

                            ' Generate Syntax file
                            SplitAfter = 2^31 - 1     ' Don't split
                            SplitChr   = ""           ' Add this when splitting
                            ShowFn     = 0            ' Do not differentiate functions
                            NewLine    = "keywords="  ' Start all lines with this
                            KwCase     = 0            ' Keywords in lower case
                            RmvArgs    = 1            ' Remove arguments
                            s = ParseKWFile (allin)

                            ' Save it
                            e = RTRIM$(ENVIRON$("ProgramFiles"), "\") + "\Geany\data\filedefs\filetypes.rfobasic"
                            DISPLAY SAVEFILE CB.HNDL, 40, 0, "Save as (1/1)", "", "", e, "", %OFN_PATHMUSTEXIST TO e
                            e = TRIM$(e)
                            IF e = "" THEN GOTO cancelled
                            IF EXIST(e) THEN
                                IF MessageBox (CB.HNDL, "File already exists." + $CR + "Replace it?", _
                                    EXE.NAME$, %MB_ICONQUESTION + %MB_OKCANCEL) = %IDCANCEL THEN GOTO cancelled
                            END IF
                            ff = FREEFILE
                            OPEN e FOR OUTPUT AS #ff
                                PRINT #ff, RESOURCE$(RCDATA, "GNY0") + s + RESOURCE$(RCDATA, "GNY1")
                            CLOSE #ff

                            ' OK!
                            MessageBox CB.HNDL, "Done!", EXE.NAME$, %MB_ICONINFORMATION

                        '============================================================================================
                        CASE %SUBLIME
                        '============================================================================================

                        END SELECT


cancelled:
                        CONTROL ENABLE CB.HNDL, %IDC_BUTTON1 ' Browse list of BASIC! keywords (*.txt)
                        CONTROL ENABLE CB.HNDL, %IDC_BUTTON2 ' Browse list of GW-lib keywords (*.txt)
                        CONTROL ENABLE CB.HNDL, %IDC_BUTTON3 ' Generate Config File(s)
                    END IF

                CASE %IDC_GRAPHIC1 : edout = %NPP : CONTROL SET OPTION CB.HNDL, %IDC_OPTION1, %IDC_OPTION1, %IDC_OPTION7
                CASE %IDC_OPTION1  : edout = %NPP

                CASE %IDC_GRAPHIC2 : edout = %SCITE : CONTROL SET OPTION CB.HNDL, %IDC_OPTION2, %IDC_OPTION1, %IDC_OPTION7
                CASE %IDC_OPTION2  : edout = %SCITE

                CASE %IDC_GRAPHIC3 : edout = %NINEONEO : CONTROL SET OPTION CB.HNDL, %IDC_OPTION3, %IDC_OPTION1, %IDC_OPTION7
                CASE %IDC_OPTION3  : edout = %NINEONEO

                CASE %IDC_GRAPHIC4 : edout = %NINEONEOV2 : CONTROL SET OPTION CB.HNDL, %IDC_OPTION4, %IDC_OPTION1, %IDC_OPTION7
                CASE %IDC_OPTION4  : edout = %NINEONEOV2

                CASE %IDC_GRAPHIC5 : edout = %JOTA : CONTROL SET OPTION CB.HNDL, %IDC_OPTION5, %IDC_OPTION1, %IDC_OPTION7
                CASE %IDC_OPTION5  : edout = %JOTA

                CASE %IDC_GRAPHIC6 : edout = %GEANY : CONTROL SET OPTION CB.HNDL, %IDC_OPTION6, %IDC_OPTION1, %IDC_OPTION7
                CASE %IDC_OPTION6  : edout = %GEANY

                CASE %IDC_GRAPHIC7 : edout = %SUBLIME : CONTROL SET OPTION CB.HNDL, %IDC_OPTION7, %IDC_OPTION1, %IDC_OPTION7
                CASE %IDC_OPTION7  : edout = %SUBLIME

                CASE %IDC_LABEL5                     ' http://mougino.free.fr
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                        ShellExecute BYVAL 0, "open", $WEB, BYVAL 0, BYVAL 0, %SW_SHOWNORMAL
                    END IF

                CASE %IDC_LABEL6                     ' BASIC! keywords (Appendix A)
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                        ShellExecute BYVAL 0, "open", $RFO, BYVAL 0, BYVAL 0, %SW_SHOWNORMAL
                    END IF

                CASE %IDC_LABEL7                     ' GW-lib keywords (GW APIs cheat sheet)
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                        ShellExecute BYVAL 0, "open", $GWL, BYVAL 0, BYVAL 0, %SW_SHOWNORMAL
                    END IF

            END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDlg(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg   AS DWORD
    LOCAL hFont1 AS DWORD
    FONT NEW "MS Sans Serif", 8, 4, %ANSI_CHARSET TO hFont1

    DIALOG NEW PIXELS, hParent, $EXE+" (RFO "+$VBA+" / GW "+$VGW+")", , , 489, 395, _
        %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR _
        %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
        %DS_MODALFRAME OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR, TO hDlg
    DIALOG SET ICON      hDlg, "AICO"

    CONTROL ADD LABEL,   hDlg, %IDC_LABEL1, "Load list of BASIC! keywords (*.txt)", 8, 8, 182, 16
    CONTROL ADD LABEL,   hDlg, %IDC_TEXTBOX1, "", 192, 6, 256, 18, %WS_CHILD _
        OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_AUTOHSCROLL OR _
        %SS_PATHELLIPSIS, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL SET COLOR    hDlg, %IDC_TEXTBOX1, -1, %WHITE
    CONTROL ADD BUTTON,  hDlg, %IDC_BUTTON1, "...", 448, 5, 32, 20

    CONTROL ADD LABEL,   hDlg, %IDC_LABEL2, "Load list of GW-lib keywords (*.txt)", 8, 28, 182, 16
    CONTROL ADD LABEL,   hDlg, %IDC_TEXTBOX2, "", 192, 26, 256, 18, %WS_CHILD _
        OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_AUTOHSCROLL OR _
        %SS_PATHELLIPSIS, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL SET COLOR    hDlg, %IDC_TEXTBOX2, -1, %WHITE
    CONTROL ADD BUTTON,  hDlg, %IDC_BUTTON2, "...", 448, 25, 32, 20

    CONTROL ADD LABEL,   hDlg, %IDC_LABEL8, "Online resources:", 8, 48, 90, 16

    CONTROL ADD LABEL,   hDlg, %IDC_LABEL6, "BASIC! keywords (Appendix A)", 100, 48, 175, 20, _
        %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER OR %SS_NOTIFY, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR    hDlg, %IDC_LABEL6, %BLUE, -1
    CONTROL SET FONT     hDlg, %IDC_LABEL6, hFont1

    CONTROL ADD LABEL,   hDlg, %IDC_LABEL7, "GW-lib keywords (GW APIs cheat sheet)", 285, 48, 195, 20, _
        %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER OR %SS_NOTIFY, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR    hDlg, %IDC_LABEL7, %BLUE, -1
    CONTROL SET FONT     hDlg, %IDC_LABEL7, hFont1

    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "",         10, 80, 96, 96, %SS_NOTIFY
    CONTROL ADD OPTION,  hDlg, %IDC_OPTION1, "Notepad++", 10, 184, 96, 16
    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC2, "",     135, 80, 96, 96, %SS_NOTIFY
    CONTROL ADD OPTION,  hDlg, %IDC_OPTION2, "SciTE", 150, 184, 96, 16
    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC3, "",          260, 80, 96, 96, %SS_NOTIFY
    CONTROL ADD OPTION,  hDlg, %IDC_OPTION3, "920 Editor", 260, 184, 96, 16
    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC4, "",             380, 80, 96, 96, %SS_NOTIFY
    CONTROL ADD OPTION,  hDlg, %IDC_OPTION4, "920 Editor V2", 380, 184, 96, 16

    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC5, "",            50, 225, 96, 96, %SS_NOTIFY
    CONTROL ADD OPTION,  hDlg, %IDC_OPTION5, "Jota / Jota+", 50, 322, 96, 16
    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC6, "",     195, 225, 96, 96, %SS_NOTIFY
    CONTROL ADD OPTION,  hDlg, %IDC_OPTION6, "Geany", 210, 322, 96, 16
    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC7, "",            340, 225, 96, 96, %SS_NOTIFY
    CONTROL ADD OPTION,  hDlg, %IDC_OPTION7, "Sublime Text", 340, 322, 96, 16

    CONTROL ADD LABEL,   hDlg, %IDC_LABEL4, "Freeware by mougino (c) 2016-2019", 8, 372, 200, 16
    CONTROL ADD LABEL,   hDlg, %IDC_LABEL5, "http://mougino.free.fr", 208, 371, 112, 16, _
        %WS_CHILD OR %WS_VISIBLE OR %SS_LEFT OR %SS_NOTIFY, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR    hDlg, %IDC_LABEL5, %BLUE, -1
    CONTROL SET FONT     hDlg, %IDC_LABEL5, hFont1

    CONTROL ADD BUTTON,  hDlg, %IDC_BUTTON3, "Generate Config File(s)", 328, 356, 152, 32

#PBFORMS END DIALOG

    DIALOG SHOW MODAL hDlg, CALL ProcDlg TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
    FONT END hFont1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION EXIST(BYVAL fileOrFolder AS STRING) AS LONG
    LOCAL Dummy&
    ON ERROR GOTO Inexistant
    Dummy& = GETATTR(fileOrFolder)
    Inexistant:
    RESUME FLUSH
    FUNCTION = (ERRCLEAR = 0)
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
SUB DumpFile(buf AS STRING, file AS STRING)
    LOCAL ff AS LONG
    ff = FREEFILE
    KILL file
    OPEN file FOR BINARY ACCESS WRITE LOCK WRITE AS #ff
    PUT$ #ff, buf
    CLOSE #ff
END SUB
'------------------------------------------------------------------------------
