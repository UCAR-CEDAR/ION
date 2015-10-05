pro instrument_list, verbosity

query='SELECT DISTINCT concat(tbl_instrument.INST_NAME,"%",tbl_instrument.PREFIX,"%",tbl_instrument.KINST) FROM tbl_instrument,tbl_record_info,tbl_record_type WHERE tbl_instrument.KINST=tbl_record_type.KINST AND tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID ORDER BY tbl_instrument.KINST ASC;'

rows=0ul
columns=0ul
results=0ul
cell=''

val0=LOAD_CATALOG_QUERY (query, rows, columns, results)

if (val0 eq 0) then begin
   for i=0ul,(rows-1) do begin
      val1=GET_CELL (results,i,0ul,cell)
      if (val1 eq 0) then begin
         part=str_sep(cell,'%',/TRIM)
         if (verbosity eq 0) then print,'<OPTION VALUE='+part(2)+'>'+part(0) else $
	 if (verbosity eq 1) then print,'<OPTION VALUE='+part(2)+'>'+part(1)+' - '+part(0) else $
	 print,'<OPTION VALUE='+part(2)+'>'+part(2)+' - '+part(1)+' - '+part(0)
      endif
   endfor
endif

val2=DESTROY_RESULT_SET(results)

end
