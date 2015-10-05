PRO fpi,data,p,i,print_params,k,kindat_parts,$
	req_parts,i_func,use_ndays,beginning,starting,$
	p_min,p_max,p_label,doingprint,$
	did_plot,debug
;{

IF( debug GT 0ul ) THEN BEGIN ;{
    fi=i
    IF( fi LT 10 ) THEN fi='0'+STRING( fi )
    fi=STRCOMPRESS( fi, /REMOVE_ALL )
    fn=STRING(FORMAT='(%"/project/cedar/src/pwest/apache/ion/fpi_%s.out")',fi)
    ;fn='/project/cedar/src/pwest/apache/ion/fpi.out'
    OPENW,11,fn
ENDIF ;}

; We want to start on the selected dayno, not the dayno of the first
; returned piece of data, so use starting and beginning
;doy_start = p.dayno.value[0]
doy_start = starting - beginning + 1
doy_end = doy_start + use_ndays

IF( debug GT 0ul ) THEN BEGIN ;{
    PRINTF,11,'doy_start = ',doy_start
    PRINTF,11,'doy_end = ',doy_end
    PRINTF,11,'print_params = ',print_params
    PRINTF,11,'req_parts = ',req_parts
    PRINTF,11,'use_ndays = ',use_ndays
    PRINTF,11,'beginning = ',beginning
    PRINTF,11,'p_min = ',p_min
    PRINTF,11,'p_max = ',p_max
    PRINTF,11,'p_label = ',p_label
    PRINTF,11,''
ENDIF ;}

missing_value_lower=-32000

r0 = 1.
rday = 1.

num_ticks=use_ndays
IF( num_ticks GT 15 ) THEN BEGIN ;{
    num_ticks = 15
ENDIF ;}
;if ( use_ndays le 2 ) then begin ;{
;    num_ticks=12
;    tick_units=['days','hours']
;    y_margin=10
;endif else begin ;} ;{
;    num_ticks=use_ndays
;    tick_units=['days']
;    y_margin=6
;endelse ;}

vert = 1
IF( use_ndays GT 30 ) THEN BEGIN ;{
    vert = use_ndays/30
ENDIF ;}

y_margin=6

c_size = 1.0
n_req_parts = N_ELEMENTS( req_parts )
IF( n_req_parts EQ 1 ) THEN BEGIN ;{
    c_size = 0.5
ENDIF ;}

tag_name = 'KINDAT_' + STRCOMPRESS( STRING( kindat_parts[k] ), /REMOVE_ALL )
k_tags=TAG_NAMES(p)
k_tag_index = WHERE( k_tags EQ tag_name, k_tag_count )
IF( k_tag_count NE 0 ) THEN BEGIN ;{
    p_tags = TAG_NAMES( p.(k_tag_index[0]) )
    p_tag_index = WHERE( p_tags EQ req_parts[i], p_tag_there )
    IF( p_tag_there NE 0 ) THEN BEGIN ;{
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,11,'plotting ',p.(k_tag_index[0]).(p_tag_index[0]).name
	    PRINTF,11,'p_min = ',p_min
	    PRINTF,11,'p_max = ',p_max
	    PRINTF,11,'p_label = ',p_label
	ENDIF ;}

	MISSINGVALUE,p.(k_tag_index[0]).(p_tag_index[0]).value,p_values,p_index,p_valid,MISSING_VALUE=missing_value_lower
	CALL_PROCEDURE,i_func,p,k_tag_index[0],p_index,p_daytime
	p_data=CEDAR_FIX_MISSING(p_daytime(0:p_valid-1),p_values(0:p_valid-1))

	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,11,'p_data.values = ',p_data.values
	    PRINTF,11,'p_data.time = ',p_data.time
	    PRINTF,11,''
	ENDIF ;}
	IF( did_plot EQ 0ul ) THEN BEGIN ;{
	    dummy=FPI_XTICKS(BEGINNING=beginning)
	    dummy=LABEL_DATE(DATE_FORMAT='%M %D')
	    PLOT,p_data.time,p_data.values,$
		 MIN_VALUE=-32760,$
		 MAX_VALUE=99998.,$
		 CHARSIZE=c_size,$
		 ystyle=1,$
		 xstyle=1,$
		 xrange =[doy_start,doy_end],$
		 yrange =[p_min,p_max],$
		 ymargin=[y_margin,0],$
		 ytitle=p_label,$
		 xticks=num_ticks,$
		 xtickformat='FPI_XTICKS',$
		 background=255,$
		 color=0

	    OPLOT,[doy_start,doy_end],[0,0], linestyle=0,color=0
	    IF ( use_ndays NE 1 ) THEN BEGIN ;{
		FOR j=1,use_ndays-1 DO BEGIN ;{
		    OPLOT,[rday*j+doy_start*r0,rday*j+doy_start*r0],[p_min,p_max], linestyle=0,color=0
		    j = j + vert
		ENDFOR ;}
	    ENDIF ;}
	    did_plot = 1ul
	ENDIF ELSE BEGIN ;} ;{
	    new_color=k*40
	    OPLOT,p_data.time,p_data.values,$
		 MIN_VALUE=-32760,$
		 MAX_VALUE=99998.,$
		 color=new_color
	ENDELSE ;}
    ENDIF ;}
ENDIF ;}

IF( debug GT 0ul ) THEN BEGIN ;{
    CLOSE,11
ENDIF ;}

;}
END

