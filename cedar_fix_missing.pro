FUNCTION CEDAR_FIX_MISSING, p_time, p_values
    n_arr=N_ELEMENTS(p_time)
    s_arr=0
    FOR i_arr = 0, n_arr - 2 DO BEGIN ;{
	t_val = p_time[i_arr+1] - p_time[i_arr]
	n_val = p_time[i_arr]+UINT(t_val/2)
	IF( t_val GT 0.05 ) THEN BEGIN ;{
	    IF( s_arr EQ 0 ) THEN BEGIN ;{
		newp_values=[p_values[s_arr:i_arr],-32767]
		newp_time=[p_time[s_arr:i_arr],n_val]
		s_arr=i_arr+1
	    ENDIF ELSE BEGIN ;} ;{
		newp_values=[newp_values,p_values[s_arr:i_arr],-32767]
		newp_time=[newp_time,p_time[s_arr:i_arr],n_val]
		s_arr=i_arr+1
	    ENDELSE ;}
	ENDIF ;}
    ENDFOR ;}
    IF( s_arr EQ 0 ) THEN BEGIN ;{
	newp_values=p_values
	newp_time=p_time
    ENDIF ELSE BEGIN ;} ;{
	newp_values=[newp_values,p_values[s_arr:*]]
	newp_time=[newp_time,p_time[s_arr:*]]
    ENDELSE ;}
    p_data = CREATE_STRUCT( 'time', newp_time, 'values', newp_values )
;    p_data = CREATE_STRUCT( 'time', p_time, 'values', p_values )
    RETURN, p_data
END

