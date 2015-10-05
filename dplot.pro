PRO dplot
;{
    xax = intarr( 10 )
    yax = intarr( 10 )
    yax2 = intarr( 10 )

    FOR i=0ul,(9) DO BEGIN ;{
	xax[i] = i
	yax[i] = i
	yax2[i] = i+1
    ENDFOR ;}

    ; Set the color table
    colortable = 33
    TVLCT, oldr,oldg,oldb,/GET
    if( N_Elements(colortable) EQ 1 ) then begin ;{
	LOADCT, colortable, /silent
	TVLCT, r,g,b,/GET
	r[0]=0 & r[255]=255
	g[0]=0 & g[255]=255
	b[0]=0 & b[255]=255
	colortable=[[r],[g],[b]]
    endif ;}
    TVLCT, colortable

    UTfirst = 0
    UTlast = 0
    !p.multi= [0,1,1]
    !y.style=1
    !x.style=1
    !x.margin=[20,6]
    !y.charsize=1.5
    !x.charsize= 1.5

    PLOT,xax,yax,$
	 MIN_VALUE=-32760,$
	 MAX_VALUE=99998.,$
	 xrange =[0,9],$
	 yrange =[-5,15],$
	 ymargin=[0,0],$
	 ytitle="Y",$
	 xticks=2,$
	 background=255,$
	 color=0

    OPLOT,xax,yax2,$
	 MIN_VALUE=-32760,$
	 MAX_VALUE=99998.,$
	 color=60
END
;}

