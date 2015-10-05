; IDL-Cedar interface.
; Written by Patrick C. West - UCAR
; Copyright 2006, UCAR - please see COPYRIGHT_UCAR for complete information
;
; Main interface to retrieve, parse, and aggregate cedar data given data
; selection made by the user via CedarWeb, http://cedarweb.hao.ucar.edu.
;
; kinst - instrument
; kindats - list of type of data given the instrument
; params - list of paramters selected.
; reqs - madrigal names of the selected parameters
; files - cedar data files required to retrieve satisfy request
; syear - starting year
; smonth - starting month
; sday - starting day
; eyear - ending year
; emonth - ending month
; eday - ending day
; username - CedarWeb username - the user must be logged in to the Cedar
;            website in order to retrieve data
; opendap_data - variable
; returns the status of the given request
;
; USAGE:
;
; stat=cedar_data(<kinst>,<kindat>,<params>,<reqs>,<files>,$
;                     <syear>,<smonth>,<sday>,<eyear>,<emonth>,<eday>,$
;                     <username>,opendap_data)
;
; The data is aggregated across the different files selected and units and
; scales are applied to the data.
;
; To get an idea of what the data looks like you would then invoke commands
; such as:
;
; help,opendap_data,/struct
;

FUNCTION cedar_data, kinst, kindats, params, reqs, files, $
	             syear, smonth, sday, eyear, emonth, eday, $
	             username, opendap_data, DEBUG=debug
;{
    retstat=0

    IF( N_ELEMENTS( debug ) LE 0L ) THEN debug = 0UL

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'kinst = ',kinst
	PRINT,'kindats = ',kindats
	PRINT,'params = ',params
	PRINT,'reqs = ',reqs
	PRINT,'files = ',files
	PRINT,'syear = ',syear
	PRINT,'smonth = ',smonth
	PRINT,'sday = ',sday
	PRINT,'eyear = ',eyear
	PRINT,'emonth = ',emonth
	PRINT,'eday = ',eday
	PRINT,'username = ',username
	PRINT,''
    ENDIF ;}

    IF ( kindats EQ 'undef' ) THEN BEGIN ;{
	GET_KINDAT_LIST,kinst,0ul,kindat_parts
    ENDIF ELSE BEGIN ;} ;{
	kindat_parts = STR_SEP( kindats, '|', /TRIM )
    ENDELSE ;}
    n_kindat_parts = N_ELEMENTS( kindat_parts )

    kindat_list = ''
    kinst_kindat_list = ''
    FOR i=0ul,(n_kindat_parts-1) DO BEGIN ;{
	IF( i NE 0ul ) THEN BEGIN ;{
	    kindat_list += ','
	    kinst_kindat_list += ','
	ENDIF ;}
	kindat_list += STRING( kindat_parts[i] )
	kinst_kindat_list += STRING( kinst) + '/' + STRING( kindat_parts[i] )
    ENDFOR ;}

    paralist=str_sep(params,'|',/TRIM)
    n_paralist=n_elements(paralist)
    request=str_sep(reqs,'|',/TRIM)
    filelist=str_sep(files,'|',/TRIM)
    n_filelist=n_elements(filelist)

    shr='00'
    smn='00'
    ehr='23'
    emn='59'

    ;*********************************************************************
    ; Now we are going to build the url for the das and the url for the dods
    ; request.
    ;*********************************************************************
    dat1='.constraint=%22'
    dat1=dat1+'date('+string(syear)+','+string(smonth)+string(sday)+','+string(shr)+string(smn)+',0,'
    dat1=dat1+string(eyear)+','+string(emonth)+string(eday)+','+string(ehr)+string(emn)+',5999);'
    dat1=dat1+'record_type('+kinst_kindat_list+');parameters('
    dat2=strcompress(dat1,/remove_all)

    dasurl='http://cedarweb.hao.ucar.edu/opendap?username='
    dasurl=dasurl+username
    dasurl=dasurl+'&request=define+silently+d+as+'
    FOR i=0ul,(n_filelist-1) DO BEGIN
	dasurl=dasurl+filelist[i] 
	IF (i LT (n_filelist-1)) THEN dasurl=dasurl+',' ELSE dasurl=dasurl+';'
    ENDFOR
    dasurl=dasurl+'get+das+for+d;'

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'dasurl = ',dasurl
	PRINT,''
    ENDIF ;}

    url='http://cedarweb.hao.ucar.edu/opendap?username='
    url=url+username
    url=url+'&request=define+silently+d+as+'
    constraint=''
    FOR i=0ul,(n_filelist-1) DO BEGIN ;{
	url=url+filelist[i]
	constraint=constraint+filelist[i]+dat2
	FOR j=0ul,(n_paralist-1) DO BEGIN ;{
	    constraint=constraint+string(paralist[j])
	    IF (n_paralist NE 0ul AND (j GE 0ul) AND (j LT (n_paralist-1))) THEN constraint=constraint+','
	ENDFOR ;}
	constraint=constraint+')%22'
	IF (i LT (n_filelist-1)) THEN BEGIN ;{
	    constraint=constraint+','
	    url=url+','
	ENDIF ELSE BEGIN ;} ;{
	    url=url+'+with+'+constraint
	ENDELSE ;}
    ENDFOR ;}
    url=url+';'
    url=url+'get+dods+for+d;'

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'dodsurl = ',url
	PRINT,''
    ENDIF ;}

    ;*********************************************************************
    ; Now let's go get the OPeNDAP das object and parse through it. We only want
    ; to fill in the parcods, reqcods, longnames, scales and units for the
    ; parameters that we will retrieve into the OPeNDAP data object.
    ;*********************************************************************
    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'calling get_dods to retrieve das'
	PRINT,''
    ENDIF ;}
    dasstat=get_dods(dasurl,das,mode='fulldas')
    if (dasstat ne 1) then begin ;{
	PRINT,'Problem getting the OPeNDAP das object, exiting'
	retstat=1
	RETURN,retstat
    endif ;}

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'calling opendap_parse_das with'
	PRINT,'    kinst = ',kinst
	PRINT,'    kindat_parts = ',kindat_parts
	PRINT,'    paralist = ',paralist
	PRINT,'    request = ',request
	PRINT,''
    ENDIF ;}

    parsedasstat=opendap_parse_das(das,kinst,kindat_parts,paralist,request,code,site,latitude,longitude,elev,parcods,reqcods,longnames,scales,units)
    if (parsedasstat ne 1) then begin ;{
	PRINT,'Problem parsing the OPeNDAP das object, exiting'
	retstat=2
	RETURN,retstat
    endif ;}

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'parcods = ',parcods
	PRINT,'reqcods = ',reqcods
	PRINT,'longnames = ',longnames
	PRINT,'scales = ',scales
	PRINT,'units = ',units
	PRINT,''
    ENDIF ;}

    ;*********************************************************************
    ; Go get the OPeNDAP data object, retrieving only the parameter codes
    ; required for the plottable points
    ;*********************************************************************
    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'calling get_dods to retrieve data'
	PRINT,''
    ENDIF ;}
    data=create_struct('undef',0)
    dodsstat=get_dods(url,data,mode='fulldata')
    if (dodsstat ne 1) then begin ;{
	PRINT,'Problem getting the OPeNDAP data object'
	retstat=3
	RETURN,retstat
    endif ;}

    n_data=n_tags(data)
    t_data=tag_names(data)
    IF (n_data EQ 1 AND t_data[0] EQ 'UNDEF') THEN BEGIN ;{
	PRINT,'No data available for specified date range and parameters'
	retstat=4
	RETURN,retstat
    ENDIF ;}

    ;*****************************************************************
    ; Aggregate the data. Again, we are only aggregating the parameters
    ; required for this plot, not all of the parameters in the data
    ; containers.
    ;*****************************************************************
    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'calling aggregate with'
	PRINT,'    kinst = ',kinst
	PRINT,'    kindat_parts = ',kindat_parts
	PRINT,'    reqcods = ',reqcods
	PRINT,'    longnames = ',longnames
	PRINT,'    scales = ',scales
	PRINT,'    units = ',units
	PRINT,''
    ENDIF ;}
    aggregate,data,kinst,kindat_parts,reqcods,longnames,scales,units,opendap_data

    IF( debug GT 0UL ) THEN BEGIN ;{
	PRINT,'returning with',retstat
	PRINT,''
    ENDIF ;}

    RETURN,retstat
END ;}

