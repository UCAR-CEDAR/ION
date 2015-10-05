pro calendar_year

print, '<SELECT NAME=YEAR SIZE=5>'

query='SELECT DISTINCT tbl_date.YEAR FROM tbl_date,tbl_date_in_file WHERE tbl_date.DATE_ID=tbl_date_in_file.DATE_ID ORDER BY tbl_date.YEAR ASC;'
rows=0ul
columns=0ul
results=0ul
cell=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

if (val0 eq 0) then begin
   for i=0ul,(rows-1) do begin
      val1=GET_CELL (results,i,0ul,cell)
      if (val1 eq 0) then begin
         print,'<OPTION VALUE='+cell+'>'+cell
       endif
   endfor
endif

val2=DESTROY_RESULT_SET(results)

print, '</SELECT>'


end
