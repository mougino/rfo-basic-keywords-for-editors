' Extract all keywords as copied-pasted from Appendix A - Command List
' of the BASIC! documentation: http://rfo-basic.com/manual

GLOBAL SplitAfter   AS LONG     ' Split line after 'SplitAfter' characters
GLOBAL SplitChr     AS STRING   ' Add 'SplitChr' at end of line when splitting it, or end of argument
GLOBAL ShowFn       AS LONG     ' Differentiate functions: 0 = do not differentiate ; 1 = add '()' after function name
GLOBAL NewLine      AS STRING   ' Start all multi-lines with 'NewLine'
GLOBAL NewLineFn    AS STRING   ' ..and add 'NewLineFn' if it's a function
GLOBAL KwCase       AS LONG     ' Keywords case: 0 = lower case ; 1 = upper case ; 2 = mixed case
GLOBAL RmvArgs      AS LONG     ' Remove arguments: 1 = remove ; 0 = keep
GLOBAL StartFnArgs  AS STRING   ' Start a list of function arguments with 'StartFnArgs'
GLOBAL EndFnArgs    AS STRING   ' End a list of function arguments with 'EndFnArgs'
GLOBAL NewArg       AS STRING   ' Start all function arguments with 'NewArg'

'---------------------------------------------------------------------------------------------------------------

MACRO KW_SEPARATOR = IIF$(SplitAfter > 0, $SPC, $CRLF)

'---------------------------------------------------------------------------------------------------------------

MACRO KW_CASE(e) = IIF$(KwCase = 0, LCASE$(e), IIF$(KwCase = 1, UCASE$(e), MCASE$(e)))

'---------------------------------------------------------------------------------------------------------------

MACRO RECURSIVE_TREATMENT(sep) ' Treat all keywords from a single line, that are separated by a character 'sep'
    WHILE i > 0
        h = e
        e = TRIM$(LEFT$(h, i-1))
        s += TRIM$(e, ANY $SPC+$TAB) + $CRLF
        e = TRIM$(MID$(h, i+1))
        i = INSTR(e, ANY sep)
    WEND
    s += TRIM$(e, ANY $SPC+$TAB) + $CRLF
END MACRO

'---------------------------------------------------------------------------------------------------------------

MACRO FORMAT_ARGUMENTS
    e = KW_CASE(e)
    j=INSTR(e,"(")          ' consider subs as functions e.g. gr.bitmap.load arg1,arg2,.. --> gr.bitmap.load(arg1,arg2,..)
    IF j=0 THEN
        j = INSTR(e, " ")
        IF j>0 THEN
            MID$(e,j,1) = "("
            e += ")"
        END IF
    END IF
    IF j>0 THEN             ' format arguments in a simpler manner
        e = REMOVE$(e, ANY "<>{}")
        e = REMOVE$(e, "nexp_")
        e = REMOVE$(e, "_nexp")
        e = REMOVE$(e, "_nvar")
        REPLACE "_sexp" WITH "$" IN e
        REPLACE "_svar" WITH "$" IN e
        REPLACE $DQ WITH "&quot;" IN e
        REPLACE "r|w|a" WITH "&quot;r&quot;|&quot;w&quot;|&quot;a&quot;" IN e
        j = INSTR(e, "[")
        WHILE j>0
            k = INSTR(j, e, "]")
            e = LEFT$(e, j) + MID$(e, k)
            j = INSTR(j+1, e, "[")
        WEND
        REPLACE ", " WITH "," IN e
        REPLACE "(" WITH NewLineFn + REMOVE$(SplitChr, "/") + $CRLF + StartFnArgs + $CRLF + NewArg IN e
        REPLACE "," WITH SplitChr + $CRLF + NewArg IN e
        REPLACE ")" WITH SplitChr + $CRLF + EndFnArgs IN e
    END IF
END MACRO

'---------------------------------------------------------------------------------------------------------------

MACRO REMOVE_ARGUMENTS
    e = KW_CASE(e)
    j=INSTR(e,"(") : IF j<>0 THEN e = TRIM$(LEFT$(e,j-1)) + IIF$(ShowFn, "()", "") ' ABS(<nexp>)
    j=INSTR(e,"<") : IF j<>0 THEN e = TRIM$(LEFT$(e,j-1))                          ' Array.average <Average_nvar>
    j=INSTR(e," ") : IF j<>0 THEN e = TRIM$(LEFT$(e,j-1))                          ' Array.delete Array[]
    j=INSTR(e,",") : IF j<>0 THEN e = TRIM$(LEFT$(e,j-1))                          ' Audio.loop, 114
    j=INSTR(e,":") : IF j<>0 THEN e = TRIM$(LEFT$(e,j-1))                          ' OnBackGround:
    j=INSTR(e,"$") : IF j<>0 AND INSTR(e, "()") = 0 THEN e = TRIM$(LEFT$(e,j))     ' Inkey$
    j=INSTR(e,"{") : IF j<>0 THEN e = TRIM$(LEFT$(e,j-1))                          ' End{<msg_sexp>}
END MACRO

'---------------------------------------------------------------------------------------------------------------

MACRO CHECK_LINE_TOO_LONG
    IF SplitAfter > 0 THEN
        j = INSTR(-1, s, $CRLF)
        IF LEN(MID$(s, j+1)) >= SplitAfter THEN s += SplitChr + $CRLF + NewLine
        IF INSTR(SplitChr,">") > 0 THEN REPLACE RIGHT$(SplitChr,1) + KW_SEPARATOR + SplitChr WITH RIGHT$(SplitChr,1) IN s
    END IF
END MACRO

'---------------------------------------------------------------------------------------------------------------

MACRO ADD_TO_OUTPUT
    IF s = "" THEN s += NewLine
    IF TRIM$(e) <> "" AND INSTR(s, KW_SEPARATOR + TRIM$(e) + KW_SEPARATOR) = 0 _
                      AND INSTR(s, NewLine + TRIM$(e) + KW_SEPARATOR) = 0 THEN
        s += TRIM$(e) + KW_SEPARATOR
        CHECK_LINE_TOO_LONG
    END IF
END MACRO

'---------------------------------------------------------------------------------------------------------------

FUNCTION PARSE_AND_ADD_LINE(inpt AS STRING, outpt AS STRING) AS STRING
    LOCAL e, oe, s, t AS STRING
    LOCAL i, j, k AS LONG

    IF TRIM$(inpt) = "" THEN FUNCTION = outpt : EXIT FUNCTION

    e = inpt
    s = outpt
    IF ASC(TRIM$(e)) > 64 AND ASC(TRIM$(e)) < 123 THEN ' A-Z a-z
        REPLACE ". " WITH "." IN e
        IF RmvArgs THEN
            REMOVE_ARGUMENTS
        ELSE
            FORMAT_ARGUMENTS
        END IF
        ADD_TO_OUTPUT
    END IF
    FUNCTION = s
END FUNCTION

'---------------------------------------------------------------------------------------------------------------

SUB Consolidate(basfile AS STRING, gwfile AS STRING, outfile AS STRING)
    LOCAL ff, i, j, jj, k AS LONG
    LOCAL e, s, h, kw() AS STRING

    ff = FREEFILE                                         ' 1) OPEN BASIC KEYWORDS FILE
    OPEN basfile FOR INPUT AS #ff
        DO
            LINE INPUT #ff, e
            DO
                i = INSTR(-1, e, ",")                     ' Remove the page(s) reference at the end of line
                k = VAL(MID$(e, i+1))                     ' e.g. Zip.read <fid_nexp> ,<buf_svar>, <file_sexp>, 116, 117
                IF k > 0 THEN e = LEFT$(e, i-1)
            LOOP UNTIL k = 0
            i = INSTR(e, ANY "-/")                        ' Split multiple commands per line
            IF i > 0 THEN                                 ' e.g. For - To - Step / Next
                RECURSIVE_TREATMENT("-/")                 ' e.g. Do / Until
            END IF                                        ' e.g. If / Then / Else
            s += TRIM$(e, ANY $SPC+$TAB) + $CRLF
        LOOP UNTIL EOF(#ff)
    CLOSE #ff

    ff = FREEFILE                                         ' 2) OPEN GW-LIB KEYWORDS FILE
    OPEN gwfile FOR INPUT AS #ff
        DO
            LINE INPUT #ff, e
            h = HEX$(ASC(e,1)) + HEX$(ASC(e,2)) + HEX$(ASC(e,3)) ' header
            IF h = "E296BA" THEN
                e = MID$(e, 4)
                i = INSTR(e, "%")  : IF i > 0 THEN e = LEFT$(e, i-1)
                i = INSTR(e, "..")
                j = INSTR(e, $DQ)      ' opening quote
                jj = INSTR(-1, e, $DQ) ' closing quote
                k = INSTR(e, "GW_")
                IF i > 0 AND jj < i THEN e = LEFT$(e, i-1)' e.g. GW_THEME$[1] ..to GW_THEME$[9]
                i = INSTR(e, "=")
                IF i > 0 THEN
                    IF j > 0 AND j < i AND i < jj THEN    ' The equal sign is inside a string
                        ' do nothing                      ' e.g. GW_DEFAULT_TRANSITIONS ("PAGE=fx, PANEL=fx, DIALOG=fx")

                    ELSEIF k > 0 AND k < i THEN           ' The keyword is before the equal sign
                        e = LEFT$(e, i-1)                 ' GW_COLOR$ = "black"

                    ELSE                                  ' Either the keyword is after the equal sign
                        e = MID$ (e, i+1)                 ' e.g. mypage = GW_NEW_PAGE ()
                    END IF                                ' -or- there is no 'GW_' keyword
                END IF                                    ' e.g. mode = IS_APK()
                e = TRIM$(e, ANY $SPC+$TAB)
                i = INSTR(e, "(")
                IF i > 0 THEN e = MCASE$(LEFT$(e, i-1)) + MID$(e, i) ' Convert keyword to mixed case
                s += e + $CRLF
            END IF
        LOOP UNTIL EOF(#ff)
    CLOSE #ff

    REDIM kw(PARSECOUNT(s, $CRLF))                        ' 3) SORT KEYWORDS ALPHABETICALLY
    PARSE s, kw(), $CRLF
    ARRAY SORT kw(), COLLATE UCASE

    k = 0
    FOR i = UBOUND(kw) TO LBOUND(kw)+1 STEP -1            ' 4) REMOVE KEYWORD LIST DUPLICATES
        IF LCASE$(kw(i)) = LCASE$(kw(i-1)) THEN ARRAY DELETE kw(i) : INCR k
    NEXT
    REDIM PRESERVE kw(UBOUND(kw)-k)
    s = JOIN$(kw(), $CRLF)

    ff = FREEFILE                                         ' 5) CREATE CONSOLIDATED FILE
    OPEN outfile FOR OUTPUT AS #ff
        PRINT #ff, s
    CLOSE #ff

END SUB

'---------------------------------------------------------------------------------------------------------------

FUNCTION ParseKWFile(file AS STRING) AS STRING
    LOCAL ff AS LONG
    LOCAL e, s AS STRING

    ff = FREEFILE
    OPEN file FOR INPUT AS #ff
        DO
            LINE INPUT #ff, e
            s = PARSE_AND_ADD_LINE(e, s)
        LOOP UNTIL EOF(#ff)
        s = RTRIM$(s, $CRLF + NewLine)
    CLOSE #ff

    FUNCTION = s
END FUNCTION
