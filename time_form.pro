pro selectYear,syear,eyear,select_year,label
    if( syear eq eyear ) then begin ;{
	print,'<SELECT NAME=',label,' SIZE=1>'
	print,'<OPTION VALUE=',syear,' SELECTED>',syear,'</OPTION>'
	print,'</SELECT>'
    endif else begin ;} ;{
	print, '<SELECT NAME=',label,' SIZE=3>'
	for i_year=ulong(syear),ulong(eyear) do begin ;{
	    if( i_year eq ulong(select_year) ) then begin ;{
		print,'<OPTION VALUE=',i_year,' SELECTED>',i_year,'</OPTION>'
	    endif else begin ;} ;{
		print,'<OPTION VALUE=',i_year,'>',i_year,'</OPTION>'
	    endelse ;}
	endfor ;}
	print, '</SELECT>'
    endelse ;}
end

pro selectMonth,months,smonth,emonth,select_month,label
    lsmonth=ulong(smonth)
    lemonth=ulong(emonth)
    lselect=ulong(select_month)
    if( lsmonth eq lemonth ) then begin ;{
	print,'<SELECT NAME=',label,' SIZE=1>'
	print,'<OPTION VALUE=',smonth,' SELECTED>',months[lsmonth-1],'</OPTION>'
	print,'</SELECT>'
    endif else begin ;} ;{
	if( lemonth lt lsmonth ) then lemonth=lemonth+12
	print, '<SELECT NAME=',label,' SIZE=3>'
	for i_month=lsmonth,lemonth do begin ;{
	    if( i_month > 12 ) then amonth=i_month-12 else amonth=i_month
	    print,'<OPTION VALUE=',amonth
	    if( amonth eq lselect ) then begin ;{
		print,' SELECTED>'
	    endif else begin ;} ;{
		print,'>'
	    endelse ;}
	    print,months[amonth-1],'</OPTION>'
	endfor ;}
	print, '</SELECT>'
    endelse ;}
end

pro selectDay,smonth,sday,syear,emonth,eday,eyear,select_day,label
    smonthLength=[31,28,31,30,31,30,31,31,30,31,30,31]
    emonthLength=[31,28,31,30,31,30,31,31,30,31,30,31]
    lselect=ulong(select_day)
    if( double(double(syear)/4) eq double(syear/4) ) then begin ;{
	smonthLength[1] = 29;
    endif ;}
    if( double(double(eyear)/4) eq double(eyear/4) ) then begin ;{
	emonthLength[1] = 29;
    endif ;}
    print, '<SELECT NAME=',label,' SIZE=3>'
    for i_day=1ul,31 do begin ;{
	print,'<OPTION VALUE=',i_day
	if( i_day eq lselect ) then begin ;{
	    print,' SELECTED>'
	endif else begin ;} ;{
	    print,'>'
	endelse ;}
	print,i_day,'</OPTION>'
    endfor ;}
    print, '</SELECT>'
end

pro selectTime,select_time,label
    print, '<SELECT NAME=',label,' SIZE=3>'
    for i_hr=0ul,23 do begin ;{
	for i_min=0ul,59 do begin ;{
	    if( i_hr lt 10 ) then combo='0'+string(i_hr) else combo=string(i_hr)
	    if( i_min lt 10 ) then combo=combo+':0'+string(i_min) else combo=combo+':'+string(i_min)
	    combo=strcompress(combo,/REMOVE_ALL)
	    print,'<OPTION VALUE=',combo
	    if( combo eq select_time ) then begin ;{
		print,' SELECTED>'
	    endif else begin ;} ;{
		print,'>'
	    endelse ;}
	    print,combo,'</OPTION>'
	    if( i_min eq 45 ) then i_min=i_min+13 else i_min=i_min+14
	endfor ;}
    endfor ;}
    print, '</SELECT>'
end

pro time_form,smonth,sday,syear,ndays,sdt,edt

!quiet=1

kinst=5340
kindat=7001
parameter='800 | 810 | 1410 | 1420 | 2506'

stime='00:00'
etime='23:59'

starting=JULDAY(string(smonth),string(sday),string(syear))
ending=starting+ndays

CALDAT, ending, emonth, eday, eyear

if (sday lt 10) then sday='0'+string(sday)
if (eday lt 10) then eday='0'+string(eday)
sday=strcompress(sday,/REMOVE_ALL)
eday=strcompress(eday,/REMOVE_ALL)

;*********************************************************************
; determine what the users current selection is for the date and time
;*********************************************************************
if( sdt eq 'undef' ) then begin ;{
    s_smonth=smonth
    s_sday=sday
    s_syear=syear
    s_stime=stime

    e_smonth=emonth
    e_sday=eday
    e_syear=eyear
    e_stime=etime
endif else begin ;} ;{
    s_parts=str_sep(sdt,'|',/TRIM)
    s_smonth=s_parts[0]
    s_sday=s_parts[1]
    s_syear=s_parts[2]
    s_stime=s_parts[3]

    e_parts=str_sep(edt,'|',/TRIM)
    e_smonth=e_parts[0]
    e_sday=e_parts[1]
    e_syear=e_parts[2]
    e_stime=e_parts[3]
endelse ;}

;*********************************************************************
; create the date strings to display in the plot
;*********************************************************************
months=['January',$
	'February',$
	'March',$
	'April',$
	'May',$
	'June',$
	'July',$
	'August',$
	'September',$
	'October',$
	'November',$
	'December']

print,'<TABLE WIDTH="600" CELLSPACING="2" CELLPADDING="5" BORDER="0">'
print,'<TR>'
print,'<TD ALIGN="CENTER" WIDTH="200">'
print,'Current Selection'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
print,'Select Year'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
print,'Select Month'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
print,'Select Day'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
print,'Select Time'
print,'</TD>'
print,'</TR>'
print,'<TR>'
print,'<TD ALIGN="LEFT" WIDTH="200">'
print,'Starting: ',months[smonth-1],' ',string(sday),', ',string(syear)
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
selectYear,syear,eyear,s_syear,'YEAR'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
selectMonth,months,smonth,emonth,s_smonth,'MONTH'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
selectDay,smonth,sday,syear,emonth,eday,eyear,s_sday,'DAY'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
selectTime,stime,'STIME'
print,'</TD>'
print,'</TR>'
print,'<TR>'
print,'<TD ALIGN="LEFT" WIDTH="200">'
print,'Ending: ',months[emonth-1],' ',string(eday),', ',string(eyear)
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
selectYear,syear,eyear,e_syear,'EYEAR'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
selectMonth,months,smonth,emonth,e_smonth,'EMONTH'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
selectDay,smonth,sday,syear,emonth,eday,eyear,e_sday,'EDAY'
print,'</TD>'
print,'<TD ALIGN="CENTER" WIDTH="100">'
selectTime,etime,'ETIME'
print,'</TD>'
print,'</TR>'
print,'</TABLE>'

end

