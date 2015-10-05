PRO print_dods_variables,ntree,treelist,namelist
    ;print a tree listing of the names and index positions of
    ;all entries in an IDL data structure; max 8 deep.
    ;requires a call to DODS_VARIABLES to populate input arrays
    ;OUTPUT printed.
    namelist_count=n_elements(namelist)
    offset=1l
    for i=0,namelist_count-1 do begin
	print,'<BR />'
	print,'offset=',offset
	print,'ntree(',i,')=',ntree(i)
	print,'high=',offset+ntree(i)-1
	print,'namelist(',i,')=',namelist(i)
	print,"Dataset ",namelist(i),i,":",treelist(offset:offset+ntree(i)-1)
	offset=offset+ntree(i)
    endfor
END

PRO dods_variables,data,ntree,treelist,namelist ;{
    ;construct a tree listing of the names and index positions of
    ;all entries in an IDL data structure; max 8 deep.
    ; INPUT data
    ; OUTPUT ntree
    ;        treelist
    ;        namelist
    ntags=n_tags(data)
    nm=tag_names(data)
    namelist=['ds']
    ntree=[0]
    tree=[0]
    treelist=tree
    offset=0
    namelist_count=1
    pre_namelist=strarr(8)
    pre_namelist(0)=namelist(namelist_count-1)

    for l=0,ntags-1 do begin ;{
	pre_tree=[l]
	namelist(namelist_count-1)=pre_namelist(0)+"."+nm(l)
	ntags_1=n_tags(data.(l)) 
	if ntags_1 gt 0 then begin ;{
	    nm_1=tag_names(data.(l))
	    pre_namelist(1)=string(namelist(namelist_count-1))
	    for l1=0,ntags_1-1 do begin ;{
		tree=[pre_tree,l1]
		ntree(namelist_count-1)=n_elements(tree)
		offset=offset+1
		namelist(namelist_count-1)=pre_namelist(1)+"."+nm_1(l1)
		ntags_2=n_tags(data.(l).(l1)) 
		if ntags_2 gt 0 then begin ;{
		    nm_2=tag_names(data.(l).(l1))
		    pre_namelist(2)=string(namelist(namelist_count-1))
		    for l2=0,ntags_2-1 do begin ;{
			tree=[pre_tree,l1,l2]
			ntree(namelist_count-1)=n_elements(tree)
			offset=offset+1
			namelist(namelist_count-1)=pre_namelist(2)+"."+nm_2(l2)
			ntags_3=n_tags(data.(l).(l1).(l2)) 
			if ntags_3 gt 0 then begin ;{
			    nm_3=tag_names(data.(l).(l1).(l2))
			    pre_namelist(3)=namelist(namelist_count-1)
			    for l3=0,ntags_3-1 do begin ;{
				tree=[pre_tree,l1,l2,l3]
				ntree(namelist_count-1)=n_elements(tree)
				offset=offset+1
				namelist(namelist_count-1)=pre_namelist(3)+"."+nm_3(l3)
				ntags_4=n_tags(data.(l).(l1).(l2).(l3)) 
				if ntags_4 gt 0 then begin ;{
				    nm_4=tag_names(data.(l).(l1).(l2).(l3))
				    pre_namelist(4)=namelist(namelist_count-1)
				    for l4=0,ntags_4-1 do begin ;{
					tree=[pre_tree,l1,l2,l3,l4]
					ntree(namelist_count-1)=n_elements(tree)
					offset=offset+1
					namelist(namelist_count-1)=pre_namelist(4)+"."+nm_4(l4)
					ntags_5=n_tags(data.(l).(l1).(l2).(l3).(l4)) 
					if ntags_5 gt 0 then begin ;{
					    nm_5=tag_names(data.(l).(l1).(l2).(l3).(l4))
					    pre_namelist(5)=namelist(namelist_count-1)
					    for l5=0,ntags_5-1 do begin ;{
						tree=[pre_tree,l1,l2,l3,l4,l5]
						ntree(namelist_count-1)=n_elements(tree)
						offset=offset+1
						namelist(namelist_count-1)=pre_namelist(5)+"."+nm_5(l5)
						ntags_6=n_tags(data.(l).(l1).(l2).(l3).(l4).(l5)) 
						if ntags_6 gt 0 then begin ;{
						    nm_6=tag_names(data.(l).(l1).(l2).(l3).(l4).(l5))
						    pre_namelist(6)=namelist(namelist_count-1)
						    for l6=0,ntags_6-1 do begin ;{
							tree=[pre_tree,l1,l2,l3,l4,l5,l6]
							ntree(namelist_count-1)=n_elements(tree)
							offset=offset+1
							namelist(namelist_count-1)=pre_namelist(6)+"."+nm_6(l6)
							ntags_7=n_tags(data.(l).(l1).(l2).(l3).(l4).(l5).(l6))
							if ntags_7 gt 0 then begin ;{
							    nm_7=tag_names(data.(l).(l1).(l2).(l3).(l4).(l5).(l6))
							    pre_namelist(7)=namelist(namelist_count-1)
							    for l7=0,ntags_7-1 do begin ;{
								tree=[pre_tree,l1,l2,l3,l4,l5,l6,l7]
								ntree(namelist_count-1)=n_elements(tree)
								offset=offset+1
								namelist(namelist_count-1)= pre_namelist(7)+"."+$
								nm_7(l7)
								namelist_count=namelist_count+1 
								namelist=[namelist,pre_namelist(0)]
							    endfor ;}
							endif else begin ;} ;{
							    treelist=[treelist,tree]
							    ntree=[ntree,1]
							    namelist_count=namelist_count+1 
							    namelist=[namelist,pre_namelist(0)]
							endelse ;}
						    endfor ;}
						endif else begin ;} ;{
						    treelist=[treelist,tree]
						    ntree=[ntree,1]
						    namelist_count=namelist_count+1 
						    namelist=[namelist,pre_namelist(0)]
						endelse ;}
					    endfor ;}
					endif else begin ;} ;{
					    treelist=[treelist,tree]
					    ntree=[ntree,1]
					    namelist_count=namelist_count+1 
					    namelist=[namelist,pre_namelist(0)]
					endelse ;}
				    endfor ;}
				endif else begin ;} ;{
				    treelist=[treelist,tree]
				    ntree=[ntree,1]
				    namelist_count=namelist_count+1 
				    namelist=[namelist,pre_namelist(0)]
				endelse ;}
			    endfor ;}
			endif else begin ;} ;{
			    treelist=[treelist,tree]
			    ntree=[ntree,1]
			    namelist_count=namelist_count+1 
			    namelist=[namelist,pre_namelist(0)]
			endelse ;}
		    endfor ;}
		endif else begin ;} ;{
		    treelist=[treelist,tree]
		    ntree=[ntree,1]
		    namelist_count=namelist_count+1 
		    namelist=[namelist,pre_namelist(0)]
		endelse ;}
	    endfor ;}
	endif else begin ;} ;{
	    treelist=[treelist,tree]
	    ntree=[ntree,1]
	    namelist_count=namelist_count+1 
	    namelist=[namelist,pre_namelist(0)]
	endelse ;}
    endfor ;}
    namelist_count=namelist_count-1 
    namelist=namelist(0:namelist_count-1)
END ;}
