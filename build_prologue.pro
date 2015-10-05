PRO build_prologue, data, prologue ;{

    ; Need to make sure there is a prologue
    ; We are assuming that every prologue looks exactly the same
    ; We also assume that there is an mpar, and that each parameter in the
    ; mpar has the same number of elements
    first_prologue=data.(0).(0).prologue
    n_pvars=N_TAGS(first_prologue)
    t_pvars=TAG_NAMES(first_prologue)
    n_virtual=n_tags(data)
    FOR pv=0l,n_pvars-1 DO BEGIN ;{
	isstart=1l
	FOR v=0l,n_virtual-1 DO BEGIN ;{
	    n_level=n_tags(data.(v))
	    FOR l=0l,n_level-1 DO BEGIN ;{
		arr_size=N_ELEMENTS(data.(v).(l).mpar.(0).(0))
		curr_arr=data.(v).(l).prologue.(pv)
		FOR as=1l,arr_size-1 DO BEGIN ;{
		    curr_arr=[curr_arr,curr_arr[0]]
		ENDFOR ;}

		IF( isstart EQ 1l ) THEN BEGIN ;{
		    newarr=curr_arr
		ENDIF ELSE BEGIN ;} ;{
		    newarr=[newarr,curr_arr]
		ENDELSE ;}

		isstart=0l
	    ENDFOR ;}
	ENDFOR ;}
	stmp={name:t_pvars[pv],value:newarr}
	IF( pv EQ 0l ) THEN BEGIN ;{
	    prologue=CREATE_STRUCT(t_pvars[pv],stmp)
	ENDIF ELSE BEGIN ;} ;{
	    prologue=CREATE_STRUCT(prologue,t_pvars[pv],stmp)
	ENDELSE ;}
    ENDFOR ;}
END ;}

