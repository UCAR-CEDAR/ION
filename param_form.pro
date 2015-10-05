pro param_form,params ;{
    n_p_tags=n_tags(params)
    ;*********************************************************************
    ; Any parameters that aren't to be plotted should be displayed in
    ; the top part of the table next to the plot text, with the check
    ; boxes unchecked
    ;*********************************************************************
    print,'<TR>'
    print,'<TD WIDTH="100%" HEIGHT="300" VALIGN="TOP">'
    anynot=0
    for i_p_tags=0ul,n_p_tags-1 do begin ;{
	curr_param=params.(i_p_tags)
	if ( curr_param.p_onoff eq 0 ) then begin ;{
	    if( anynot eq 0 ) then begin ;{
		print,'<DIV CLASS="mainctext">'
		print,'Parameters not plotted<BR />(check to plot)'
		print,'<BR /><BR />'
		print,'<INPUT TYPE="SUBMIT" NAME="REPLOT" VALUE="RePlot" PERSIST="TRUE">'
		print,'</DIV>'
		print,'<DIV CLASS="mainltext">'
		print,'<BR />'
	    endif else begin ;} ;{
		print,'<DIV CLASS="mainltext">'
	    endelse ;}
	    anynot=anynot+1
	    print,'<INPUT TYPE="HIDDEN" NAME="PARAM_LIST" VALUE="',curr_param.p_code,'">'
	    print,'<INPUT TYPE="CHECKBOX"> ',curr_param.p_code,' - ',curr_param.name
	    print,'<INPUT TYPE="HIDDEN" NAME="MINS" VALUE="',curr_param.p_min,'">'
	    print,'<INPUT TYPE="HIDDEN" NAME="MAXS" VALUE="',curr_param.p_max,'">'
	    print,'<INPUT TYPE="HIDDEN" NAME="LABELS" VALUE="',curr_param.p_label,'">'
	    print,'<INPUT TYPE="HIDDEN" NAME="BOGUS">'
	    print,'</DIV>'
	endif ;}
    endfor ;}
    print,'</TD>'
    print,'</TR>'
    ;*********************************************************************
    ; Now display the form for the parameters that are being plotted,
    ; with the min, max, and label and checkbox
    ;*********************************************************************
    for i_p_tags=0ul,n_p_tags-1 do begin ;{
	curr_param=params.(i_p_tags)
	if ( curr_param.p_onoff ne 0 ) then begin ;{
	    print,'<TR>'
	    print,'<TD WIDTH="100%" VALIGN="CENTER" HEIGHT="300">'
	    print,'<TABLE WIDTH="100%" CELLPADDING="1" CELLSPACING="1" BORDER="0">'
	    print,'<TR>'
	    print,'<TD WIDTH="100%">'
	    print,'<DIV CLASS="mainltext">'
	    print,curr_param.p_code,' - ',curr_param.name,'<BR />',curr_param.longname,'<BR />'
	    print,'<INPUT TYPE="HIDDEN" NAME="PARAM_LIST" VALUE="',curr_param.p_code,'">'
	    print,'</DIV>'
	    print,'</TD>'
	    print,'</TR>'
	    print,'<TR> '
	    print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
	    print,'</TR>'
	    print,'<TR>'
	    print,'<TD WIDTH="100%">'
	    print,'<DIV CLASS="mainltext">'
	    print,'Plot this param <INPUT TYPE="CHECKBOX" CHECKED>'
	    print,'</DIV>'
	    print,'</TD>'
	    print,'</TR>'
	    print,'<TR> '
	    print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
	    print,'</TR>'
	    print,'<TR>'
	    print,'<TD WIDTH="100%">'
	    print,'<DIV CLASS="mainltext">'
	    print,'Min Value'
	    print,'<BR />'
	    print,'<INPUT TYPE="TEXT" NAME="MINS" VALUE="',curr_param.p_min,'" SIZE="10">'
	    print,'</DIV>'
	    print,'</TD>'
	    print,'</TR>'
	    print,'<TR> '
	    print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
	    print,'</TR>'
	    print,'<TR>'
	    print,'<TD WIDTH="100%">'
	    print,'<DIV CLASS="mainltext">'
	    print,'Max Value'
	    print,'<BR />'
	    print,'<INPUT TYPE="TEXT" NAME="MAXS" VALUE="',curr_param.p_max,'" SIZE="10">'
	    print,'</DIV>'
	    print,'</TD>'
	    print,'</TR>'
	    print,'<TR> '
	    print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
	    print,'</TR>'
	    print,'<TR>'
	    print,'<TD WIDTH="100%">'
	    print,'<DIV CLASS="mainltext">'
	    print,'Label'
	    print,'<BR />'
	    print,'<INPUT TYPE="TEXT" NAME="LABELS" VALUE="',curr_param.p_label,'" SIZE="20">'
	    print,'</DIV>'
	    print,'</TD>'
	    print,'</TR>'
	    print,'<TR> '
	    print,'<TD HEIGHT="2" VALIGN="top" ALIGN="RIGHT"><IMG SRC="/images/red_dot.gif" WIDTH="100%" height="1"></TD>'
	    print,'</TR>'
	    print,'<TR>'
	    print,'<TD WIDTH="100%">'
	    print,'<DIV CLASS="mainltext">'
	    print,'<BR />'
	    print,'<INPUT TYPE="SUBMIT" NAME="REPLOT" VALUE="RePlot" PERSIST="TRUE">'
	    print,'</DIV>'
	    print,'</TD>'
	    print,'</TR>'
	    print,'</TABLE>'
	    print,'</TD>'
	    print,'</TR>'
	endif ;}
    endfor ;}
end ;}
