; IDL-Cedar interface.
; Written by Patrick C. West and Peter Fox - UCAR
; Copyright 2006, UCAR - please see COPYRIGHT_UCAR for complete information
;
; takes das from a previous call and parses the CEDAR form into
; important metadata which will be used later for all sorts of
; things.

FUNCTION opendap_parse_das,das,kinst,kindats,paralist,request,code,site,location,elev,parcods,reqcods,longnames,scales,units ;{
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
    location = DBLARR( 2 )
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

	    ; separate out the information for the KINST
	    elems = str_sep( STRCOMPRESS( das.(v).KINST.(0) ), " " )
	    nelems = N_ELEMENTS( elems )
	    IF( nelems LT 5 ) THEN BEGIN ;{
		code = '0'
		elev = '0'
		location[0] = DOUBLE( 0 )
		location[1] = DOUBLE( 0 )
		site = STRING( das_kindat )
	    ENDIF ELSE BEGIN ;} ;{
		; code is always 3 letters and is the last part of the attribute
		code = STRMID( elems[nelems-1], 0, 3 )

		; elevation is before the code
		elev = DOUBLE( elems[nelems-2] )
		not_elev = DOUBLE( -999 )
		IF( elev EQ not_elev ) THEN BEGIN ;{
		    location[0] = DOUBLE( 0 )
		    location[1] = DOUBLE( 0 )
		    IF( nelems GT 3 ) THEN BEGIN ;{
			site = STRJOIN( elems[0:nelems-3], " " )
		    ENDIF ELSE BEGIN ;} ;{
			site = elems[0]
		    ENDELSE ;}
		    site = STRMID( site, 1, STRLEN( site ) - 1 )
		ENDIF ELSE BEGIN ;} ;{
		    ; lat, lon are before the elevation
		    location[0] = DOUBLE( elems[nelems-4] )
		    location[1] = DOUBLE( elems[nelems-3] )

		    ; extract site name, which could have been split
		    ; and rejoin them
		    IF( nelems GT 5 ) THEN BEGIN ;{
			site = STRJOIN( elems[0:nelems-5], " " )
		    ENDIF ELSE BEGIN ;} ;{
			site = elems[0]
		    ENDELSE ;}
		    site = STRMID( site, 1, STRLEN( site ) - 1 )
		ENDELSE ;}
	    ENDELSE ;}

	    ; next entries are of the form JPAR_n and MPAR_n, step 
	    ; through them and record the metadata
	    dasnames = TAG_NAMES( das.(v) )
	    n_das_entries = N_TAGS( das.(v) )
	    paraindex = 0
	    FOR n =1l, ( n_das_entries - 1 ) DO BEGIN ;{
		; determine if JPAR or MPAR
		ptype = STRMID( dasnames[n], 0, 4 )

		; separate out the elements of the name
		pname = STR_SEP( TAG_NAMES( das.(v).(n)), "_" )

		; if there are 3 elements in the pname then it is a regular
		; parameter. If there are 5 elements in the pname then is is
		; the error parameter
		; extract the last element which is the code number
		IF( N_ELEMENTS( pname ) EQ 3 ) THEN BEGIN ;{
		    parcod = FIX( pname[2] )
		ENDIF ELSE BEGIN ;} ;{
		    parcod = -FIX( pname[4] )
		ENDELSE ;}

		tryme_count = 0l
		tryme = WHERE( paralist EQ parcod, tryme_count )
		already_count = 0l
		already = WHERE( parcods EQ parcod, already_count )
		IF( tryme_count GT 0 AND already_count EQ 0 ) THEN BEGIN ;{
		    parcods[paraindex] = parcod
		    reqcods[paraindex] = request[tryme[0]]

		    ; now proceed to extract the longname, scale and units
		    ; use same procedures as for KINST
		    elems = str_sep( STRCOMPRESS( das.(v).(n).(0)), " ")
		    nelems = N_ELEMENTS( elems )

		    ; strip off the trailing '"' from the last element which is
		    ; the units
		    units[paraindex]=STRMID(elems[nelems-1],0,STRLEN(elems[nelems-1])-1)

		    ; next to last element (if present) is the scale
		    scales[paraindex] = FLOAT( elems[nelems-2] )

		    ; remainder is long name, which could have been split and
		    ; rejoin them
		    IF( nelems GT 3 ) THEN BEGIN ;{
			longnames[paraindex] = STRJOIN( elems[0:nelems-3], " " )
		    ENDIF ELSE BEGIN ;} ;{
			longnames[paraindex] = elems[0]
		    ENDELSE ;}
		    longnames[paraindex] = STRMID( longnames[paraindex], 0, STRLEN( longnames[paraindex] ) )
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

