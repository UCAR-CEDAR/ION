pro record_plot_list, inst, year, month, day, ndays, rverbosity

query='SELECT DATE_ID from tbl_date WHERE YEAR =' + string(year) + ' AND MONTH =' + string(month) + ' AND DAY =' + string(day) +';'

rows=0ul
columns=0ul
results=0ul
date1=''
date2=''

val0=LOAD_CATALOG_QUERY(query, rows, columns, results)

if (val0 eq 0) then begin
	val1=GET_CELL (results,0ul,0ul,date1)
	if (val1 eq 0) then begin
		date2=date1+ndays
	endif
endif

val2=DESTROY_RESULT_SET(results)


query='SELECT DISTINCT concat(tbl_record_type.KINST,"%",tbl_record_type.KINDAT,"%",tbl_record_type.DESCRIPTION)' 

query=query+' FROM tbl_record_info,tbl_record_type,tbl_file_info,tbl_cedar_file,tbl_date_in_file,tbl_plotting_params'

query=query+' WHERE (tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID)'

query=query+' AND (tbl_record_type.RECORD_TYPE_ID=tbl_file_info.RECORD_TYPE_ID)'

query=query+' AND (tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID)'

query=query+' AND (tbl_file_info.RECORD_IN_FILE_ID=tbl_date_in_file.RECORD_IN_FILE_ID)'

query=query+' AND (tbl_record_type.KINST='+string(inst)+')'

query=query+' AND (tbl_plotting_params.KINST='+string(inst)+')'

query=query+' AND (tbl_record_type.KINDAT=tbl_plotting_params.KINDAT)'

query=query+' AND ((tbl_date_in_file.DATE_ID >='+string(date1)+') AND (tbl_date_in_file.DATE_ID <='+string(date2)+'))'

query=query+' ORDER BY tbl_record_type.KINST,tbl_record_type.KINDAT'

;startdate=JULDAY(string(month),string(day),string(year))-JULDAY(1,1,1950)+1
;enddate=day+ndays
;ending=JULDAY(string(month),string(enddate),string(year))-JULDAY(1,1,1950)+1
;openw,12,'/project/cedar/src/pwest/apache/logs/query.txt'
;printf,12,query
;close,12

rows=0ul
columns=0ul
results=0ul
cell=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

if (val0 eq 0 and rows gt 0) then begin
   for i=0ul,(rows-1) do begin
      val1=GET_CELL (results,i,0ul,cell)
      if (val1 eq 0) then begin
         part=str_sep(cell,'%',/TRIM)
         if (rverbosity eq 0) then print,'<OPTION VALUE='+part(1)+'>'+part(2) else $
	 if (rverbosity eq 1) then print,'<OPTION VALUE='+part(1)+'>'+part(1)+' - '+part(2) else $
	 print,'<OPTION VALUE='+part(1)+'>'+part(0)+' - '+part(1)+' - '+part(2)
      endif
   endfor
endif

val2=DESTROY_RESULT_SET(results)

end

