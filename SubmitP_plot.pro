pro SubmitP_plot, kinst, kindat, parameter, year, month, day, ndays

;*********************************************************************
; Make sure that all of the incoming parameters are acceptable
;*********************************************************************
if (kinst LT 0) then begin
    print, 'Error: instrument is a negative value'
    return
endif

if (year LT 0) then begin
    print, 'Error: year is a negative value of' 
    print, year
    return
endif

if (month LT 0) then begin
    print, 'Error: month is a negative value of' 
    print, month
    return
endif

if (day LT 0) then begin
    print, 'Error: day is a negative value of' 
    print, day
    return
endif

if (ndays LT 0) then begin
    print, 'Error: Number of days is a negative value of' 
    print, ndays
    return
endif

;*********************************************************************
; the parameters come in as a '|' separated list of parameter codes,
; separate them out and put them in an array called parts
;*********************************************************************
parts=str_sep(parameter,'|',/TRIM)
result=N_ELEMENTS(parts)

;*********************************************************************
; We want the list of parameters that the user wants to plot AND the list of
; parameters that each of those parameters requires in order to plot them.
;*********************************************************************
requires_query='SELECT requires from tbl_plotting_params WHERE tbl_plotting_params.KINST = '+string(kinst)+' AND tbl_plotting_params.KINDAT = '+string(kindat)+' AND '

for i=0ul,(result-1) do begin
    if (i eq 0) then begin ;{
	requires_query=requires_query+'('
    endif else begin ;} ;{
	requires_query=requires_query+' OR '
    endelse ;}
    requires_query=requires_query+'(tbl_plotting_params.PARAMETER_ID='+parts[i]+')'
endfor

requires_query=requires_query+')'

rows=0ul
columns=0ul
results=0ul

val0=LOAD_CATALOG_QUERY (requires_query, rows, columns, results)

requires=''
paralist=[1]

if (val0 eq 0) then begin ;{
    for i=0ul,(rows-1) do begin ;{
	val1=GET_CELL (results,i,0ul,requires)
	if (val1 eq 0) then begin ;{
	    para_parts=str_sep(requires,',',/TRIM)
	    n_parts=n_elements(para_parts)
	    for j=0ul,(n_parts-1) do begin ;{
		if (i eq 0 and j eq 0) then begin ;{
		    paralist=[para_parts[j]]
		endif else begin ;} ;{
		    tryme=where(paralist eq para_parts[j],tryme_count)
		    if (tryme_count ne 1) then begin ;{
			paralist=[paralist,para_parts[j]]
		    endif ;}
		endelse ;}
	    endfor ;}
	endif ;}
    endfor ;}
endif ;}
n_paras=n_elements(paralist)

val2=DESTROY_RESULT_SET(results)

;*********************************************************************
; Get the date range for this query
;*********************************************************************
date_query='SELECT DATE_ID from tbl_date WHERE YEAR =' + string(year) + ' AND MONTH =' + string(month) + ' AND DAY =' + string(day) +';'
rows=0ul
columns=0ul
results=0ul
startdate=''
enddate='' 

val0=LOAD_CATALOG_QUERY (date_query, rows, columns, results)

if (val0 eq 0) then begin
    val1=GET_CELL (results,0ul,0ul,startdate)
    if (val1 eq 0) then begin
        enddate=startdate+ndays
    endif
endif

val2=DESTROY_RESULT_SET(results)

;*********************************************************************
; now we need the list of containers that will satisfy this query
;*********************************************************************
container_query='SELECT DISTINCT tbl_cedar_file.FILE_NAME FROM tbl_date_in_file,tbl_cedar_file,tbl_file_info,tbl_record_type WHERE tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID and tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND (tbl_date_in_file.DATE_ID >= ' +string(startdate) + ') AND (tbl_date_in_file.DATE_ID <=' + string(enddate) + ') AND (tbl_record_type.KINST=' + string(kinst) + ') AND (((tbl_record_type.KINST=' + string(kinst) + ') AND (tbl_record_type.KINDAT=' + string(kindat) + ')));'
cell=''

val0=LOAD_CATALOG_QUERY (container_query, rows, columns, results)

starting=JULDAY(string(month),string(day),string(year))
ending=starting+ndays

CALDAT, ending, M, D, Y

if (day lt 10) then day='0'+string(day) else day=day
if (D lt 10) then D='0'+string(D) else D=D

dat1='.constraint=%22date('+string(year)+','+string(month)+string(day)+',0,0,'+string(Y)+','+string(M)+string(D)+',2359,5999);record_type('+string(kinst)+'/'+string(kindat)+');parameters('

dat2=strcompress(dat1,/remove_all)

if (val0 eq 0) then begin
    print, '<p><b>Access the data using these links:</b></p>'
    print, '<a href="/opendap?request=define+silently+d+as+' 
    constraint=''
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
	    print, cell
	    constraint=constraint+cell+dat2
	    for j=0ul,(n_paras-1) do begin
	      constraint=constraint+string(paralist(j))
	      if (n_paras ne 0ul and (j ge 0ul) and (j lt (n_paras-1))) then constraint=constraint+','
	    endfor
	    constraint=constraint+')%22'
	    if (i lt (rows-1)) then constraint=constraint+','
            if (i lt (rows-1)) then print, ',' else print,'+with+'+constraint
        endif
    endfor
    print, ';'
    print, 'get+tab+for+d;'
    print,'" TARGET="cedar_aux">TAB</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+' 
    constraint=''
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
	    print, cell
	    constraint=constraint+cell+dat2
	    for j=0ul,(n_paras-1) do begin
	      constraint=constraint+string(paralist(j))
	      if (n_paras ne 0ul and (j ge 0ul) and (j lt (n_paras-1))) then constraint=constraint+','
	    endfor
	    constraint=constraint+')%22'
	    if (i lt (rows-1)) then constraint=constraint+','
            if (i lt (rows-1)) then print, ',' else print,'+with+'+constraint
        endif
    endfor
    print, ';'
    print, 'get+flat+for+d;'
    print,'" TARGET="cedar_aux">FLAT</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print, cell 
            if (i lt (rows-1)) then print, ',' else print,';'
        endif
    endfor
    print, 'get+info+for+d;'
    print, '" TARGET="cedar_aux">INFO</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print, cell 
            if (i lt (rows-1)) then print, ',' else print,';'
        endif
    endfor
    print, 'get+das+for+d;'
    print,'" TARGET="cedar_aux">DAS</a>'
endif


if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    constraint=''
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
	    print, cell
	    constraint=constraint+cell+dat2
	    for j=0ul,(n_paras-1) do begin
	      constraint=constraint+string(paralist(j))
	      if (n_paras ne 0ul and (j ge 0ul) and (j lt (n_paras-1))) then constraint=constraint+','
	    endfor
	    constraint=constraint+')%22'
	    if (i lt (rows-1)) then constraint=constraint+','
            if (i lt (rows-1)) then print, ',' else print,'+with+'+constraint
        endif
    endfor
    print, ';'
    print, 'get+dds+for+d;'
    print, '" TARGET="cedar_aux">DDS</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    constraint=''
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
	    print, cell
	    constraint=constraint+cell+dat2
	    for j=0ul,(n_paras-1) do begin
	      constraint=constraint+string(paralist(j))
	      if (n_paras ne 0ul and (j ge 0ul) and (j lt (n_paras-1))) then constraint=constraint+','
	    endfor
	    constraint=constraint+')%22'
	    if (i lt (rows-1)) then constraint=constraint+','
            if (i lt (rows-1)) then print, ',' else print,'+with+'+constraint
        endif
    endfor
    print, ';'
    print, 'get+dods+for+d;'
    print, '" TARGET="cedar_aux">OPeNDAP</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print, cell 
            if (i lt (rows-1)) then print, ',' else print,';'
        endif
    endfor
    print, 'get+stream+for+d;'
    print, '" TARGET="cedar_aux">STREAM</a>'
endif

val2=DESTROY_RESULT_SET(results)

end

