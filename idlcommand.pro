pro idlcommand, kinst, kindats, params, onoff_list, $
                year, month, day, ndays, sdt, edt, isplot, DEBUG=debug
;{

    IF( N_ELEMENTS( debug ) LE 0L ) THEN debug = 0UL

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'<BR /><BR />'
	PRINT,'kinst = ',kinst,'<BR />'
	PRINT,'kindats = ',kindats,'<BR />'
	PRINT,'params = ',params,'<BR />'
	PRINT,'onoff_list = ',onoff_list,'<BR />'
	PRINT,'year = ',year,'<BR />'
	PRINT,'month = ',month,'<BR />'
	PRINT,'day = ',day,'<BR />'
	PRINT,'ndays = ',ndays,'<BR />'
	PRINT,'sdt = ',sdt,'<BR />'
	PRINT,'edt = ',edt,'<BR />'
	PRINT,'isplot = ',isplot,'<BR />'
	PRINT,'<BR />'
    ENDIF ;}

    ;*********************************************************************
    ; Determine the kindat list. If the kindat list is undef then find all
    ; of the operating modes for the given kinst. Otherwise, use the '|'
    ; separated list in kindat
    ;*********************************************************************
    IF ( kindats EQ 'undef' ) THEN BEGIN ;{
	GET_KINDAT_LIST,kinst,isplot,kindat_parts
    ENDIF ELSE BEGIN ;} ;{
	kindat_parts = STR_SEP( kindats, '|', /TRIM )
    ENDELSE ;}
    n_kindat_parts = N_ELEMENTS( kindat_parts )
    kindat_pipe_list=STRING(kindat_parts[0])
    kindat_comma_list=STRING(kindat_parts[0])
    FOR i_kindat_parts=1ul, n_kindat_parts-1 DO BEGIN ;{
	kindat_pipe_list=kindat_pipe_list + '|' + STRCOMPRESS(STRING(kindat_parts[i_kindat_parts]),/REMOVE_ALL)
	kindat_comma_list=kindat_comma_list + ',' + STRCOMPRESS(STRING(kindat_parts[i_kindat_parts]),/REMOVE_ALL)
    ENDFOR ;}

    min_list='undef'
    max_list='undef'
    label_list='undef'
    if( onoff_list ne 'undef' ) then begin ;{
	onoff_parts=str_sep(onoff_list,'|',/TRIM)
	n_onoff_parts=n_elements(onoff_parts)
	for i_onoff_parts=1ul,(n_onoff_parts-1) do begin ;{
	    min_list=min_list+'|undef'
	    max_list=max_list+'|undef'
	    label_list=label_list+'|undef'
	endfor ;}
    endif ;}

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'onoff_list = ',onoff_list,'<BR />'
	PRINT,'min_list = ',min_list,'<BR />'
	PRINT,'max_list = ',max_list,'<BR />'
	PRINT,'label_list = ',label_list,'<BR />'
	PRINT,'<BR />'
    ENDIF ;}

    ;*********************************************************************
    ; determine the start time and end time
    ;*********************************************************************

    use_ndays=ndays
    if( sdt eq 'undef' ) then begin ;{
	shr='00'
	smn='00'

	smonth=month
	sday=day
	syear=year
	starting=JULDAY(string(month),string(day),string(year))
	ending=starting+use_ndays

	CALDAT, ending, emonth, eday, eyear
	ehr='23'
	emn='59'
    endif else begin ;} ;{
	s_parts=str_sep(sdt,'|',/TRIM)
	smonth=s_parts[0]
	sday=s_parts[1]
	syear=s_parts[2]
	st_parts=str_sep(s_parts[3],':',/TRIM)
	shr=st_parts[0]
	smn=st_parts[1]

	e_parts=str_sep(edt,'|',/TRIM)
	emonth=e_parts[0]
	eday=e_parts[1]
	eyear=e_parts[2]
	et_parts=str_sep(e_parts[3],':',/TRIM)
	ehr=et_parts[0]
	emn=et_parts[1]

	starting=JULDAY(string(smonth),string(sday),string(syear))
	ending=JULDAY(string(emonth),string(eday),string(eyear))
	use_ndays=ending-starting
	if( use_ndays le 0 ) then use_ndays = 1 else use_ndays=use_ndays+1
    endelse ;}

    if (smonth lt 10) then smonth='0'+string(smonth)
    if (emonth lt 10) then emonth='0'+string(emonth)
    smonth=strcompress(smonth,/REMOVE_ALL)
    emonth=strcompress(emonth,/REMOVE_ALL)

    if (sday lt 10) then sday='0'+string(sday)
    if (eday lt 10) then eday='0'+string(eday)
    sday=strcompress(sday,/REMOVE_ALL)
    eday=strcompress(eday,/REMOVE_ALL)

    syear=strcompress(syear,/REMOVE_ALL)
    eyear=strcompress(eyear,/REMOVE_ALL)

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'syear = ',syear,'<BR />'
	PRINT,'smonth = ',smonth,'<BR />'
	PRINT,'sday = ',sday,'<BR />'
	PRINT,'eyear = ',eyear,'<BR />'
	PRINT,'emonth = ',emonth,'<BR />'
	PRINT,'eday = ',eday,'<BR />'
	PRINT,'<BR />'
    ENDIF ;}

    ;*********************************************************************
    ; Figure out what parameters are required and put them into a single list
    ; without duplicates.
    ;
    ; paralist is the list of parameter codes to be requested from opendap.
    ;*********************************************************************
    build_param_struct,kinst,kindat_pipe_list,params,onoff_list,min_list,max_list,label_list,year,month,day,ndays,isplot,param_struct

    n_p_tags=n_tags(param_struct)

    paralist=0ul
    sparalist=''
    request=''
    IF ( isplot EQ 1ul ) THEN BEGIN ;{
	keep_count=0ul
	for i_p_tags=0ul,(n_p_tags-1) do begin ;{
	    curr_param=param_struct.(i_p_tags)
	    if ( curr_param.p_onoff eq 1 ) then begin ;{
		p_parts=str_sep(curr_param.p_requires,',',/TRIM)
		n_parts=n_elements(p_parts)
		for i_parts=0ul,(n_parts-1) do begin ;{
		    if (keep_count eq 0 and i_parts eq 0) then begin ;{
			paralist=[p_parts[i_parts]]
			sparalist=string(p_parts[i_parts])
			request=curr_param.name
		    endif else begin ;} ;{
			tryme=where(paralist eq p_parts[i_parts],tryme_count)
			if (tryme_count ne 1) then begin ;{
			    paralist=[paralist,p_parts[i_parts]]
			    sparalist=sparalist+'|'+string(p_parts[i_parts])
			    request=request+'|'+curr_param.name
			endif ;}
		    endelse ;}
		endfor ;}
		keep_count++
	    endif ;}
	endfor ;}
    ENDIF ELSE BEGIN ;{
	for i_p_tags=0ul,(n_p_tags-1) do begin ;{
	    curr_param=param_struct.(i_p_tags)
	    if( i_p_tags eq 0 ) then begin ;{
		paralist=[curr_param.p_code]
		sparalist=string(curr_param.p_code)
		request=strupcase(curr_param.name)
	    endif else begin ;}
		paralist=[paralist,curr_param.p_code]
		sparalist=sparalist+'|'+string(curr_param.p_code)
		request=request+'|'+strupcase(curr_param.name)
	    endelse ;}
	endfor ;}
    ENDELSE ;}
    n_paras=n_elements(paralist)

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'paralist = ',paralist,'<BR />'
	PRINT,'request = ',request,'<BR />'
	PRINT,'<BR />'
    ENDIF ;}

    IF ( isplot EQ 1ul ) THEN BEGIN ;{
	;*********************************************************************
	; If this didn't come from plotting then we already have the
	; madrigal names for the parameters, so no need to get them again.
	;
	; Now that we have the array of parameter codes in paralist, go get
	; the madrigal names of those parameter codes that needs to be
	; retrieved from the data
	;
	; paralist is the list of parameter codes that we will be requesting
	; from the opendap server
	;
	; request is the list of parameter names, the madrigal names, that
	; we will be requesting from the opendap server, but it is the codes
	; that is used in the opendap request
	;*********************************************************************
	query='SELECT DISTINCT concat(tbl_parameter_code.PARAMETER_ID,"%",tbl_parameter_code.MADRIGAL_NAME,"%",tbl_parameter_code.LONG_NAME) FROM tbl_parameter_code,tbl_record_info,tbl_record_type'

	query=query+' WHERE (1) AND tbl_parameter_code.PARAMETER_ID=tbl_record_info.PARAMETER_ID AND tbl_record_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND '

	for i=0ul,(n_paras-1) do begin
		if (i eq 0) then query=query+'(' else query=query+' OR '
		query=query+'(tbl_parameter_code.PARAMETER_ID='+paralist[i]+')'
	endfor

	query=query+') ORDER BY tbl_parameter_code.PARAMETER_ID'

	IF( debug GT 0UL ) THEN BEGIN ;{
	    PRINT,'madrigal query = ',query,'<BR />'
	    PRINT,'<BR />'
	ENDIF ;}

	cell=''

	rows=0ul
	columns=0ul
	results=0ul
	val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

	IF (val0 eq 0) THEN BEGIN ;{
	    FOR i=0ul,(rows-1) DO BEGIN ;{
		val1=GET_CELL (results,i,0ul,cell)
		IF (val1 eq 0) THEN BEGIN ;{
		    parts=str_sep(cell,'%',/TRIM)
		    paralist[i]=parts[0]
		    IF( i eq 0 ) THEN BEGIN ;{
			request=strupcase(parts[1])
		    ENDIF ELSE BEGIN ;} ;{
			request=request+'|'+strupcase(parts[1])
		    ENDELSE ;}
		ENDIF ;}
	    ENDFOR ;}
	ENDIF ;}

	val2=DESTROY_RESULT_SET(results)
    ENDIF ;}

    ;*********************************************************************
    ; Determine the day number given the month, day and year
    ;*********************************************************************
    query='SELECT DATE_ID from tbl_date WHERE YEAR =' + string(syear) + ' AND MONTH =' + string(smonth) + ' AND DAY =' + string(sday) +';'
    rows=0ul
    columns=0ul
    results=0ul
    date1=''
    date2='' 

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'day number query = ',query,'<BR />'
	PRINT,'<BR />'
    ENDIF ;}

    val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

    if (val0 eq 0) then begin
	val1=GET_CELL (results,0ul,0ul,date1)
	if (val1 eq 0) then begin
	    date2=date1+use_ndays
	endif
    endif

    val2=DESTROY_RESULT_SET(results)

    ;*********************************************************************
    ; Determine what files are needed for this query
    ;*********************************************************************

    query='SELECT DISTINCT tbl_cedar_file.FILE_NAME FROM tbl_date_in_file,tbl_cedar_file,tbl_file_info,tbl_record_type WHERE tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID and tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND (tbl_date_in_file.DATE_ID >= ' +string(date1) + ') AND (tbl_date_in_file.DATE_ID <=' + string(date2) + ') AND (tbl_record_type.KINST=' + string(kinst) + ') AND (((tbl_record_type.KINST=' + string(kinst) + ') AND (tbl_record_type.KINDAT IN (' + kindat_comma_list + '))));'

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'files query = ',query,'<BR />'
	PRINT,'<BR />'
    ENDIF ;}

    cell=''

    val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

    files=''
    if (val0 eq 0) then begin
	for i=0ul,(rows-1) do begin
	    val1=GET_CELL (results,i,0ul,cell)
	    if (val1 eq 0) then begin
		files=files+cell 
		if (i lt (rows-1)) then files=files+'|'
	    endif
	endfor
    endif

    val2=DESTROY_RESULT_SET(results)

    spaces='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
    PRINT,"stat=cedar_data(",kinst,",'",kindat_pipe_list,"'"
    PRINT,",$<BR />",spaces,"'",sparalist,"'"
    PRINT,",$<BR />",spaces,"'",request,"'"
    PRINT,",$<BR />",spaces,"'",files,"'"
    PRINT,",$<BR />",spaces,"'",syear,"','",smonth,"','",sday,"','",eyear,"','",emonth,"','",eday,"',"

end ;}

