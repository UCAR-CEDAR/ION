; IDL-DODS interface to the CEDAR catalog.
; Written Jose H. Garcia
; Copyright 2001, UCAR
;
; Batch file to set up system variables and link external routines.
;

PRO cedar_catalog_setup

DEFSYSV, '!cedar_catalog', EXISTS=cedar_catalog_defined
   
       ; If this is the first time run in this IDL session,
       ; then define system variables and link external routines.
       IF (cedar_catalog_defined EQ 0) THEN BEGIN
		DEFSYSV, '!cedar_catalog', 0
		DEFSYSV, '!load_catalog_query', 1
		DEFSYSV, '!get_cell', 3
                DEFSYSV, '!destroy_result_set', 4
		DEFSYSV, '!toggle_debug', 5

		so_file = 'libcedar_catalog.so'

		LINKIMAGE, 'load_catalog_query', so_file, 1
		LINKIMAGE, 'get_cell', so_file, 1
		LINKIMAGE, 'destroy_result_set', so_file, 1
		LINKIMAGE, 'toggle_debug', so_file, 0
       ENDIF
END


