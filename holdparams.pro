pro holdparams,url,paramet,inst,r_t,start,ending,event,oldfile,newfile
if (event eq 'page') then begin
   opener=newfile+'.sav'
   openw,10,opener
   printf,10,'undef'
   close,10
   return
endif

parameters='' 

opener=oldfile+'.sav'
openr,10,opener,error=ierr,/DELETE
if (ierr eq 0 ) then readf,10,parameters
if (ierr eq 0 ) then close,10

if (parameters eq 'undef') then parameters='?'

parser=STR_SEP(url,'PARAMS%3ASTR%3A',/TRIM)
if (N_ELEMENTS(parser) GT 1) then begin
   if (N_ELEMENTS(STR_SEP(parser(1),'undef',/TRIM)) EQ 1) then begin
      marker='&RELOAD'
      if (N_ELEMENTS(STR_SEP(url,'Record_Type')) GT 1) then marker='&Record_Type'
      if (N_ELEMENTS(STR_SEP(url,'Instrument')) GT 1) then marker='&Instrument'
      if (N_ELEMENTS(STR_SEP(url,'Parameters')) GT 1) then marker='&Parameters' 
      if (N_ELEMENTS(STR_SEP(url,'Start')) GT 1) then marker='&Start'
      if (N_ELEMENTS(STR_SEP(url,'End')) GT 1) then marker='&End'
      if (N_ELEMENTS(STR_SEP(url,'&DATA')) GT 1) then marker='&DATA'
      if (N_ELEMENTS(STR_SEP(url,'&PLOT')) GT 1) then marker='&PLOT'
      parsed=STR_SEP(parser(1),marker,/TRIM)
      wanted=parsed(0)
      elems=STR_SEP(wanted,'%3F',/TRIM)
      if (N_ELEMENTS(elems) gt 1) then begin
         parameters=parameters+elems(1)+'?'
         for i=2,(N_ELEMENTS(elems)-2) do parameters=parameters+elems(i)+'?'
      endif
   endif
endif

result=STR_SEP(parameters,'%0A',/TRIM)  
if (N_ELEMENTS(result) GT 1) then begin
   if (result(0) EQ '') then parameters=result(1)
   if (result(1) EQ '') then parameters=result(0)
endif


results=STR_SEP(url,'&Parameters=',/TRIM)
parts=N_ELEMENTS(results)

if (parts GT 1) then begin
   mini=STR_SEP(results(parts-1),'&',/TRIM)
   results(parts-1)=mini(0)
   for i=1,(parts-1) do begin
      if (STRPOS(parameters,('?'+results(i)+'?')) eq -1) then parameters=parameters+results(i)+'?'
   endfor
endif

barrier=STR_SEP(url,'Add+Paramet',/TRIM)
barparts=N_ELEMENTS(barrier)

if ((parameters ne '?') and (barparts ne 2)) then begin
query='SELECT DISTINCT concat(tbl_parameter_code.PARAMETER_ID) FROM tbl_parameter_code'
if ((r_t ne 'undef') or (inst ne 'undef') or (start ne 'undef') or (ending ne 'undef')) then query=query+',tbl_record_info,tbl_record_type'

if ((start ne 'undef') or (ending ne 'undef')) then query=query+',tbl_file_info,tbl_cedar_file,tbl_date_in_file'

query=query+' WHERE (1) '

if ((r_t ne 'undef') or (inst ne 'undef') or (start ne 'undef') or (ending ne 'undef')) then begin
   query=query+'AND tbl_parameter_code.PARAMETER_ID=tbl_record_info.PARAMETER_ID AND tbl_record_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID '
endif

if ((start ne 'undef') or (ending ne 'undef')) then begin
   query=query+'AND tbl_record_type.RECORD_TYPE_ID=tbl_file_info.RECORD_TYPE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_file_info.RECORD_IN_FILE_ID=tbl_date_in_file.RECORD_IN_FILE_ID '
endif

if (r_t ne 'undef') then begin
;   parts=str_sep(r_t,'-',/TRIM)
;   part=str_sep(parts(1),' ')
;   query=query+'AND ((tbl_record_type.KINST='+parts(0)+') AND (tbl_record_type.KINDAT='+part(0)+')) '
    query=query+'AND (tbl_record_type.KINDAT='+r_t+') '
endif    

if ((inst ne 'undef') and (r_t eq 'undef')) then begin
   parts=str_sep(inst,'-',/TRIM)
   query=query+'AND (tbl_record_type.KINST='+parts(0)+') '
endif

if (((start ne 'undef') or (ending ne 'undef')) and (r_t eq 'undef')) then begin
 
   if (start eq 'undef') then begin
      startdate=1
   endif else begin
      parser=STR_SEP(start,'?',/TRIM)
      if (N_ELEMENTS(parser) eq 2) then begin
         startdate=JULDAY(parser(0),1,parser(1))-JULDAY(1,1,1950)+1
      endif else begin
         startdate=JULDAY(parser(1),parser(0),parser(2))-JULDAY(1,1,1950)+1   
      endelse
   endelse

   beginning=string(startdate)
   beginning=STRTRIM(beginning,1)
   query=query+'AND (tbl_date_in_file.DATE_ID >= '+beginning+') '

   if (ending eq 'undef') then begin
      day=31
      mon=12
      year=2000
   endif else begin
      parser=STR_SEP(ending,'?',/TRIM)
      if (N_ELEMENTS(parser) eq 2) then begin
         day=28
         mon=parser(0)
         year=parser(1)
      endif else begin
         day=parser(0)
         mon=parser(1)
         year=parser(2)
      endelse
   endelse
   enddate=JULDAY(mon,day,year)-JULDAY(1,1,1950)+1
   ending=string(enddate)
   ending=STRTRIM(ending,1)
   query=query+'AND (tbl_date_in_file.DATE_ID <= '+ending+') '
endif

query=query+'ORDER BY tbl_parameter_code.PARAMETER_ID'


rows=0ul
columns=0ul
results=0ul

cell=''

listofparas=''
val0=LOAD_CATALOG_QUERY (query, rows, columns, results)
if (val0 eq 0) then begin
   for i=0ul,(rows-1) do begin
      val1=GET_CELL (results,i,0ul,cell)
      if (val1 eq 0) then begin
         part=STRTRIM(cell,1)
         listofparas=listofparas+'?'+part
      endif
   endfor
endif
listofparas=listofparas+'?'

val2=DESTROY_RESULT_SET(results)


if (parameters NE '?') then begin
   params=STR_SEP(parameters,'?',/TRIM)
   parameters='?'
   for i=1,(N_ELEMENTS(params)-2) do begin
      if (STRPOS(listofparas,('?'+params(i)+'?')) ne -1) then parameters=parameters+params(i)+'?'
   endfor
endif
endif

if (parameters EQ '?') then parameters='undef'

closer=newfile+'.sav'
close,11
openw,11,closer
printf,11,parameters
close,11

;if (parameters NE '') then begin
 ;  lists=STR_SEP(parameters,'?',/TRIM)
   





end
