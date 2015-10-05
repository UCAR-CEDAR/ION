pro listinstrument,instrument

parts=str_sep(instrument,'-',/TRIM)

query='SELECT DISTINCT concat(tbl_instrument.INST_NAME,"%",tbl_instrument.PREFIX,"%",tbl_instrument.KINST) FROM tbl_instrument ORDER BY tbl_instrument.KINST'

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
	 if (parts eq part(2)) then begin
	 print, part(2)+' - '+part(0)
	 endif
      endif
   endfor
endif

val2=DESTROY_RESULT_SET(results)
end
