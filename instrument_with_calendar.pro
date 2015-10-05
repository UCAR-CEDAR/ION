pro instrument_with_calendar, year, month, day, ndays

if (year LT 0) then begin
    print, 'Error: year is a negative value'
    return
endif

if (month LT 0) then begin
    print, 'Error: month is a negative value of' 
    print, year
    return
endif

if (day LT 0) then begin
    print, 'Error: day is a negative value of' 
    print, day
    return
endif

if (ndays LT 0) then begin
    print, 'Error: The number of days is a negative value of' 
    print, ndays
    return
endif

query='SELECT DATE_ID from tbl_date WHERE YEAR =' + string(year) + ' AND MONTH =' + string(month) + ' AND DAY =' + string(day) +';'
rows=0ul
columns=0ul
results=0ul
date1=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

if (val0 eq 0) then begin
    val1=GET_CELL (results,0ul,0ul,date1)
    if (val1 eq 0) then begin
        date2=date1+ndays
    endif
endif

val2=DESTROY_RESULT_SET(results)


query='SELECT DISTINCT concat(tbl_instrument.INST_NAME,"%",tbl_instrument.PREFIX,"%",tbl_instrument.KINST) FROM tbl_instrument,tbl_record_info,tbl_record_type,tbl_file_info,tbl_cedar_file,tbl_date_in_file WHERE tbl_instrument.KINST=tbl_record_type.KINST AND tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID AND tbl_record_type.RECORD_TYPE_ID=tbl_file_info.RECORD_TYPE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_file_info.RECORD_IN_FILE_ID=tbl_date_in_file.RECORD_IN_FILE_ID AND (tbl_date_in_file.DATE_ID >=' + string(date1) +') AND (tbl_date_in_file.DATE_ID <=' + string(date2) + ') ORDER BY tbl_instrument.KINST ASC;'
cell=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

if (val0 eq 0) then begin
    print, '<SELECT NAME=INSTRUMENT SIZE=5>'
    for i=0ul,(rows-1) do begin
        val1=GET_CELL (results,i,0ul,cell)
        if (val1 eq 0) then begin
            part=str_sep(cell,'%',/TRIM)
            print,'<OPTION VALUE='+part(2)+'>'+part(2)+' - '+part(1)+' - '+part(0)
        endif
    endfor
    print, '</SELECT>'
endif

val2=DESTROY_RESULT_SET(results)

end
