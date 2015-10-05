FUNCTION fpi_xticks, an_axis, an_index, a_value, a_level, $
                     BEGINNING=beginning
;{
    COMPILE_OPT idl2
    COMMON tryplot_common, tryplot_beginning

    IF NOT KEYWORD_SET(beginning) THEN beginning=0

    IF( beginning NE 0 ) THEN BEGIN ;{
	tryplot_beginning=beginning
	ret=''
    ENDIF ELSE BEGIN ;} ;{
	jul=tryplot_beginning+a_value-1
	ret=LABEL_DATE('x',0,jul)
    ENDELSE ;}

    RETURN, ret
;}
END


