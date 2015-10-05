pro listpara,instrument,record,parameter

parts=str_sep(parameter,'|',/TRIM)

result=N_ELEMENTS(parts)

query='SELECT DISTINCT concat(tbl_parameter_code.PARAMETER_ID,"%",tbl_parameter_code.MADRIGAL_NAME,"%",tbl_parameter_code.LONG_NAME) FROM tbl_parameter_code,tbl_record_info,tbl_record_type'

query=query+' WHERE (1) AND tbl_parameter_code.PARAMETER_ID=tbl_record_info.PARAMETER_ID AND tbl_record_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND '

for i=0ul,(result-1) do begin
	if (i eq 0) then query=query+'(' else query=query+' OR '
	query=query+'(tbl_parameter_code.PARAMETER_ID='+parts(i)+')'
endfor

query=query+') ORDER BY tbl_parameter_code.PARAMETER_ID'

rows=0ul
columns=0ul
results=0ul
cell=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

;openw,12,'/projects/cedar/src/ion/version4/wb.txt'
;printf,12,val0,i,result,query,rows
;close,12
if (val0 eq 0) then begin
   for i=0ul,(rows-1) do begin
      val1=GET_CELL (results,i,0ul,cell)
      if (val1 eq 0) then begin
         part=str_sep(cell,'%',/TRIM)
	 print,'<br>'+part(0)+' - '+part(1)+' - '+part(2)
      endif
   endfor
endif

val2=DESTROY_RESULT_SET(results)
end
