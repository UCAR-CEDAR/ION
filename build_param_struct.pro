PRO build_param_struct,kinst,kindat_list,param_list,onoff_list,min_list,max_list,label_list,year,month,day,ndays,isplot,params
;{
    ;OPENW,14,'/project/cedar/src/pwest/apache/ion/build_param_struct.out'
    ;PRINTF,14,'kinst = ',kinst
    ;PRINTF,14,'kindat_list = ',kindat_list
    ;PRINTF,14,'param_list = ',param_list
    ;PRINTF,14,'onoff_list = ',onoff_list
    ;PRINTF,14,'min_list = ',min_list
    ;PRINTF,14,'max_list = ',max_list
    ;PRINTF,14,'label_list = ',label_list
    ;PRINTF,14,'year = ',year
    ;PRINTF,14,'month = ',month
    ;PRINTF,14,'day = ',day
    ;PRINTF,14,'ndays = ',ndays
    ;PRINTF,14,'isplot = ',isplot
    ;CLOSE,14

;*********************************************************************
; Builds a parameter structure for each request parameter. The structure
; will look like:
;*********************************************************************

;*********************************************************************
; Determine the kindat list. If the kindat list is undef then find all
; of the operating modes for the given kinst. Otherwise, use the '|'
; separated list in kindat
;*********************************************************************
    IF ( kindat_list EQ 'undef' ) THEN BEGIN ;{
	GET_KINDAT_LIST,kinst,isplot,kindat_parts
    ENDIF ELSE BEGIN ;} ;{
	kindat_parts = STR_SEP( kindat_list, '|', /TRIM )
    ENDELSE ;}
    n_kindat_parts = N_ELEMENTS( kindat_parts )

;*********************************************************************
; Determine the parameter list. If the parameter list comes in with
; param_list then we know the parameter list. If param_list is undef then no
; parameters have been selected yet, so go get all the parameters for the
; given situation. There are two different situations. The first is if we
; are plotting. If we are plotting then get the list of parameters from the
; plotting parameter table. If we are NOT plotting then get the list of all
; parameters for the given variables.
;*********************************************************************
    IF ( param_list NE 'undef' ) THEN BEGIN ;{
	para_parts = STR_SEP( param_list, '|', /TRIM )
	n_para_parts = N_ELEMENTS( para_parts )

	IF ( onoff_list NE 'undef' ) THEN BEGIN ;{
	    onoff_parts = STR_SEP( onoff_list, '|', /TRIM )
	    min_parts = STR_SEP( min_list, '|', /TRIM )
	    max_parts = STR_SEP( max_list, '|', /TRIM )
	    label_parts = STR_SEP( label_list, '|', /TRIM )
	ENDIF ;}
    ENDIF ELSE BEGIN ;} ;{
	GET_PARAM_LIST,kinst,kindat_parts,year,month,day,ndays,isplot,param_avail
	n_para_parts = N_ELEMENTS( param_avail )
	FOR i_param_list=0ul,(n_para_parts-1) DO BEGIN ;{
	    a_param = param_avail[i_param_list]
	    part = str_sep( a_param, '%', /TRIM )
	    IF( i_param_list EQ 0ul ) THEN BEGIN ;{
		para_parts = [part[0]]
	    ENDIF ELSE BEGIN ;} ;{
		para_parts = [para_parts,part[0]]
	    ENDELSE ;}
	ENDFOR ;}
    ENDELSE ;}

;*********************************************************************
; Now we go get the parameter code and longname from the appropriate tables
; and begin to build our parameter structure. If the we have information
; such as onoff, min, max and label then fill in that part. We know we have
; this information if onoff_list is not equal to 'undef'
;*********************************************************************

    query='SELECT DISTINCT concat(tbl_parameter_code.PARAMETER_ID,"%",tbl_parameter_code.MADRIGAL_NAME,"%",tbl_parameter_code.LONG_NAME) FROM tbl_parameter_code,tbl_record_info,tbl_record_type'

    query=query+' WHERE (1) AND tbl_parameter_code.PARAMETER_ID=tbl_record_info.PARAMETER_ID AND tbl_record_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND '

    FOR i_para_parts=0ul,(n_para_parts-1) DO BEGIN ;{
	    IF( i_para_parts EQ 0 ) THEN query=query+'(' ELSE query=query+' OR '
	    query=query+'(tbl_parameter_code.PARAMETER_ID='+para_parts[i_para_parts]+')'
    ENDFOR ;}

    query=query+') ORDER BY tbl_parameter_code.PARAMETER_ID'

    cell=''
    rows=0ul
    columns=0ul
    results=0ul

    val0 = LOAD_CATALOG_QUERY( query, rows, columns, results )

    IF( val0 EQ 0 ) THEN BEGIN ;{
	FOR i=0ul,(rows-1) DO BEGIN ;{
	    val1 = GET_CELL( results, i, 0ul, cell )
	    IF( val1 EQ 0 ) THEN BEGIN ;{
		parts = STR_SEP( cell, '%', /TRIM )

		stmp = {name:parts[1],p_code:parts[0],longname:parts[2],p_min:'',p_max:'',p_requires:'',p_label:'',p_onoff:1,p_func:'',i_func:''}

		IF( onoff_list NE 'undef' ) THEN BEGIN ;{
		    try_index = WHERE( para_parts EQ parts[0] )
		    stmp.p_min = min_parts[try_index[0]]
		    stmp.p_max = max_parts[try_index[0]]
		    stmp.p_label = label_parts[try_index[0]]
		    stmp.p_onoff = onoff_parts[try_index[0]]
		ENDIF ;}

		IF( i EQ 0 ) THEN BEGIN ;{
		    params = CREATE_STRUCT( parts[1], stmp )
		ENDIF ELSE BEGIN ;} ;{
		    params = CREATE_STRUCT( params, parts[1], stmp )
		ENDELSE ;}
	    ENDIF ;}
	ENDFOR ;}
    ENDIF ;}

    val2 = DESTROY_RESULT_SET( results )

;*********************************************************************
; If we are plotting then we need to get the required parameters for the
; plot. We don't need any information about those parameters, we just need
; to get the data for those parameters. If there is no information in the
; onoff_list, min_list, max_list or label_list then set the onoff to on and
; get the default min, max and label.
;*********************************************************************

    IF( isplot EQ 1ul ) THEN BEGIN ;{

	kindat_comma_list = ''
	FOR i_kindat_parts=0ul,(n_kindat_parts-1) DO BEGIN ;{
	    IF( i_kindat_parts NE 0ul ) THEN kindat_comma_list += ','
	    kindat_comma_list += STRING( kindat_parts[i_kindat_parts] )
	ENDFOR ;}

	para_comma_list = ''
	FOR i_para_parts=0ul,(n_para_parts-1) DO BEGIN ;{
	    IF( i_para_parts NE 0ul ) THEN para_comma_list += ','
	    para_comma_list += STRING( para_parts[i_para_parts] )
	ENDFOR ;}

	query='SELECT concat(PARAMETER_ID,"%",requires,"%",plot_func,"%",ind_func,"%",default_label,"%",default_min,"%",default_max)'
	query += ' FROM tbl_plotting_params'
	query += ' WHERE KINST = ' + STRING( kinst )
	query += ' AND KINDAT IN (' + kindat_comma_list + ')'
	query += ' AND PARAMETER_ID IN (' + para_comma_list + ')'
	query += ' ORDER BY PARAMETER_ID'

	cell=''
	rows=0ul
	columns=0ul
	results=0ul

	val0 = LOAD_CATALOG_QUERY( query, rows, columns, results )

	IF( val0 EQ 0 ) THEN BEGIN ;{
	    i_params = 0ul
	    FOR i=0ul,(rows-1) DO BEGIN ;{
		val1 = GET_CELL( results, i, 0ul, cell )
		IF( val1 EQ 0 ) THEN BEGIN ;{
		    parts = STR_SEP( cell, '%', /TRIM )
		    same = 1ul
		    WHILE( parts[0] NE params.(i_params).p_code ) DO BEGIN ;{
			i_params = i_params + 1
			same = 0ul
		    ENDWHILE ;}
		    IF( same EQ 0ul OR i EQ 0ul ) THEN BEGIN ;{
			params.(i_params).p_requires = parts[1]
			params.(i_params).p_func = parts[2]
			params.(i_params).i_func = parts[3]
			IF( onoff_list EQ 'undef' ) THEN BEGIN ;{
			    params.(i_params).p_label = parts[4]
			    params.(i_params).p_min = parts[5]
			    params.(i_params).p_max = parts[6]
			ENDIF ;}
		    ENDIF ELSE BEGIN ;} ;{
			IF( params.(i_params).p_requires NE '' ) THEN BEGIN ;{
			    params.(i_params).p_requires += ','
			ENDIF ;}
			params.(i_params).p_requires += parts[1]
		    ENDELSE ;}
		ENDIF ;}
	    ENDFOR ;}
	ENDIF ;}

	val2=DESTROY_RESULT_SET(results)
    ENDIF ;}
;}
END

