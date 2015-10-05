PRO get_param_list,kinst,kindat_parts,year,month,day,ndays,isplot,param_avail
;{

query = 'SELECT DATE_ID from tbl_date WHERE YEAR =' + STRING(year)
query += ' AND MONTH =' + STRING(month)
query += ' AND DAY =' + STRING(day) + ';'

rows=0ul
columns=0ul
results=0ul
date1=''
date2=''

val0 = LOAD_CATALOG_QUERY( query, rows, columns, results )

IF( val0 EQ 0 ) THEN BEGIN ;{
    val1 = GET_CELL( results, 0ul, 0ul, date1 )
    IF( val1 EQ 0 ) THEN BEGIN ;{
	date2 = date1 + ndays
    ENDIF ;}
ENDIF ;}

val2 = DESTROY_RESULT_SET( results )

kindat_list=''
n_kindat_parts = N_ELEMENTS( kindat_parts )
FOR i=0ul, (n_kindat_parts-1) DO BEGIN ;{
    IF( i NE 0ul ) THEN BEGIN ;{
	kindat_list += ','
    ENDIF ;}
    kindat_list += STRING( kindat_parts[i] )
ENDFOR ;}

query='SELECT DISTINCT concat(tbl_parameter_code.PARAMETER_ID,"%",tbl_parameter_code.MADRIGAL_NAME,"%",tbl_parameter_code.LONG_NAME)'

query=query+' FROM tbl_parameter_code,tbl_record_info,tbl_record_type,tbl_file_info,tbl_cedar_file,tbl_date_in_file'

IF( isplot EQ 1ul ) THEN BEGIN ;{
    query = query + ',tbl_plotting_params'
ENDIF ;}

query=query+' WHERE (1) AND tbl_parameter_code.PARAMETER_ID=tbl_record_info.PARAMETER_ID'

query=query+' AND tbl_record_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID'

query=query+' AND tbl_record_type.RECORD_TYPE_ID=tbl_file_info.RECORD_TYPE_ID'

query=query+' AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID'

query=query+' AND tbl_file_info.RECORD_IN_FILE_ID=tbl_date_in_file.RECORD_IN_FILE_ID'

query=query+' AND ((tbl_date_in_file.DATE_ID >='+STRING(date1)+') AND (tbl_date_in_file.DATE_ID <='+STRING(date2)+'))'

query=query+' AND (tbl_record_type.KINST='+STRING(kinst)+')'

query=query+' AND ((tbl_record_type.KINST='+STRING(kinst)+') AND (tbl_record_type.KINDAT IN (' + kindat_list + ')))'
 
IF( isplot EQ 1ul ) THEN BEGIN ;{
    query=query+' AND ((tbl_plotting_params.KINST='+STRING(kinst)+') AND (tbl_plotting_params.KINDAT IN ('+kindat_list+')))'
    query=query+' AND (tbl_plotting_params.PARAMETER_ID = tbl_parameter_code.PARAMETER_ID)'
ENDIF ;}

query=query+' ORDER BY tbl_parameter_code.PARAMETER_ID ASC;'

rows=0ul
columns=0ul
results=0ul
cell=''

val0 = LOAD_CATALOG_QUERY( query, rows, columns, results )

IF( val0 EQ 0 ) THEN BEGIN ;{
    FOR i=0ul,(rows-1) DO BEGIN ;{
	val1 = GET_CELL( results, i, 0ul, cell )
	IF( val1 EQ 0 ) THEN BEGIN ;{
	    part = STR_SEP( cell, '^', /TRIM )
	    IF( i EQ 0 ) THEN BEGIN ;{
		param_avail = [part[0]]
	    ENDIF ELSE BEGIN ;} ;{
		param_avail = [param_avail,part[0]]
	    ENDELSE ;}
	ENDIF ;}
    ENDFOR ;}
ENDIF ;}

val2 = DESTROY_RESULT_SET( results )

;}
END

