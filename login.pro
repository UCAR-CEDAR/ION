FUNCTION cedar_login, user, password, ipaddress
;{
    r = CEDAR_AUTHENTICATE_USER( user, password )
    IF( r EQ 0 ) THEN BEGIN ;{
	y = CEDAR_CREATE_SESSION( user, ipaddress )
	IF( y EQ 0 ) THEN BEGIN ;{
	    PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
	    PRINT, '<SCRIPT LANGUAGE="JavaScript">'
	    PRINT, '<!--'
	    PRINT, 'var cookieDate = new Date() ;'
	    PRINT, 'var cookieVal = "', user, '" ;' 
	    PRINT, 'cookieDate.setTime( cookieDate.getTime() + 24*60*60*1000) ;'
	    PRINT, 'var theCookie = "OpenDAP.remoteuser=" + escape(cookieVal) + "; domain=cedarweb.hao.ucar.edu; path=/; expires=" + cookieDate.toGMTString() ;'
	    PRINT, 'document.cookie = theCookie ;'
	    PRINT, 'var theCookie = document.cookie ;'
	    PRINT, 'if( theCookie == "" )'
	    PRINT, '{'
	    PRINT, 'document.writeln( "You must enable the creation of cookies in your browser in order to sign in to CedarWeb." ) ;'
	    PRINT, 'document.writeln( "<BR />" ) ;'
	    PRINT, 'document.writeln( "Please enable cookies in your browser and refresh this page." ) ;'
	    PRINT, 'document.writeln( "<BR />" ) ;'
	    PRINT, 'document.writeln( "If you continue to experience problems logging in, please contact <A HREF=\"mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username\"><I>the CEDARweb Administrator</I></A>!" ) '
	    PRINT, 'document.writeln( "<BR />" ) ;'
	    PRINT, '}'
	    PRINT, '//-->'
	    PRINT, '</SCRIPT>'
	    PRINT, '<NOSCRIPT>'
	    PRINT, 'CedarWeb sign in uses JavaScript. Please enable JavaScript and refresh this page.'
	    PRINT, '</NOSCRIPT>'
	    PRINT, 'User <b>', user,'</b> connected to CEDARweb'
	    PRINT, '<BR />'
	    PRINT, '<BR />'
	    PRINT, '<A HREF="javascript:parent.self.close()">Continue Browsing Data</A>'
	    PRINT, '</DIV>'
	ENDIF ELSE BEGIN ;} ;{
	    IF( y EQ 18 ) THEN BEGIN ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, 'It is not possible to login <b>', user, '</b>, there is already someone else connected from this machine'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Go back to login screen</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</DIV>'
	    ENDIF ELSE BEGIN ;} ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, 'User <b>', user, '</b> is unable to login: Unknown error'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Go back to login screen</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</H1></CENTER>'
	    ENDELSE ;}
	ENDELSE ;}
    ENDIF ELSE BEGIN ;} ;{
	CASE r OF ;{
	    7 : BEGIN ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, "You must enter a username"
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Please Try Again</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</DIV>'
	    ENDCASE ;}
	    8 : BEGIN ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, "You must enter a password"
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Please Try Again</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</DIV>'
	    ENDCASE ;}
	    9 : BEGIN ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, user, ": Specified user does not exist"
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Please Try Again</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</DIV>'
	    ENDCASE ;}
	    11 : BEGIN ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, user, ": Specified password is incorrect"
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Please Try Again</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</DIV>'
	    ENDCASE ;}
	    12 : BEGIN ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, user, ": Specified user does not have permission to access CEDAR data"
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Please Try Again</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</DIV>'
	    ENDCASE ;}
	    15 : BEGIN ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, "You have not yet created a permanent password."
		PRINT, "<BR />"
		PRINT, "Please go to <A HREF='http://cedarweb.hao.ucar.edu/wiki/' TARGET='cedarwiki_aux'>the CEDAR Wiki</A>. In the upper right click on the link to log in.  You should be asked to create a new password once you log in."
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Please Try Again</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</DIV>'
	    ENDCASE ;}
	    ELSE : BEGIN ;{
		PRINT, '<DIV STYLE="text-align:center;font-size:14pt;font-weight:bold;">'
		PRINT, user, ": User does not exist or password invalid"
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, '<A HREF="/cgi-bin/ion-p?page=login.ion">Please Try Again</A>'
		PRINT, '<BR />'
		PRINT, '<BR />'
		PRINT, 'If you continue to experience problems logging in, please contact <A HREF="mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username"><I>the CEDARweb Administrator</I></A>!'
		PRINT, '</DIV>'
	    ENDELSE ;}
	ENDCASE ;}
    ENDELSE ;}
;}
END
