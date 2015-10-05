pro listrec,instrument,record

parts=str_sep(record,'-',/TRIM)
;openw,12,'/project/cedar/src/ion/version4/wb.txt'
;printf,12,record,parts
;close,12

query='SELECT DISTINCT concat(tbl_record_type.KINST,"%",tbl_record_type.KINDAT,"%",tbl_record_type.DESCRIPTION) FROM tbl_record_info,tbl_record_type'

query=query+' WHERE tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID'

query=query+' AND (tbl_record_type.KINDAT='+parts(0)+')'

query=query+'ORDER BY tbl_record_type.KINST, tbl_record_type.KINDAT'

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
	 if (instrument eq part(0) and parts eq part(1)) then begin
	 print, part(0)+'/'+part(1)+' - '+part(2)
	 endif
      endif
   endfor
endif

val2=DESTROY_RESULT_SET(results)
end
