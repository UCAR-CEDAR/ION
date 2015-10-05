pro doplot,kinst,kindats,params,year,month,day,ndays,sdt,edt,doingprint,debug
;{

IF( debug GT 0ul ) THEN BEGIN ;{
    OPENW,12,'/project/cedar/src/pwest/apache/ion/doplot.out'
ENDIF ;}

n_p_tags=N_TAGS(params)

IF ( kindats EQ 'undef' ) THEN BEGIN ;{
    GET_KINDAT_LIST,kinst,1ul,kindat_parts
ENDIF ELSE BEGIN ;} ;{
    kindat_parts = STR_SEP( kindats, '|', /TRIM )
ENDELSE ;}
n_kindat_parts = N_ELEMENTS( kindat_parts )

kindat_list = ''
kinst_kindat_list = ''
FOR i=0ul,(n_kindat_parts-1) DO BEGIN ;{
    IF( i NE 0ul ) THEN BEGIN ;{
	kindat_list += ','
	kinst_kindat_list += ','
    ENDIF ;}
    kindat_list += STRING( kindat_parts[i] )
    kinst_kindat_list += STRING( kinst) + '/' + STRING( kindat_parts[i] )
ENDFOR ;}

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,''
    PRINTF,12,'kinst = ',kinst
    PRINTF,12,'kindats = ',kindats
    PRINTF,12,'kindat_list = ',kindat_list
    FOR i_p_tags=0ul,(n_p_tags-1) DO BEGIN ;{
	curr_param=params.(i_p_tags)
	PRINTF,12,curr_param.p_code,' - ',curr_param.name,' - ',curr_param.longname
	PRINTF,12,' : min = ',curr_param.p_min
	PRINTF,12,' : max = ',curr_param.p_max
	PRINTF,12,' : requires = ',curr_param.p_requires
	PRINTF,12,' : func = ',curr_param.p_func
	PRINTF,12,' : independent func = ',curr_param.i_func
	PRINTF,12,' : label = ',curr_param.p_label
	PRINTF,12,' : onoff = ',curr_param.p_onoff
	PRINTF,12,''
    ENDFOR ;}
    PRINTF,12,''
ENDIF ;}

;*********************************************************************
; determine the start time and end time
;*********************************************************************

use_ndays=ndays
IF( sdt EQ 'undef' ) THEN BEGIN ;{
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
    use_ndays=use_ndays+1
ENDIF ELSE BEGIN ;} ;{
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

    starting=JULDAY(STRING(smonth),STRING(sday),STRING(syear))
    ending=JULDAY(STRING(emonth),STRING(eday),STRING(eyear))
    use_ndays=ending-starting
    IF( use_ndays LE 0 ) THEN use_ndays = 1 ELSE use_ndays=use_ndays+1
ENDELSE ;}
beginning=JULDAY('1','1',STRING(syear))
calc_doy=starting-beginning+1

IF( smonth LT 10 ) THEN smonth='0'+STRING(smonth)
IF( emonth LT 10 ) THEN emonth='0'+STRING(emonth)
smonth=STRCOMPRESS( smonth, /REMOVE_ALL )
emonth=STRCOMPRESS( emonth, /REMOVE_ALL )

IF( sday LT 10 ) THEN sday='0'+STRING( sday )
IF( eday LT 10 ) THEN eday='0'+STRING( eday )
sday=STRCOMPRESS( sday, /REMOVE_ALL )
eday=STRCOMPRESS( eday, /REMOVE_ALL )

syear=STRCOMPRESS( syear, /REMOVE_ALL )
eyear=STRCOMPRESS( eyear, /REMOVE_ALL )

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'smonth = ',smonth
    PRINTF,12,'sday = ',sday
    PRINTF,12,'syear = ',syear
    PRINTF,12,'shr = ',shr
    PRINTF,12,'smn = ',smn
    PRINTF,12,'emonth = ',emonth
    PRINTF,12,'eday = ',eday
    PRINTF,12,'eyear = ',eyear
    PRINTF,12,'ehr = ',ehr
    PRINTF,12,'emn = ',emn
    PRINTF,12,'use_ndays = ',use_ndays
    PRINTF,12,''
ENDIF ;}

;*********************************************************************
; create the string representing the instrument
;*********************************************************************

query='SELECT DISTINCT concat(tbl_instrument.INST_NAME,"%",tbl_instrument.PREFIX,"%",tbl_instrument.KINST) FROM tbl_instrument WHERE tbl_instrument.KINST='+STRING(kinst)

rows=0ul
columns=0ul
results=0ul
cell=''
print_instrument='Instrument: '

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

IF (val0 EQ 0) THEN BEGIN ;{
    val1=GET_CELL (results,0ul,0ul,cell)
    IF (val1 eq 0) THEN BEGIN ;{
	part=str_sep(cell,'%',/TRIM)
	print_instrument=print_instrument+part[2]+' - '+part[0]
    ENDIF ;}
ENDIF ;}

val2=DESTROY_RESULT_SET(results)

;*********************************************************************
; create the string representing the record type
;*********************************************************************

query='SELECT DISTINCT concat(KINST,"%",KINDAT,"%",DESCRIPTION) FROM tbl_record_type'

query = query + ' WHERE KINST=' + STRING( kinst )
query = query + ' AND KINDAT IN (' + kindat_list +')'

rows=0ul
columns=0ul
results=0ul
cell=''
print_record=0ul

val0 = LOAD_CATALOG_QUERY( query, rows, columns, results )

IF( val0 EQ 0 ) THEN BEGIN ;{
    FOR i=0ul, (rows - 1) DO BEGIN ;{
	val1 = GET_CELL( results, i, 0ul, cell )
	IF( val1 EQ 0 ) THEN BEGIN ;{
	    part = str_sep( cell, '%', /TRIM )
	    newstr = '    ' + part[0] + '/' +part[1] + ' - ' + part[2]
	    IF( i EQ 0ul ) THEN BEGIN ;{
		print_record = [newstr]
	    ENDIF ELSE BEGIN ;} ;{
		print_record = [print_record, newstr]
	    ENDELSE ;}
	ENDIF ;}
    ENDFOR ;}
ENDIF ;}
print_record_count = N_ELEMENTS( print_record )

val2=DESTROY_RESULT_SET(results)

;*********************************************************************
; Figure out what parameters are required and put them into a single list
; without duplicates. Also put in order the parameter codes, labels, min
; values, max values, and parameter info string of the parameters to be
; plotted.
;
; paralist is the list of parameter codes to be requested from opendap.
; para_parts is the list of parameter codes to be plotted
; label_parts is the list of labels for the parameters to be plotted
; min_parts is the list of min values for the parameters to be plotted
; max_parts is the list of max values for the parameters to be plotted
; print_params is the list of info for the parameters to be plotted
;*********************************************************************
paralist=0ul
para_parts=0ul
label_parts=0ul
min_parts=0ul
max_parts=0ul
print_params=0ul
keep_count=0ul
FOR i_p_tags=0ul,(n_p_tags-1) DO BEGIN ;{
    curr_param=params.(i_p_tags)
    IF ( curr_param.p_onoff EQ 1 ) THEN BEGIN ;{
	IF ( keep_count EQ 0 ) THEN BEGIN ;{
	    para_parts=[curr_param.p_code]
	    func_parts=[curr_param.p_func]
	    ifunc_parts=[curr_param.i_func]
	    label_parts=[curr_param.p_label]
	    min_parts=[curr_param.p_min]
	    max_parts=[curr_param.p_max]
	    print_params=['    '+curr_param.p_code+' - '+curr_param.name+' - '+curr_param.longname]
	ENDIF ELSE BEGIN ;} ;{
	    para_parts=[para_parts,curr_param.p_code]
	    func_parts=[func_parts,curr_param.p_func]
	    ifunc_parts=[ifunc_parts,curr_param.i_func]
	    label_parts=[label_parts,curr_param.p_label]
	    min_parts=[min_parts,curr_param.p_min]
	    max_parts=[max_parts,curr_param.p_max]
	    print_params=[print_params,'    '+curr_param.p_code+' - '+curr_param.name+' - '+curr_param.longname]
	ENDELSE ;}
	p_parts=str_sep(curr_param.p_requires,',',/TRIM)
	n_parts=N_ELEMENTS(p_parts)
	FOR i_parts=0ul,(n_parts-1) DO BEGIN ;{
	    IF (keep_count EQ 0 AND i_parts EQ 0) THEN BEGIN ;{
		paralist=[p_parts[i_parts]]
	    ENDIF ELSE BEGIN ;} ;{
		tryme=WHERE(paralist eq p_parts[i_parts],tryme_count)
		IF (tryme_count NE 1) THEN BEGIN ;{
		    paralist=[paralist,p_parts[i_parts]]
		ENDIF ;}
	    ENDELSE ;}
	ENDFOR ;}
	keep_count++
    ENDIF ;}
ENDFOR ;}
n_paras=N_ELEMENTS(paralist)
n_para_parts=N_ELEMENTS(para_parts)

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'paralist = ',paralist
    PRINTF,12,'para_parts = ',para_parts
    PRINTF,12,''
ENDIF ;}

;*********************************************************************
; Now that we have the array of parameter codes in paralist, go get the
; madrigal names of those parameter codes that needs to be retrieved from
; the data
;
; paralist is the list of parameter codes that we will be requesting from
; the opendap server
;
; request is the list of parameter names, the madrigal names, that we will
; be requesting from the opendap server, but it is the codes that is used in
; the opendap request
;*********************************************************************
query='SELECT DISTINCT concat(tbl_parameter_code.PARAMETER_ID,"%",tbl_parameter_code.MADRIGAL_NAME,"%",tbl_parameter_code.LONG_NAME) FROM tbl_parameter_code,tbl_record_info,tbl_record_type'

query=query+' WHERE (1) AND tbl_parameter_code.PARAMETER_ID=tbl_record_info.PARAMETER_ID AND tbl_record_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND '

FOR i=0ul,(n_paras-1) DO BEGIN ;{
	IF (i EQ 0) THEN query=query+'(' ELSE query=query+' OR '
	query=query+'(tbl_parameter_code.PARAMETER_ID='+paralist[i]+')'
ENDFOR ;}

query=query+') ORDER BY tbl_parameter_code.PARAMETER_ID'

cell=''
request=STRARR(n_paras)

rows=0ul
columns=0ul
results=0ul
val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

IF (val0 EQ 0) THEN BEGIN ;{
    FOR i=0ul,(rows-1) DO BEGIN ;{
	val1=GET_CELL (results,i,0ul,cell)
	IF (val1 EQ 0) THEN BEGIN ;{
	    parts=str_sep(cell,'%',/TRIM)
	    paralist[i]=parts[0]
	    request[i]=STRUPCASE(parts[1])
	ENDIF ;}
    ENDFOR ;}
ENDIF ;}
IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'paralist = ',paralist
    PRINTF,12,'request = ',request
    PRINTF,12,''
ENDIF ;}

val2=DESTROY_RESULT_SET(results)

;*********************************************************************
; Determine the day number given the month, day and year
;*********************************************************************
query='SELECT DATE_ID from tbl_date WHERE YEAR =' + STRING(syear) + ' AND MONTH =' + STRING(smonth) + ' AND DAY =' + STRING(sday) +';'
rows=0ul
columns=0ul
results=0ul
date1=''
date2='' 

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

IF (val0 EQ 0) THEN BEGIN ;{
    val1=GET_CELL (results,0ul,0ul,date1)
    IF (val1 EQ 0) THEN BEGIN ;{
        date2=date1+use_ndays
    ENDIF ;}
ENDIF ;}

val2=DESTROY_RESULT_SET(results)

;*********************************************************************
; create the date strings to display in the plot
;*********************************************************************
months=['January',$
	'February',$
	'March',$
	'April',$
	'May',$
	'June',$
	'July',$
	'August',$
	'September',$
	'October',$
	'November',$
	'December']
print_start_date='Starting: '+months[smonth-1]+' '+STRING(sday)+', '+STRING(syear)
print_end_date='Ending: '+months[emonth-1]+' '+STRING(eday)+', '+STRING(eyear)

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'print_start_date = ',print_start_date
    PRINTF,12,'print_end_date = ',print_end_date
    PRINTF,12,''
ENDIF ;}

;*********************************************************************
; Determine what files are needed for this query
;*********************************************************************

query='SELECT DISTINCT tbl_cedar_file.FILE_NAME FROM tbl_date_in_file,tbl_cedar_file,tbl_file_info,tbl_record_type WHERE tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID and tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND (tbl_date_in_file.DATE_ID >= ' +STRING(date1) + ') AND (tbl_date_in_file.DATE_ID <=' + STRING(date2) + ') AND (tbl_record_type.KINST=' + STRING(kinst) + ') AND (((tbl_record_type.KINST=' + STRING(kinst) + ') AND (tbl_record_type.KINDAT IN (' + kindat_list + '))));'

cell=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

;*********************************************************************
; Now we are going to build the url for the das and the url for the dods
; request.
;*********************************************************************
dat1='.constraint=%22'
dat1=dat1+'date('+STRING(syear)+','+STRING(smonth)+STRING(sday)+','+STRING(shr)+STRING(smn)+',0,'
dat1=dat1+STRING(eyear)+','+STRING(emonth)+STRING(eday)+','+STRING(ehr)+STRING(emn)+',5999);'
dat1=dat1+'record_type('+kinst_kindat_list+');parameters('
dat2=STRCOMPRESS(dat1,/remove_all)

dasurl=''
IF (val0 EQ 0) THEN BEGIN ;{
    dasurl=dasurl+'http://cedarweb.hao.ucar.edu/opendap?username=opendap_idl&request=define+silently+d+as+'
    FOR i=0ul,(rows-1) DO BEGIN ;{
        val1=GET_CELL (results,i,0ul,cell)
        IF (val1 EQ 0) THEN BEGIN ;{
            dasurl=dasurl+cell 
            IF (i LT (rows-1)) THEN dasurl=dasurl+',' ELSE dasurl=dasurl+';'
        ENDIF ;}
    ENDFOR ;}
    dasurl=dasurl+'get+das+for+d;'
ENDIF ;}

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'dasurl = ',dasurl
    PRINTF,12,''
ENDIF ;}

url=''
IF (val0 EQ 0) THEN BEGIN ;{
    url=url+'http://cedarweb.hao.ucar.edu/opendap?username=opendap_idl&request=define+silently+d+as+'
    constraint=''
    FOR i=0ul,(rows-1) DO BEGIN ;{
        val1=GET_CELL (results,i,0ul,cell)
        IF (val1 EQ 0) THEN BEGIN ;{
	    url=url+cell
	    constraint=constraint+cell+dat2
	    FOR j=0ul,(n_paras-1) DO BEGIN ;{
	      constraint=constraint+STRING(paralist[j])
	      IF (n_paras NE 0ul AND (j GE 0ul) AND (j LT (n_paras-1))) THEN constraint=constraint+','
	    ENDFOR ;}
	    constraint=constraint+')%22'
	    IF (i LT (rows-1)) THEN constraint=constraint+','
            IF (i LT (rows-1)) THEN url=url+',' ELSE url=url+'+with+'+constraint
        ENDIF ;}
    ENDFOR ;}
    url=url+';'
    url=url+'get+dods+for+d;'
ENDIF ;}

val2=DESTROY_RESULT_SET(results)

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'url = ',url
    PRINTF,12,''
ENDIF ;}

;*********************************************************************
; Now let's go get the OPeNDAP das object and parse through it. We only want
; to fill in the parcods, reqcods, longnames, scales and units for the
; parameters that we will retrieve into the OPeNDAP data object.
;*********************************************************************
IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'getting das'
    PRINTF,12,''
ENDIF ;}
stat=get_dods(dasurl,das,mode='fulldas')
IF (stat NE 1) THEN BEGIN ;{
    PRINT,'Problem getting the OPeNDAP das object, exiting'
ENDIF ;}

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'parsing das'
    PRINTF,12,''
ENDIF ;}
stat=opendap_parse_das(das,kinst,kindat_parts,paralist,request,code,site,latitude,longitude,elev,parcods,reqcods,longnames,scales,units)
IF (stat NE 1) THEN BEGIN ;{
    PRINT,'Problem parsing the OPeNDAP das object, exiting'
ENDIF ;}

plot_title=STRING(FORMAT='(%"%s - %s - %s %s %f")',code,site,latitude,longitude,elev)

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'parcods = ',parcods
    PRINTF,12,'reqcods = ',reqcods
    PRINTF,12,'longnames = ',longnames
    PRINTF,12,'scales = ',scales
    PRINTF,12,'units = ',units
    PRINTF,12,'plot_title = ',plot_title
    PRINTF,12,''
ENDIF ;}

;*********************************************************************
; Go get the OPeNDAP data object, retrieving only the parameter codes
; required for the plottable points
;*********************************************************************
IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,12,'calling get_dods'
    PRINTF,12,'get_dods(',url,',data,mode=fulldata)'
    PRINTF,12,''
ENDIF ;}
err_msg='undef'
data=CREATE_STRUCT('undef',0)
stat=get_dods(url,data,mode='fulldata')

IF (stat NE 1) THEN BEGIN ;{
    IF( debug GT 0ul ) THEN BEGIN ;{
	PRINTF,12,'Problem getting the OPeNDAP data object'
    ENDIF ;}
    err_msg='Problem getting the OPeNDAP data object'
ENDIF ELSE BEGIN ;} ;{
    n_data=N_TAGS(data)
    t_data=TAG_NAMES(data)
    IF (n_data EQ 1 AND t_data[0] EQ 'UNDEF') THEN BEGIN ;{
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,12,'No data available for specified date range and params'
	ENDIF ;}
	err_msg='No data available for specified date range and parameters'
    ENDIF ELSE BEGIN ;} ;{

	;*********************************************************************
	; Aggregate the data. Again, we are only aggregating the parameters
	; required for this plot, not all of the parameters in the data
	; containers.
	;*********************************************************************
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,12,'calling aggregate'
	    PRINTF,12,''
	ENDIF ;}
	aggregate,data,kinst,kindat_parts,reqcods,longnames,scales,units,p
	;if (stat ne 1) THEN BEGIN ;{
	;    print,'Problem aggregating the OPeNDAP data object, exiting'
	;ENDIF ;}

	;*********************************************************************
	; Time to plot
	;*********************************************************************

	;*********************************************************************
	; determine the parameter names that we are going to be plotting
	;*********************************************************************
	req_parts=STRARR(n_para_parts)
	unit_parts=STRARR(n_para_parts)
	FOR i=0ul,(n_para_parts-1) DO BEGIN ;{
	    para_index=where(parcods eq para_parts[i],para_count)
	    IF (para_count EQ 1) THEN BEGIN ;{
		req_parts[i]=reqcods[para_index]
		unit_parts[i]=units[para_index]
	    ENDIF ;}
	ENDFOR ;}

	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,12,''
	    PRINTF,12,'para_parts = ',para_parts
	    PRINTF,12,'req_parts = ',req_parts
	    PRINTF,12,'label_parts = ',label_parts
	    PRINTF,12,'min_parts = ',min_parts
	    PRINTF,12,'max_parts = ',max_parts
	    PRINTF,12,'parcods = ',parcods
	    PRINTF,12,'reqcods = ',reqcods
	    PRINTF,12,''
	ENDIF ;}
    ENDELSE ;}
ENDELSE ;}

n_para_parts=N_ELEMENTS(para_parts)
print_para_count=N_ELEMENTS(print_params)

UTfirst = starting
UTlast = starting + use_ndays

IF ( doingprint EQ 0 ) THEN BEGIN ;{
    !p.multi= [0,1,n_para_parts+1]
ENDIF ELSE BEGIN ;} ;{
    !p.multi= [0,1,1]
ENDELSE ;}
!y.style=1
!x.style=1
!x.margin=[20,6]
!y.charsize=1.5
!x.charsize= 1.5

;Set up some color
colortable = 33
TVLCT, oldr,oldg,oldb,/GET
IF( N_Elements(colortable) EQ 1 ) THEN BEGIN ;{
    LOADCT, colortable, /silent
    TVLCT, r,g,b,/GET
    r[0]=0 & r[255]=255
    g[0]=0 & g[255]=255
    b[0]=0 & b[255]=255
    colortable=[[r],[g],[b]]
ENDIF ;}
TVLCT, colortable
;*********************************************************************
; Let's create some space for some text
;*********************************************************************
print_yticks=print_para_count+5
dummy=[0,0]
PLOT,dummy,dummy,MAX_VALUE=99998.,$
     yrange=[0,40],$
     ymargin=[0,0],$
     xrange=[UTfirst,UTlast],$
     xmargin=[0,0],$
     ystyle=4,$
     xstyle=4,$
     background=255,$
     color=0
print_position=35
XYOUTS,UTfirst,print_position,print_instrument,color=0
print_position=print_position-2
XYOUTS,UTfirst,print_position,'Operating Modes:',color=0
print_position=print_position-2
print_record_color=0
FOR i=0ul,(print_record_count-1) DO BEGIN ;{
    XYOUTS,UTfirst,print_position,print_record[i],color=print_record_color
    print_position=print_position-2
    print_record_color+=40
ENDFOR ;}
XYOUTS,UTfirst,print_position,'Parameters:',color=0
print_position=print_position-2
FOR i=0ul,(print_para_count-1) DO BEGIN ;{
    XYOUTS,UTfirst,print_position,print_params[i],color=0
    print_position=print_position-2
ENDFOR ;}
XYOUTS,UTfirst,print_position,print_start_date,color=0
print_position=print_position-2
XYOUTS,UTfirst,print_position,print_end_date,color=0
print_position=print_position-4
XYOUTS,UTfirst,print_position,'These plots are produced for visual browsing of the data and should not',color=0
print_position=print_position-2
XYOUTS,UTfirst,print_position,'be used in publications without citing the data provider and CEDARWEB.',color=0

IF( err_msg NE 'undef' ) THEN BEGIN ;{
    print_position=print_position-4
    XYOUTS,UTfirst,print_position,err_msg,color=0
ENDIF ELSE BEGIN ;} ;{

    ;*********************************************************************
    ; for each parameter name, get the data and plot it using the plotting
    ; function specified in the database for that parameter
    ;*********************************************************************
    FOR i=0ul,(n_para_parts-1) DO BEGIN ;{
	p_min=FLOAT(min_parts[i])
	p_max=FLOAT(max_parts[i])
	p_label=label_parts[i]+' ('+unit_parts[i]+')'
	p_func=func_parts[i]
	i_func=ifunc_parts[i]
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,12,'plotting ',print_params[i]
	    PRINTF,12,'  print_params = ',print_params
	    PRINTF,12,'  req_parts = ',req_parts
	    PRINTF,12,'  use_ndays = ',use_ndays
	    PRINTF,12,'  beginning = ',beginning
	    PRINTF,12,'  starting = ',starting
	    PRINTF,12,'  p_min = ',p_min
	    PRINTF,12,'  p_max = ',p_max
	    PRINTF,12,'  p_label = ',p_label
	    PRINTF,12,'  p_func = ',p_func
	    PRINTF,12,'  i_func = ',i_func
	    PRINTF,12,'  !p.multi = ',!p.multi
	    PRINTF,12,''
	ENDIF ;}
	did_plot = 0ul
	FOR k=0ul, ( n_kindat_parts - 1 ) DO BEGIN ;{
	    CALL_PROCEDURE,p_func,data,p,i,print_params,k,kindat_parts,$
	                          req_parts,i_func,$
				  use_ndays,beginning,starting,$
				  p_min,p_max,p_label,doingprint,$
				  did_plot,debug
	ENDFOR ;}
	IF( did_plot EQ 0ul ) THEN BEGIN ;{
	    dummy=[0,0]
	    doy_start = starting - beginning + 1
	    doy_end = doy_start + use_ndays
	    PLOT,dummy,dummy,MAX_VALUE=99998.,$
		 xrange=[doy_start,doy_end],$
		 yrange=[0,40],$
		 ymargin=[0,0],$
		 xmargin=[0,0],$
		 ystyle=4,$
		 xstyle=4,$
		 background=255,$
		 color=0
	    print_position=35
	    print_not_there=print_params[i]+' - no data to plot'
	    XYOUTS,doy_start,print_position,print_not_there,color=0
	ENDIF ;}
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,12,'done plotting ',print_params[i]
	ENDIF ;}
    ENDFOR ;}
ENDELSE ;}

IF( debug GT 0ul ) THEN BEGIN ;{
    CLOSE,12
ENDIF ;}

;}
END

