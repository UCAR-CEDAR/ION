PRO binhnt,data,agg_data,p_index,print_params,k_index,kindat_parts,$
	   req_parts,i_func,use_ndays,beginning,starting,$
	   zmin,zmax,p_label,doing_print,$
	   did_plot,debug
;{
    IF( debug GT 0ul ) THEN BEGIN ;{
	fi=p_index
	IF( fi LT 10 ) THEN fi='0'+STRING( fi )
	fi=STRCOMPRESS( fi, /REMOVE_ALL )
	fn=STRING(FORMAT='(%"/project/cedar/src/pwest/apache/ion/binhnt%s.out")',fi)
	OPENW,13,fn
	PRINTF,13,'binhnt called with'
	PRINTF,13,'  p_index = ',p_index
	PRINTF,13,'  print_params = ',print_params
	PRINTF,13,'  req_parts = ',req_parts
	PRINTF,13,'  use_ndays = ',use_ndays
	PRINTF,13,'  beginning = ',beginning
	PRINTF,13,'  starting = ',starting
	PRINTF,13,'  zmin = ',zmin
	PRINTF,13,'  zmax = ',zmax
	PRINTF,13,'  p_label = ',p_label
	PRINTF,13,'  doing_print = ',doing_print
    ENDIF ;}

c_size = 1.0
n_req_parts = N_ELEMENTS( req_parts )
IF( n_req_parts EQ 1 ) THEN BEGIN ;{
    c_size = 0.5
ENDIF ;}

; binhnt, which is really just hnt, can only plot one operating mode, not
; multiple. So, if k is more than 0ul then we are calling this routine for a
; different kindat, which we can not do.
IF( k_index EQ 0ul ) THEN BEGIN ;{
    ; Build the x axis (time) uisng ut.
    n_records = N_TAGS(data.(0))
    FOR i_records=0,n_records-1 DO BEGIN ;{
	prologue = data.(0).(i_records).prologue
	yr = prologue.ibyrt
	md = prologue.ibdtt
	mnth = md/100
	day = md MOD 100
	hm = prologue.ibhmt
	hr = hm/100
	mn = hm MOD 100
	uth=( JULDAY( STRING( mnth ), STRING( day ), STRING( yr ), $
	              STRING( hr ), STRING( mn ) ) - beginning ) + 1
	IF( i_records EQ 0 ) THEN x=[uth] ELSE x=[x,uth]
    ENDFOR ;}
    delta_x = x[1] - x[0]
    doy_start = starting - beginning + 1
    doy_end = doy_start + use_ndays
    ;xrange=[doy_start,doy_end]
    xrange = [MIN( x ), MAX( x ) + delta_x]
    nx = N_ELEMENTS( x )
    xlabel = 'Time (UT)'
    ;nrange = FIX(nx*(xrange[1]-xrange[0])/(doy_end-doy_start))	; # of profiles in xrange
    nrange = FIX(nx*(xrange[1]-xrange[0])/(MAX(x)-MIN(x)))	; # of profiles in xrange
    IF( debug GT 0ul ) THEN BEGIN ;{
	PRINTF,13,'x = '
	PRINTF,13,x
	PRINTF,13,''
    ENDIF ;}
    
    ; Build the y axis (height/gdalt)
    y = agg_data.(0).gdalt.value( UNIQ( agg_data.(0).gdalt.value, SORT( agg_data.(0).gdalt.value ) ) )
    yrange = [ MIN( y ), MAX( y ) ]
    ny = N_ELEMENTS( y )
    yoffset = ( y[0] - yrange[0] ) > 0
    nyplot = FIX(ny * (yrange[1]-yrange[0])/(y[ny-1]-y[0]))
    ylabel = 'Height (km)'
    IF( debug GT 0ul ) THEN BEGIN ;{
	PRINTF,13,'y = '
	PRINTF,13,y
	PRINTF,13,''
    ENDIF ;}

    ; Build the 2 dimensional image array
    missing_value = -32767
    ;nan = 0/0
    nan = missing_value
    nx = N_ELEMENTS( x )
    ny = N_ELEMENTS( y )
    z = FLTARR( nx, ny )
    p_tags = TAG_NAMES( agg_data.(0) )
    p_tag_index = WHERE( p_tags EQ req_parts[p_index], p_tag_there )
    IF( debug GT 0ul ) THEN BEGIN ;{
	PRINTF,13,'looking for ',req_parts[p_index]
	PRINTF,13,'looking in ',p_tags
	PRINTF,13,'p_tag_index = ',p_tag_index
	PRINTF,13,'p_tag_there = ',p_tag_there
    ENDIF ;}

    IF( p_tag_there NE 0 ) THEN BEGIN ;{
	p_data = agg_data.(0).(p_tag_index[0]).value
	id = 0ul
	FOR ix = 0ul,nx-1 DO BEGIN ;{
	    gdalt = data.(0).(ix).mpar.gdalt.gdalt
	    ng = N_ELEMENTS( gdalt )
	    iy = 0ul
	    FOR ig = 0ul,ng-1 DO BEGIN ;{
		WHILE( gdalt[ig] NE y[iy] ) DO BEGIN ;{
		    z[ix,iy] = nan
		    iy++
		ENDWHILE ;}
		IF( p_data[id] EQ missing_value ) THEN z[ix,iy] = nan ELSE z[ix,iy] = p_data[id]
		id++
		iy++
	    ENDFOR ;}
	ENDFOR ;}
	;zmin = MIN( z, /NAN )
	;zmax = MAX( z, /NAN )
	zrange = [ zmin, zmax ]
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'z = '
	    PRINTF,13,z
	    PRINTF,13,''
	ENDIF ;}

	; Set the color table
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'setting the color table'
	    PRINTF,13,''
	ENDIF ;}
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
	
	xfill = 1
	IF( doing_print EQ 1 ) THEN BEGIN ;{
	    xfill = 0		; xfill is cancelled if set with the PS device
	    xthick=1.78 & ythick=1.78 & zthick=1.78
	    thick=2.7
	ENDIF ELSE BEGIN ;} ;{
	    xthick=1.0 & ythick=1.0 & zthick=1.0
	    thick=1.0
	    ;IF( !d.window EQ -1 ) THEN window,28,xsize=600,ysize=300
	ENDELSE ;}

	scrlayout = !p.multi ; [plot #, # cols, # rows, # deep, plot order]
	wsize = [!d.x_size,!d.y_size]
	windx = wsize[0]/scrlayout[1]>1
	windy = wsize[1]/scrlayout[2]>1
	nplotsonpage = scrlayout[1]*scrlayout[2]
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'scrlayout = ',scrlayout
	    PRINTF,13,'wsize = ',wsize
	    PRINTF,13,'windx = ',windx
	    PRINTF,13,'windy = ',windy
	    PRINTF,13,'nplotsonpage = ',nplotsonpage
	ENDIF ;}

	; set the x pixel size:
	xpsize = FLTARR(nx)
	FOR i=0,nx-2 DO xpsize[i] = x[i+1] - x[i] ; x[xind[i+1]]-x[xind[i]]
	xpsize[nx-1] = xpsize[nx-2]

	; Plot position (scrlayout[4]=0 => left to right, top to bottom, 1 => top to bottom,
	; left to right)
	; Lower left position is:
	plotxy = (scrlayout[0] EQ 0) ? $
	         [0,windy*(scrlayout[2]-1)>0] : $
	         [((nplotsonpage-scrlayout[0]) MOD scrlayout[1]) * windx, $
		  (scrlayout[2] - 1 - (nplotsonpage - scrlayout[0])/scrlayout[1])*windy]

	plotx0 = plotxy[0] + FIX(0.13*windx)		; used for /device coordinates
	plotx1 = plotxy[0] + FIX(0.95*windx)
	ploty0 = plotxy[1] + FIX(0.3*windy)
	ploty1 = plotxy[1] + FIX(0.9*windy)
	; width of plot in data coordinates
	delta_x = xrange[1] - xrange[0]

	;  make the final data profile more than 1 pixel wide, thus visible
	IF( xrange[1] LE MAX(x) ) THEN xrange[1] = xrange[1] + delta_x/nrange

	; used for device='ps' and xfill
	xpixsize = CEIL(xpsize*FLOAT(plotx1-plotx0)/(delta_x))

	xplimit = plotx1 - plotx0

	; Now set the y pixel size (rescale y & plotdata for screen) (((May 2005)))
	; also set is the y-offset, which is important if the bottom of the y range 
	; is below the bottom of the data.
	CASE doing_print OF ;{
	    0 : BEGIN ;{ screen (nonscalable pixels)
		nypixels = ploty1 - ploty0 - 1
		ypixsize = 1
		ypoffset = FIX(yoffset*(ploty1-ploty0)/(yrange[1]-yrange[0]))
		nyplotpixels = nypixels - ypoffset $
				- Fix((yrange[1]-y[ny-1])*(ploty1-ploty0)/(yrange[1]-yrange[0]))
		y = INTERPOL( y, nyplotpixels )
		plotdata = MAKE_ARRAY( nx, nyplotpixels, TYPE=SIZE( z, /TYPE ) )
		FOR i=0,nx-1 DO plotdata[i,*] = INTERPOL( z[i,*], nyplotpixels )
	    ENDCASE ;}
	    1 : BEGIN ;{ postscript (scalable pixels)
		; scaled to the number of data points
		ypixsize = FLOAT( ploty1 - ploty0 ) / ( nyplot )
		ypoffset = FIX( yoffset * ( ( ploty1 - ploty0 ) / ( yrange[1] - yrange[0] ) ) )
		plotdata = z
	    ENDCASE ;}
	ENDCASE ;}

	;xtickformat=''
        xtickformat='FPI_XTICKS'
	xticks=0

	IF N_ELEMENTS(xflimit) NE 0 THEN xplimit = CEIL( xflimit * FLOAT( plotx1 - plotx0 )/(delta_x))

	; First define the plot location
	; Styles are: exact ranges, suppress axes, suppress force y to 0
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'setting plot location to ', $
		      plotx0,',', $
		      ploty0,',', $
		      plotx1,',', $
		      ploty1,','
	    PRINTF,13,'xrange = ',xrange
	    PRINTF,13,'yrange = ',yrange
	    PRINTF,13,''
	ENDIF ;}
	PLOT, x, y, /NODATA, $
	      /DEVICE, POSITION=[ plotx0, ploty0, plotx1, ploty1 ], $
	      background=255,$
	      XSTYLE=21, XRANGE=xrange, YSTYLE=21, YRANGE=yrange

	; Now the x and y coordinates need to be converted to device coordinates
	; The terms are as follows:
	; plotx0(ploty0) is the axis position, add 1 to put first profile after this
	; add offset for xrange(yrange)
	; for the x-values add data scaled to the device coordinates
	xoffset = FIX( ( x[0] - xrange[0] ) * ( plotx1 - plotx0 ) / ( xrange[1] - xrange[0]) > 0 )
	x0 = plotx0 + 1 + xoffset + FIX((x - x[0])*((plotx1-plotx0)/(xrange[1]-xrange[0])))
	y0 = ploty0 + 1
	y0vec = y0 + LONG(LINDGEN(ny)*FLOAT(ploty1-ploty0)/ny)
	plotdatab=BYTSCL(plotdata, MIN=zmin, MAX=zmax, /NaN)

	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'plotting'
	    PRINTF,13,''
	ENDIF ;}
	thisRelease = Float(!Version.Release)
	IF( doing_print EQ 0 ) THEN BEGIN ;{
	    ; Decomposed color off if device supports it.
	    IF( debug GT 0ul ) THEN BEGIN ;{
		PRINTF,13,'turning off decomposed'
		PRINTF,13,''
	    ENDIF ;}

	    CASE  StrUpCase(!D.NAME) OF ;{
		'X': BEGIN ;{
		    IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
		    Device, Decomposed=0
		    ENDCASE ;}
		'WIN': BEGIN ;{
		    IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
		    Device, Decomposed=0
		    ENDCASE ;}
		'MAC': BEGIN ;{
		    IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
		    Device, Decomposed=0
		    ENDCASE ;}
		ELSE:
	    ENDCASE ;}
	ENDIF ;}
	; Now plot the image
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'actual plot'
	    PRINTF,13,''
	ENDIF ;}
	FOR i=0,nx-1 DO BEGIN ;{
	    x0i = x0[i]
	    IF( xfill ) THEN BEGIN ;{
		done = 0
		REPEAT BEGIN ;{
		    TV, plotdatab[i,*], x0i, y0 + ypoffset
		    x0i = x0i + 1
		    IF( ((x0i GT (x0[(i+1)<(nx-1)])) AND (i LT nx-1)) $
		        OR (x0i GE x0[i]+xpixsize[i]) $
		        OR (x0i GE x0[i]+xplimit) $
		        OR (x0i GE plotx1) ) $
		    THEN done=1
		ENDREP UNTIL done ;}
	    ENDIF ELSE BEGIN ;} ;{
		; TV, plotdatab[i,*], x0i, y0+ypoffset, /DEVICE,XSIZE=xpixsize[i],YSIZE=ypixsize*ny
		; Here we will go to using polyfill. The x vector will contain the x-positions, 
		; which are centered at the x0i position and go 1/2 way to the previous and next 
		; x-positions. The y vector will be set with the same idea. The color value is 
		; given by plotdatab, and if zmin is greater than 0, then a plotdatab value of 
		; zero is not plotted or plotted as transparent. Will use plotdata2 to determine 
		; whether the polygon is plotted.
		; 
		FOR j=0,ny-1 DO BEGIN ;{
		    IF FINITE(plotdata[i,j]) AND (z[i,j] GE zmin) AND (z[i,j] LE zmax) THEN BEGIN ;{
			x1 = x0i + [-xpixsize[i]/2, xpixsize[i]/2, xpixsize[i]/2, -xpixsize[i]/2]
			y1 = y0vec[j] + [-ypixsize/2, -ypixsize/2, ypixsize/2, ypixsize/2] + ypoffset + 40 ; 40 for PS device
			minfill = (zmin GT 0)?1:0
			POLYFILL,x1,y1,color=(z[i,j]>minfill)<254,/Device, Thick=0.1
		    ENDIF ;}
		ENDFOR ;}
	    ENDELSE ;}
	ENDFOR ;}
	IF( doing_print EQ 0 ) THEN BEGIN ;{
	    ; Restore Decomposed state if necessary.
	    IF( debug GT 0ul ) THEN BEGIN ;{
		PRINTF,13,'turning decomposed back on'
		PRINTF,13,''
	    ENDIF ;}

	    CASE StrUpCase(!D.NAME) OF ;{
		'X': BEGIN ;{
		    IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
		    ENDCASE ;}
		'WIN': BEGIN ;{
		    IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
		    ENDCASE ;}
		'MAC': BEGIN ;{
		    IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
		    ENDCASE ;}
		ELSE:
	    ENDCASE ;}
	ENDIF ;}

	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'plotting coordinate system'
	    PRINTF,13,''
	ENDIF ;}

	; make the coordinate system using "PLOT"
	dummy=FPI_XTICKS(BEGINNING=beginning)
	dummy=LABEL_DATE(DATE_FORMAT='%H:%I')
	PLOT, x, y, /NODATA, /NOERASE, $
	      /DEVICE,  POSITION=[plotx0,ploty0,plotx1,ploty1], $
	      CHARSIZE=c_size,$
	      XSTYLE=1, XRANGE=xrange, YSTYLE=1, YRANGE=yrange, $
	      XTITLE=xlabel, YTITLE=ylabel, TITLE=title, $
	      XTICKFORMAT=xtickformat,$
	      XTICKS=xticks, $
	      XTHICK=xthick, ythick=ythick, zthick=zthick, thick=thick, $
	      color=0,background=255

	; Print colorbar
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'displaying colorbar'
	    PRINTF,13,''
	ENDIF ;}

	IF( doing_print EQ 1 ) THEN BEGIN ;{
	    colortable[255,*]=[0,0,0]
	    colortable[0,*]=[255,255,255]
	    TVLCT,colortable
	ENDIF ;}

	;IF( debug GT 0ul ) THEN BEGIN ;{
	    ;PRINTF,13,'resetting zmax and zmin'
	    ;PRINTF,13,'  original zmin = ',zmin
	    ;PRINTF,13,'  original zmax = ',zmax
	;ENDIF ;}
	;IF( ALOG10(zmax-zmin) GT 1 ) THEN zmin=LONG(zmin) & zmax=LONG(zmax)
	;IF( debug GT 0ul ) THEN BEGIN ;{
	    ;PRINTF,13,'  new zmin = ',zmin
	    ;PRINTF,13,'  new zmax = ',zmax
	;ENDIF ;}

	; cbarvert is set to display the color bar vertical. We don't want
	; it vertical so the first part of the code is run. We keep it here
	; just in case we want it vertical.
	IF( NOT(KEYWORD_SET( cbarvert ) ) ) THEN BEGIN ;{
	    vertical=0 
	    cbx0 = FLOAT(plotx0)/wsize[0]
	    cby0 = FLOAT(ploty0)/wsize[1] - 0.35*FLOAT(ploty1-ploty0)/wsize[1]
	    position=[cbx0, cby0, $
		      cbx0 + FLOAT(plotx1-plotx0)/wsize[0], $
		      cby0 + 0.04*(ploty1-ploty0)/wsize[1]]
	    right=0
	ENDIF ELSE BEGIN ;} ;{
	    vertical=1
	    cbx0 = (FLOAT(plotx1)+wsize[0]*0.01)/wsize[0]
	    cby0 = FLOAT(ploty0)/wsize[1]
	    position=[cbx0, cby0, $
	    cbx0 + 0.04*(plotx1-plotx0)/wsize[0], $
	    cby0 + FLOAT(ploty1-ploty0)/wsize[1]]
	    right=1
	ENDELSE ;}

	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'calling colorbar'
	    PRINTF,13,'  zmin = ',zmin
	    PRINTF,13,'  zmax = ',zmax
	    PRINTF,13,'  position = ',position
	    PRINTF,13,'  p_label = ',p_label
	    PRINTF,13,'  vertical = ',vertical
	    PRINTF,13,'  right = ',right
	ENDIF ;}
	format=''
	IF( zmax GT 99999 ) THEN format='(e8.1)'
	IF( zmin LT -9999 ) THEN format='(e8.1)'
	COLORBAR,RANGE=[zmin,zmax],position=position, $ 
		 CHARSIZE=c_size,$
	         FORMAT=format,title=p_label, Divisions=0, $
		 vertical=vertical,right=right,color=0
	IF( debug GT 0ul ) THEN BEGIN ;{
	    PRINTF,13,'done calling colorbar'
	ENDIF ;}

	IF( doing_print EQ 1 ) THEN BEGIN ;{
	    colortable[255,*]=[255,255,255]
	    colortable[0,*]=[0,0,0]
	    TVLCT,colortable
	ENDIF ;}

	did_plot = 1ul

	; For some reason restoring the color table turns off color, so
	; don't do it. It doesn't seem to break anything ... YET
	; Restore the color table
	;TVLCT, oldr, oldg, oldg
    ENDIF ;}

    IF( debug GT 0ul ) THEN BEGIN ;{
	PRINTF,13,'done plotting var'
	CLOSE,13
    ENDIF ;}
ENDIF ;}

;}
END

