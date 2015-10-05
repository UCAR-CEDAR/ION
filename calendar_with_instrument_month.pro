pro calendar_with_instrument_month, instrument, year, isplot

;months=strarr(12)
;months=['January','Feburary','March','April','May','June','July','August','September','October','November','December']

if (instrument LT 0) then begin
    print, 'Error: instrument is a negative value'
    return
endif

if (year LT 0) then begin
    print, 'Error: year is a negative value of' 
    print, year
    return
endif

query='SELECT DISTINCT tbl_date.MONTH FROM tbl_date,tbl_date_in_file,tbl_cedar_file,tbl_file_info,tbl_record_type,tbl_record_info'

IF( isplot EQ 'true' ) THEN BEGIN ;{
    query+=',tbl_plotting_params'
ENDIF

query+=' WHERE tbl_date.DATE_ID=tbl_date_in_file.DATE_ID AND tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID AND tbl_date.YEAR=' +string(year)

if (isplot EQ 'true' ) then begin
    query+=' AND tbl_record_type.KINST=tbl_plotting_params.KINST AND tbl_record_type.KINDAT=tbl_plotting_params.KINDAT AND tbl_plotting_params.KINST=' + string(instrument)
endif else begin
    query+=' AND (tbl_record_type.KINST=' + string(instrument) + ')'
endelse

query+=' ORDER BY tbl_date.MONTH ASC;'

print, '<SELECT NAME=MONTH SIZE=6>'

rows=0ul
columns=0ul
results=0ul
cell=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

if (val0 eq 0) then begin
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            print,'<OPTION VALUE='+cell+'>'
	    if (cell eq '1') then print, 'January'
            if (cell eq '2') then print, 'February'
            if (cell eq '3') then print, 'March'
            if (cell eq '4') then print, 'April'
            if (cell eq '5') then print, 'May'
            if (cell eq '6') then print, 'June'
            if (cell eq '7') then print, 'July'
            if (cell eq '8') then print, 'August'
            if (cell eq '9') then print, 'September'
            if (cell eq '10') then print, 'October'
            if (cell eq '11') then print, 'November'
            if (cell eq '12') then print, 'December'
        endif
    endfor
endif

val2=DESTROY_RESULT_SET(results)

print, '</SELECT>'

end
