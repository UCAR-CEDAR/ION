pro SubmitR, instrument, record, year, month, day, ndays


if (instrument LT 0) then begin
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

query='SELECT DATE_ID from tbl_date WHERE YEAR =' + string(year) + ' AND MONTH =' + string(month) + ' AND DAY =' + string(day) +';'
rows=0ul
columns=0ul
results=0ul
date1=''
date2='' 

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

if (val0 eq 0) then begin
    val1=GET_CELL (results,0ul,0ul,date1)
    if (val1 eq 0) then begin
        date2=date1+ndays
    endif
endif

val2=DESTROY_RESULT_SET(results)


query='SELECT DISTINCT tbl_cedar_file.FILE_NAME FROM tbl_date_in_file,tbl_cedar_file,tbl_file_info,tbl_record_type WHERE tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID and tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND (tbl_date_in_file.DATE_ID >= ' +string(date1) + ') AND (tbl_date_in_file.DATE_ID <=' + string(date2) + ') AND (tbl_record_type.KINST=' + string(instrument) + ') AND ((tbl_record_type.KINST=' + string(instrument) + ') AND (tbl_record_type.KINDAT=' + string(record) + '))'

query=query+' ORDER BY tbl_record_type.KINST,tbl_record_type.KINDAT'


;openw, 12,'/project/cedar/src/ion/version4/wr1.txt'
;printf,12,date1,date2,query
;close,12

cell=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

startdate=JULDAY(string(month),string(day),string(year))
ending=startdate+ndays

CALDAT, ending, M, D, Y

if (day lt 10) then day='0'+string(day) else day=day
if (D lt 10) then D='0'+string(D) else D=D

dat1='.constraint=%22date('+string(year)+','+string(month)+string(day)+',0,0,'+string(Y)+','+string(M)+string(D)+',2359,5999);record_type('+string(instrument)+'/'+string(record)+')%22'

dat2=strcompress(dat1,/remove_all)

if (val0 eq 0) then begin
    print, '<p><b>This URL is the data request:</b></p>'
    print, '<a href="/opendap?request=define+silently+d+as+' 
    constraint=''
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
	    print, cell
	    constraint=constraint+cell+dat2
	    if (i lt (rows-1)) then constraint=constraint+','
            if (i lt (rows-1)) then print, ',' else print,'+with+'+constraint
        endif
    endfor
    print, ';'
    print, 'get+tab+for+d;'
    print,'">TAB</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+' 
    constraint=''
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
	    print, cell
	    constraint=constraint+cell+dat2
	    if (i lt (rows-1)) then constraint=constraint+','
            if (i lt (rows-1)) then print, ',' else print,'+with+'+constraint
        endif
    endfor
    print, ';'
    print, 'get+flat+for+d;'
    print,'">FLAT</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print, cell
	    if (i lt (rows-1)) then print,',' else print,';'
        endif
    endfor
    print, 'get+info+for+d;'
    print, '">INFO</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print, cell 
	    if (i lt (rows-1)) then print,',' else print,';'
        endif
    endfor
    print, 'get+das+for+d;'
    print,'">DAS</a>'
endif


if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    constraint=''
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print, cell 
	    constraint=constraint+cell+dat2
	    if (i lt (rows-1)) then constraint=constraint+','
            if (i lt (rows-1)) then print, ',' else print,'+with+'+constraint
        endif
    endfor
    print, ';'
    print, 'get+dds+for+d;'
    print, '">DDS</a>'
endif

if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    constraint=''
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print, cell 
	    constraint=constraint+cell+dat2
	    if (i lt (rows-1)) then constraint=constraint+','
            if (i lt (rows-1)) then print, ',' else print,'+with+'+constraint
        endif
    endfor
    print, ';'
    print, 'get+dods+for+d;'
    print, '">OPeNDAP</a>'
endif


if (val0 eq 0) then begin
    print, '&nbsp&nbsp; <a href="/opendap?request=define+silently+d+as+'
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print, cell 
            if (i lt (rows-1)) then print, ',' else print, ';'
        endif
    endfor
    print, 'get+stream+for+d;'
    print, '">STREAM</a>'
endif


val2=DESTROY_RESULT_SET(results)

end
