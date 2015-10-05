pro calendar_month, year

if (year LT 0) then begin
    print, 'Error: year is a negative value of' 
    print, year
    return
endif

print, '<SELECT NAME=MONTH SIZE=5>'

query='SELECT DISTINCT tbl_date.MONTH FROM tbl_date,tbl_date_in_file WHERE tbl_date.DATE_ID=tbl_date_in_file.DATE_ID AND tbl_date.YEAR=' +string(year) + ' ORDER BY tbl_date.MONTH ASC;'
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
