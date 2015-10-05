; IDL-Cedar interface.
; Written by Patrick C. West and Peter Fox - UCAR
; Copyright 2006, UCAR - please see COPYRIGHT_UCAR for complete information
;
; filters out missing values for param and returns an index to be
; used to filter other quanities
PRO missingvalue, oldparam, newparam, paramindex, n_valid, $
                  MISSING_VALUE=missing_value
;{

    IF (NOT KEYWORD_SET(missing_value)) THEN missing_value=-32767
    paramindex=WHERE( oldparam GT missing_value, n_valid)
    IF( n_valid NE 0 ) THEN BEGIN ;{
	newparam=oldparam(paramindex)
    ENDIF ;}
END ;}

; opendap_object is the DAP object returned from a call to opendap_get
; kinst is the Instrument Code to be matched.
; kindat is array of kinds of data to be matched. with kinst forms record_type
; request is the string array of variables to be returned, should
; include all 'coordinate' variables
; results is a structure built up using the names of 'request' with
; the values inserted, longnames, units, etc.
PRO aggregate,opendap_object,kinst,kindats,request, $
	       longnames,scales,units,results
;{

    missingvalue=-32767

    ; parse the dds of the OPeNDAP object to return a tree listing 
    ; of tags names and structure indices used to reference them
    dods_variables, opendap_object, ntree, treelist, namelist
    ;print_dods_variables,ntree,treelist,namelist

    n_request=N_ELEMENTS(request)
    tags=TAG_NAMES(opendap_object)
    n_virtual=N_TAGS(opendap_object)
    n_kindats = N_ELEMENTS( kindats )

    k_start = 1ul
    FOR k=0l, (n_kindats - 1) DO BEGIN ;{
	curr_kindat = kindats[k]
	has_data = 0ul
	FOR v=0l,n_virtual-1 DO BEGIN ;{
	    n_level=N_TAGS(opendap_object.(v))
	    virtual_record_select=INTARR(n_level)

	    ;determine which records match record_type, i.e. KINST/KINDAT
	    FOR n=0l,n_level-1 DO BEGIN ;{
		curr_prologue = opendap_object.(v).(n).prologue
		IF( ( curr_prologue.KINST EQ kinst ) AND $
		    ( curr_prologue.KINDAT EQ curr_kindat ) ) THEN BEGIN ;{
		    virtual_record_select[n] = 1
		ENDIF ;}
	    ENDFOR ;}
	    IF( v EQ 0ul ) THEN BEGIN ;{
		record_select=CREATE_STRUCT(tags[v],virtual_record_select)
	    ENDIF ELSE BEGIN ;} ;{
		record_select=CREATE_STRUCT(record_select,tags[v],virtual_record_select)
	    ENDELSE ;}
	ENDFOR ;}

	;scan namelist and use treelist and ntree to locate element
	;indices from treelist(o:o+ntree(s)-1) where o=sum(ntree(s-1))+1
	isstart=1ul
	FOR r=0l,n_request-1 DO BEGIN ; { search requested fields
	    ; If the parameter wasn't in the das then there will be a blank
	    ; request variable, so skip it.
	    IF( request[r] NE '' ) THEN BEGIN ;{
		;locate all occurences of the parameter in the namelist.
		;This check is looking for variables in the mpar.
		;only some of these may correspond to a valid record_type
		n_select=0l
		select=WHERE(STRPOS(namelist,request[r]+'.'+request[r]) ne -1,n_select)
		;reset dimension counter for aggregation
		dim=0l

		;verify we have a match
		IF (n_select GT 0) THEN BEGIN ;{
		    ;aggregation over each valid selection
		    scorrect=0l
		    FOR s=0l,n_select-1 DO BEGIN ;{
			;calculate offset for treelist pointer
			offset=TOTAL(ntree(0:select(s)-1))+1
			;fetch valid indices from treelist
			indx=treelist(offset:offset+ntree(select(s))-1)
			;only use the correct records in the aggregation
			IF ( record_select.(indx[0])[indx[1]] ) THEN BEGIN ;{
			    ;assume 5 here....
			    ;aggregate dimension counter
			    dim=dim+opendap_object.(indx[0]).(indx[1]).(indx[2]).(indx[3]).(indx[4]+1)(2)+1
			    ;aggregate values in temporary array
			    IF (scorrect EQ 0) THEN BEGIN ;{
				tmp=FLOAT(opendap_object.(indx[0]).(indx[1]).(indx[2]).(indx[3]).(indx[4]))
			    ENDIF ELSE BEGIN ;} ;{
				tmp=[tmp,FLOAT(opendap_object.(indx[0]).(indx[1]).(indx[2]).(indx[3]).(indx[4]))]
			    ENDELSE ;}
			    scorrect=scorrect+1
			ENDIF ;}
		    ENDFOR ;}
		    IF( scorrect GT 0l ) THEN BEGIN ;{
			;apply scaling to temporary array
			tryme=where(tmp gt missingvalue,tryme_count)
			IF( tryme_count ne 0 ) THEN BEGIN ;{
			    tmp(where (tmp gt missingvalue))=tmp(where (tmp gt missingvalue))*scales[r]
			    ;build a structure using the attributes that go with this request
			    stmp={name:request[r],value:tmp,dim:dim,long_name:longnames[r],units:units[r],missing_value:missingvalue}
			    ;add it to the structure to be returned
			    IF isstart EQ 1ul THEN BEGIN ;{
				kresults=CREATE_STRUCT(request[r],stmp)
				isstart=0ul
			    ENDIF ELSE BEGIN ;} ;{
				kresults=CREATE_STRUCT(kresults,request[r],stmp)
			    ENDELSE ;}
			    has_data = 1ul
			ENDIF ;}
		    ENDIF ELSE BEGIN ;} ;{
			;PRINT,request[r],' does not have any data'
		    ENDELSE ;}
		ENDIF ELSE BEGIN ;} ;{
		    ; perhaps the variable is in the jpar
		    n_select=0l
		    select = WHERE( STRPOS( namelist,'JPAR.'+request[r] ) ne -1,n_select )
		    IF( n_select GT 0 ) THEN BEGIN ;{
			;aggregation over each valid selection
			scorrect=0l
			FOR s=0l, n_select-1 DO BEGIN ;{
			    ;calculate offset for treelist pointer
			    offset=TOTAL(ntree(0:select(s)-1))+1
			    ;fetch valid indices from treelist
			    indx=treelist(offset:offset+ntree(select(s))-1)
			    ;only use the correct records in the aggregation
			    IF( record_select.(indx[0])[indx[1]] ) THEN BEGIN ;{
				;aggregate values in temporary array
				arr_size=N_ELEMENTS(opendap_object.(indx[0]).(indx[1]).mpar.(0).(0))
				tmp1 = FLTARR( arr_size )
				tmp1[0:arr_size-1] = opendap_object.(indx[0]).(indx[1]).(indx[2]).(indx[3])[0]
				IF( scorrect EQ 0 ) THEN BEGIN ;{
				    tmp=tmp1
				ENDIF ELSE BEGIN ;} ;{
				    tmp=[tmp,tmp1]
				ENDELSE ;}
				scorrect=scorrect+1
			    ENDIF ;}
			ENDFOR ;}
			IF( scorrect GT 0l ) THEN BEGIN ;{
			    ;apply scaling to temporary array
			    tryme=where(tmp gt missingvalue,tryme_count)
			    IF( tryme_count ne 0 ) THEN BEGIN ;{
				tmp(where (tmp gt missingvalue))=tmp(where (tmp gt missingvalue))*scales[r]
				;build a structure using the attributes that go with this request
				stmp={name:request[r],value:tmp,dim:1,long_name:longnames[r],units:units[r],missing_value:missingvalue}
				;add it to the structure to be returned
				IF isstart EQ 1ul THEN BEGIN ;{
				    kresults=CREATE_STRUCT(request[r],stmp)
				    isstart=0ul
				ENDIF ELSE BEGIN ;} ;{
				    kresults=CREATE_STRUCT(kresults,request[r],stmp)
				ENDELSE ;}
				has_data = 1ul
			    ENDIF ;}
			ENDIF ELSE BEGIN ;} ;{
			    ;PRINT,request[r],' does not have any data'
			ENDELSE ;}
		    ENDIF ELSE BEGIN ;} ;{
			;PRINT,request[r],' does not have any data'
		    ENDELSE ;}
		ENDELSE ;}
	    ENDIF ;}
	ENDFOR ;}
	IF( has_data EQ 1ul ) THEN BEGIN ;{
	    tag_name = 'KINDAT_' + STRCOMPRESS( STRING( curr_kindat ), /REMOVE_ALL )
	    IF( k_start EQ 1ul ) THEN BEGIN ;{
		k_start = 0ul
		results = CREATE_STRUCT( tag_name, kresults )
	    ENDIF ELSE BEGIN ;} ;{
		results = CREATE_STRUCT( results, tag_name, kresults )
	    ENDELSE ;}
	ENDIF ;}
    ENDFOR ;}

    ;BUILD_PROLOGUE, opendap_object, prologue
    ;results=CREATE_STRUCT(results,"prologue",prologue)
END ;}

