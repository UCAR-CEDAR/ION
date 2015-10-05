pro plot_form,kinst,kindat,param_list,onoff_list,min_list,max_list,label_list,params,doform

    para_parts=str_sep(param_list,'|',/TRIM)
    n_para_parts=n_elements(para_parts)

    if ( onoff_list ne 'undef' ) then begin ;{
	onoff_parts=str_sep(onoff_list,'|',/TRIM)
	min_parts=str_sep(min_list,'|',/TRIM)
	max_parts=str_sep(max_list,'|',/TRIM)
	label_parts=str_sep(label_list,'|',/TRIM)
    endif ;}

    query='SELECT DISTINCT concat(tbl_parameter_code.PARAMETER_ID,"%",tbl_parameter_code.MADRIGAL_NAME,"%",tbl_parameter_code.LONG_NAME) FROM tbl_parameter_code,tbl_record_info,tbl_record_type'

    query=query+' WHERE (1) AND tbl_parameter_code.PARAMETER_ID=tbl_record_info.PARAMETER_ID AND tbl_record_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND '

    for i_para_parts=0ul,(n_para_parts-1) do begin
	    if (i_para_parts eq 0) then query=query+'(' else query=query+' OR '
	    query=query+'(tbl_parameter_code.PARAMETER_ID='+para_parts[i_para_parts]+')'
    endfor

    query=query+') ORDER BY tbl_parameter_code.PARAMETER_ID'

    cell=''
    rows=0ul
    columns=0ul
    results=0ul

    val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

    if (val0 eq 0) then begin ;{
	for i=0ul,(rows-1) do begin ;{
	    val1=GET_CELL (results,i,0ul,cell)
	    if (val1 eq 0) then begin ;{
		parts=str_sep(cell,'%',/TRIM)

		stmp={name:parts[1],p_code:parts[0],longname:parts[2],p_min:'',p_max:'',p_requires:'',p_label:'',p_onoff:1}

		if ( onoff_list ne 'undef' ) then begin ;{
		    try_index=where(para_parts eq parts[0])
		    stmp.p_min=min_parts[try_index[0]]
		    stmp.p_max=max_parts[try_index[0]]
		    stmp.p_label=label_parts[try_index[0]]
		    stmp.p_onoff=onoff_parts[try_index[0]]
		endif ;}

		if ( i eq 0 ) then begin ;{
		    params=create_struct(parts[1],stmp)
		endif else begin ;} ;{
		    params=create_struct(params,parts[1],stmp)
		endelse ;}
	    endif ;}
	endfor ;}
    endif ;}

    val2=DESTROY_RESULT_SET(results)

    query='SELECT concat(PARAMETER_ID,"%",requires,"%",default_label,"%",default_min,"%",default_max) from tbl_plotting_params WHERE KINST = '+string(kinst)+' AND KINDAT = '+string(kindat)+' AND '

    for i_para_parts=0ul,(n_para_parts-1) do begin
	    if (i_para_parts eq 0) then query=query+'(' else query=query+' OR '
	    query=query+'(PARAMETER_ID='+para_parts[i_para_parts]+')'
    endfor

    query=query+') ORDER BY PARAMETER_ID'

    cell=''
    rows=0ul
    columns=0ul
    results=0ul

    val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

    if (val0 eq 0) then begin ;{
	for i=0ul,(rows-1) do begin ;{
	    val1=GET_CELL (results,i,0ul,cell)
	    if (val1 eq 0) then begin ;{
		parts=str_sep(cell,'%',/TRIM)
		params.(i).p_requires=parts[1]
		if ( onoff_list eq 'undef' ) then begin ;{
		    params.(i).p_label=parts[2]
		    params.(i).p_min=parts[3]
		    params.(i).p_max=parts[4]
		endif ;}
	    endif ;}
	endfor ;}
    endif ;}

    val2=DESTROY_RESULT_SET(results)

    if ( doform eq 1 ) then begin ;{
	n_p_tags=n_tags(params)
	;*********************************************************************
	; Any parameters that aren't to be plotted should be displayed in
	; the top part of the table next to the plot text, with the check
	; boxes unchecked
	;*********************************************************************
	print,'<TR>'
	print,'<TD WIDTH="100%" HEIGHT="300" VALIGN="TOP">'
	anynot=0
	for i_p_tags=0ul,n_p_tags-1 do begin ;{
	    curr_param=params.(i_p_tags)
	    if ( curr_param.p_onoff eq 0 ) then begin ;{
		if( anynot eq 0 ) then begin ;{
		    print,'<DIV CLASS="mainctext">'
		    print,'Parameters not plotted<BR />(check to plot)'
		    print,'<BR /><BR />'
		    print,'<INPUT TYPE="SUBMIT" NAME="REPLOT" VALUE="RePlot" PERSIST="TRUE">'
		    print,'</DIV>'
		    print,'<BR /><BR />'
		endif else begin ;} ;{
		    print,'<DIV CLASS="mainltext">'
		    print,'<BR /><BR />'
		endelse ;}
		anynot=anynot+1
		print,'<INPUT TYPE="HIDDEN" NAME="PARAM_LIST" VALUE="',curr_param.p_code,'">'
		print,'<INPUT TYPE="CHECKBOX"> ',curr_param.p_code,' - ',curr_param.name
		print,'<INPUT TYPE="HIDDEN" NAME="MIN_LIST" VALUE="',curr_param.p_min,'">'
		print,'<INPUT TYPE="HIDDEN" NAME="MAX_LIST" VALUE="',curr_param.p_max,'">'
		print,'<INPUT TYPE="HIDDEN" NAME="LABEL_LIST" VALUE="',curr_param.p_label,'">'
		print,'<INPUT TYPE="HIDDEN" NAME="BOGUS">'
		print,'</DIV>'
	    endif ;}
	endfor ;}
	print,'</TD>'
	print,'</TR>'
	;*********************************************************************
	; Now display the form for the parameters that are being plotted,
	; with the min, max, and label and checkbox
	;*********************************************************************
	for i_p_tags=0ul,n_p_tags-1 do begin ;{
	    curr_param=params.(i_p_tags)
	    if ( curr_param.p_onoff ne 0 ) then begin ;{
		print,'<TR>'
		print,'<TD WIDTH="100%" VALIGN="CENTER" HEIGHT="300">'
		print,'<TABLE WIDTH="100%" CELLPADDING="1" CELLSPACING="1" BORDER="0">'
		print,'<TR>'
		print,'<TD WIDTH="100%">'
		print,'<DIV CLASS="mainltext">'
		print,curr_param.p_code,' - ',curr_param.name,'<BR />',curr_param.longname,'<BR />'
		print,'<INPUT TYPE="HIDDEN" NAME="PARAM_LIST" VALUE="',curr_param.p_code,'">'
		print,'</DIV>'
		print,'</TD>'
		print,'</TR>'
		print,'<TR> '
		print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
		print,'</TR>'
		print,'<TR>'
		print,'<TD WIDTH="100%">'
		print,'<DIV CLASS="mainltext">'
		print,'Plot this param <INPUT TYPE="CHECKBOX" CHECKED>'
		print,'</DIV>'
		print,'</TD>'
		print,'</TR>'
		print,'<TR> '
		print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
		print,'</TR>'
		print,'<TR>'
		print,'<TD WIDTH="100%">'
		print,'<DIV CLASS="mainltext">'
		print,'Min Value'
		print,'<BR />'
		print,'<INPUT TYPE="TEXT" NAME="MIN_LIST" VALUE="',curr_param.p_min,'" SIZE="10">'
		print,'</DIV>'
		print,'</TD>'
		print,'</TR>'
		print,'<TR> '
		print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
		print,'</TR>'
		print,'<TR>'
		print,'<TD WIDTH="100%">'
		print,'<DIV CLASS="mainltext">'
		print,'Max Value'
		print,'<BR />'
		print,'<INPUT TYPE="TEXT" NAME="MAX_LIST" VALUE="',curr_param.p_max,'" SIZE="10">'
		print,'</DIV>'
		print,'</TD>'
		print,'</TR>'
		print,'<TR> '
		print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
		print,'</TR>'
		print,'<TR>'
		print,'<TD WIDTH="100%">'
		print,'<DIV CLASS="mainltext">'
		print,'Label'
		print,'<BR />'
		print,'<INPUT TYPE="TEXT" NAME="LABEL_LIST" VALUE="',curr_param.p_label,'" SIZE="20">'
		print,'</DIV>'
		print,'</TD>'
		print,'</TR>'
		print,'<TR> '
		print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
		print,'</TR>'
		print,'<TR>'
		print,'<TD WIDTH="100%">'
		print,'<DIV CLASS="mainltext">'
		print,'<BR />'
		print,'<INPUT TYPE="SUBMIT" NAME="REPLOT" VALUE="RePlot" PERSIST="TRUE">'
		print,'</DIV>'
		print,'</TD>'
		print,'</TR>'
		print,'</TABLE>'
		print,'</TD>'
		print,'</TR>'
	    endif ;}
	endfor ;}
    endif ;}
end

