; IDL-Cedar interface.
; Written by Patrick C. West and Peter Fox - UCAR
; Copyright 2006, UCAR - please see COPYRIGHT_UCAR for complete information
;
; takes das from a previous call and parses the CEDAR form into
; important metadata which will be used later for all sorts of
; things.

FUNCTION opendap_parse_das,das,kinst,kindats,paralist,request,code,site,latitude,longitude,elev,parcods,reqcods,longnames,scales,units ;{
    ; kindats is an array of kindat values to be matched against data we want
    ; kinst is provided and is the Instrument Code to be matched.
    ; kinst and kindat form the record type
    ; paralist are the requested parameter codes
    ; request are the requested parameter madrigal names
    ; code is the instrument code
    ; site is the site of the instrument
    ; location is the lat and lon of the instrument
    ; elev is the elevation of the instrument
    ; parcods are the codes of the parameters
    ; reqcods are the madrigal names of the parameters
    ; longnames are the longnames of the parameters
    ; scales are the scale of the paramters
    ; units are the unit types of the parameters

    ; if there is a problem, then set the status to 0 to return
    stat = 1

    ; n_record_type = how many virtual containers are there
    n_record_type = N_TAGS( das )
    n_paralist = N_ELEMENTS( paralist )

    ; load the top level tags for decoding in the v loop
    kd = TAG_NAMES( das )

    ; initialize return variables
    code = ''
    elev = DOUBLE( 0 )
    latitude = ''
    longitude = ''
    site = ''

    parcod = 0
    parcods = INTARR( n_paralist ) 
    reqcods = STRARR( n_paralist )
    units = STRARR( n_paralist ) 
    scales = FLTARR( n_paralist ) 
    longnames = STRARR( n_paralist ) 

    v_index = 0

    FOR v = 0l, ( n_record_type - 1 ) DO BEGIN ;{
	; extract the kinst and kindat from the top level tags. If the
	; extracted kinst and kindat are equal to what we are looking for,
	; then look into this record
	stmp = strsplit( kd[v], "_", /EXTRACT )
	das_kindat = stmp[4]
	das_kinst = stmp[6]
	tryme_count = 0l
	tryme = WHERE( kindats EQ das_kindat, tryme_count )
	IF( tryme_count GT 0ul AND das_kinst EQ kinst ) THEN BEGIN ;{
	    ; first entry is always the KINST record, treat it first and
	    ; differently

	    ; the KINST attribute contains the attributes KINST, NAME,
	    ; PREFIX LATITUDE, LONGITUDE, and ALTITUDE
	    ; we have to remove all of the leading and trailing double
	    ; quotes since the libdap parser has them in there.
	    ; FIXME: When we move to ocapi we won't have to do this
	    scode = das.(v).KINST.PREFIX
	    code = STRMID( scode, 1, STRLEN( scode ) - 2 )
	    selev = das.(v).KINST.ALTITUDE
	    elev = double( STRMID( selev, 1, STRLEN( selev ) - 2 ) )
	    qlatitude = das.(v).KINST.LATITUDE
	    slatitude = STRMID( qlatitude, 1, STRLEN( qlatitude ) - 2 )
	    ; remove the escape character for the double quote
	    bs = strpos( slatitude, '\' )
	    len = STRLEN( slatitude )
	    latitude=STRMID(slatitude,0,bs) + STRMID(slatitude,bs+1,len-bs-1)
	    qlongitude = das.(v).KINST.LONGITUDE
	    slongitude = STRMID( qlongitude, 1, STRLEN( qlongitude ) - 2 )
	    ; remove the escape character for the double quote
	    bs = strpos( slongitude, '\' )
	    len = STRLEN( slongitude )
	    longitude=STRMID(slongitude,0,bs) + STRMID(slongitude,bs+1,len-bs-1)
	    ssite = das.(v).KINST.NAME
	    site = STRMID( ssite, 1, STRLEN( scode ) - 2 )

	    ; next entries are of the form JPAR_n and MPAR_n, step 
	    ; through them and record the metadata
	    dasnames = TAG_NAMES( das.(v) )
	    n_das_entries = N_TAGS( das.(v) )
	    paraindex = 0
	    FOR n =1l, ( n_das_entries - 1 ) DO BEGIN ;{
		; determine if JPAR or MPAR
		ptype = STRMID( dasnames[n], 0, 4 )

		; The jpar and mpar attributes contain CODE, SHORTNAME,
		; LONGNAME, SCALE, UNIT
		sparcod = das.(v).(n).CODE
		parcod = FIX( STRMID( sparcod, 1, STRLEN( sparcod ) - 2 ) )

		; if the parameter code is in the paralist, which is the
		; requested parameters and it is not already in the result
		; set, then add it to the result set
		tryme_count = 0l
		tryme = WHERE( paralist EQ parcod, tryme_count )
		already_count = 0l
		already = WHERE( parcods EQ parcod, already_count )
		IF( tryme_count GT 0 AND already_count EQ 0 ) THEN BEGIN ;{
		    parcods[paraindex] = parcod
		    reqcods[paraindex] = request[tryme[0]]

		    sunit = das.(v).(n).UNIT
		    units[paraindex] = STRMID( sunit, 1, STRLEN( sunit ) - 2 )
		    sscale = das.(v).(n).SCALE
		    scales[paraindex] = DOUBLE( STRMID( sscale, 1, STRLEN( sscale ) - 2 ) )
		    slongname = das.(v).(n).LONGNAME
		    longnames[paraindex] = STRMID( slongname, 1, STRLEN( slongname ) - 2 )

		    paraindex++
		ENDIF ;}
	   ENDFOR ;}
	   v_index++
	ENDIF ;}
    ENDFOR ;}

;    if (n_record_type eq 1) then begin
;	scale=reduce(scale,/SOMETHING,n_das_entries-1) 
;    endif

    RETURN, stat
END ;}

