PRO get_kindat_list,kinst,isplot,kindat_list
;{

    IF( isplot EQ 0ul ) THEN BEGIN ;{
	query='SELECT KINDAT from tbl_record_type WHERE KINST=' + STRING( kinst )
    ENDIF ELSE BEGIN ;} ;{
	query='SELECT DISTINCT KINDAT from tbl_plotting_params WHERE KINST=' + STRING( kinst )
    ENDELSE ;}

    rows=0ul
    columns=0ul
    results=0ul
    cell=''

    val0 = LOAD_CATALOG_QUERY( query, rows, columns, results )

    IF( val0 EQ 0 ) THEN BEGIN ;{
	FOR i=0ul, (rows-1) DO BEGIN ;{
	    val1 = GET_CELL( results, i, 0ul, cell )
	    IF( val1 EQ 0 ) THEN BEGIN ;{
		IF( i EQ 0 ) THEN BEGIN ;{
		    kindat_list=[cell]
		ENDIF ELSE BEGIN ;} ;{
		    kindat_list=[kindat_list,cell]
		ENDELSE ;}
	    ENDIF ;}
	ENDFOR ;}
    ENDIF ;}

    val2 = DESTROY_RESULT_SET( results )

;}
END

