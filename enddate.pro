pro enddate,year,month,start_day,ndays


;year=2003
;month=2
;start_day=5
;ndays=395
end_day=0

this_months=strarr(13)
this_months(1)='January'
this_months(2)='February'
this_months(3)='March'
this_months(4)='April'
this_months(5)='May'
this_months(6)='June'
this_months(7)='July'
this_months(8)='August'
this_months(9)='September'
this_months(10)='October'
this_months(11)='November'
this_months(12)='December'


;define the # of days in each month.
month_day=strarr(13)
month_day(1)=31
month_day(2)=28
month_day(3)=31
month_day(4)=30
month_day(5)=31
month_day(6)=30
month_day(7)=31
month_day(8)=31
month_day(9)=30
month_day(10)=31
month_day(11)=30
month_day(12)=31


; Determine if this is a leap year.
r=((year mod 4 eq 0) and (year mod 100 ne 0) or (year mod 400 eq 0))


; For leap year, February has 29 days, total days in a year 366;
; otherwise February has 28 days, total days in a year 365.
total_day1=365
if(r eq 1) then begin
  month_day(2)=29
  total_day1=366
endif

;print,year,month,start_day,ndays
; The number of days left in this year after the start day.
for i=month+1, 12 do begin
   end_day=end_day+month_day(i)
endfor

y1=end_day+month_day(month)-start_day


; This is the year if number of days left is more than ndays;
; otherwise this is not the year, search for the right year.
if(y1 ge ndays) then  begin
  this_year=year
  D_day=total_day1-y1+ndays
endif else begin
  D_day=ndays-y1
  ; Keep subtracting days from ndays until the right year is found;
  while (D_day gt 0) do begin
     year=year+1
     r=(year mod 4 eq 0) and (year mod 100 ne 0) or (year mod 400 eq 0)
     if (r eq 1) then nyear=366 else nyear=365
     D_day=D_day-nyear
  endwhile

  ; Find the year, and number of days left in this year;
  this_year=year
  D_day=nyear+D_day
endelse

; Find the month;
total_day=0
if (r eq 1) then month_day(2)=29 else month_day(2)=28

; Keep search the month until the accumulated number of days is more than D_day;
for i=1,12 do begin
  total_day=total_day+month_day(i)
;print,total_day,'aaa'
  if (total_day ge D_day) then begin
      this_month=i
      break
  endif
endfor

; Find the day of the right month;
D_day=total_day-D_day
this_day=month_day(this_month)-D_day

print, this_months(this_month),' ',this_day,',  ',this_year
end
