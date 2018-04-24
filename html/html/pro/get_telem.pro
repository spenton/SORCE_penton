; docformat = 'rst'

;+
;  NAME: get_telem.pro
;
;  PURPOSE: Read the ascii telemetry files and return as an IDL structure.
;
; CALLING SEQUENCE:
;    out=get_telem(TIMES, [,time_in_sec=time_in_sec] [,Edge_Trim=Edge_Trim]
;            [,VERBOSE=verbose] [,DEBUG=DEBUG] [,DO_PLOT=do_plot],$
;            [,ADD_DOPPCORR=add_doppcorr][ADD_DISTCORR=add_distcorr])
;
; INPUT PARAMETERS:
;   TIMES        : A two element array that gives the [START,END] times of the SCAN.
;                  The times are in milli-seconds unless the TIME_IN_SEC keyword is set.
;   TIMES_IN_SEC :  Set if the TIMES vector is in seconds instead of milli-seconds.
;   EDGE_TRIM    : Set to the number of bins at the beginning and end of the scan to
;                  ignore in the output structure. Default is 2 bins.
;   SORT_BYGRATPOS : Set to sort the return structure in increasing gratpos (default=0)
;   SORT_BYWAVELENGTH : Set to sort the return structure in increasing wavelength (default=0)
;                      Performed after sort_bygratpos.
;   VERBOSE      :  Set if reporting of details is desired
;   DEBUG        :  Set to report additional information useful in debugging.
;	ADD_DARKCORR :  Set to include BACKGROUND CORRECTION (based on temperature)
;	ADD_DOPPCORR :  Set to include DOPPLER CORRECTION
;	ADD_DISTCORR :  Set to include DISTANCE CORRECTION
;
; OUTPUT PARAMETERS:
;     Structure of data products.
;
; EXAMPLE:
;		DownScan=[9.434134508500002E14, 9.434178736700002E14]
;		DS_telem=get_telem(DownScan,/add_darkcorr,/add_distcor,/add_doppcorr)
;		help,DS_telem,/str
;
;   START_TIME      FLOAT       9.43413e+14
;   END_TIME        FLOAT       9.43418e+14
;   TIMES_MS        DOUBLE    Array[2354]
;   TIMES_S         DOUBLE    Array[2354]
;   TIME_MS0        DOUBLE       9.4341346e+14
;   TIME_S0         DOUBLE       9.4341346e+11
;   TEMPS           DOUBLE    Array[2354]
;   GGRATPOS        FLOAT     Array[2354]
;   GWAVES          DOUBLE    Array[2354]
;   GCOUNTS         FLOAT     Array[2354]
;   IRR             DOUBLE    Array[2354]
;   WAVES           DOUBLE    Array[2354]
;   COUNTS          DOUBLE    Array[2354]
;   DELTA_WAVES     DOUBLE    Array[2354]
;   BINSIZE         DOUBLE        0.0063524922
;   DOPPCORR        INT              1
;   DWAVES          DOUBLE    Array[2354]
;   DW              DOUBLE    Array[2354]
;   DISTCORR        INT              1
;   DCOUNTS         DOUBLE    Array[2354]
;   DR              DOUBLE    Array[2354]
;   DARKCORR        INT              1
;   BKGCOUNTS       DOUBLE    Array[2354]
;   BKG             DOUBLE    Array[2354]
;   INTTIME_S       FLOAT     Array[2354]
;   EDGE_TRIM       INT              2
;-

function get_telem,times,time_in_sec=time_in_sec,debug=debug,$
	Edge_Trim=Edge_Trim,verbose=verbose,dark=dark,do_plot=do_plot,$
	sort_bywavelength=sort_bywavelength,sort_bygratpos=sort_bygratpos,$
	add_doppcorr=add_doppcorr,add_distcorr=add_distcorr,add_darkcorr=add_darkcorr
	if n_elements(add_darkcorr) ne 1 then add_darkcorr=0
	if n_elements(add_distcorr) ne 1 then add_distcorr=0
	if n_elements(add_doppcorr) ne 1 then add_doppcorr=0
	if n_elements(do_plot) ne 1 then do_plot=0
	if n_elements(dark) ne 1 then dark=0
	if n_elements(Edge_Trim) ne 1 then Edge_Trim=2
	if n_elements(sort_bywavelength) ne 1 then sort_bywavelength=0
	if n_elements(sort_bygratpos) ne 1 then sort_bygratpos=0
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(debug) ne 1 then debug=1
	if n_elements(time_in_sec) ne 1 then time_in_sec=0
	;
	RCS_ID="$Id: get_telem.pro,v 1.5 2018/04/24 16:46:22 penton Exp penton $"
	;
	; Define Constants
	;
	FF='(F10.3)'
	; Define time constants
	time0_ms=get_time0_ms()
	time0_s=time0_ms/1000.0
	start_time=times[0]
	end_time=times[1]
	;
	; Read in the full telemetry stream
	;
	telem=get_instrumentTelemetry()
	;
	if verbose or debug then help,telem,/str
	;
	; sort by time, just to be sure
	;
	index=sort(telem.time_s)
		stimes_s	=telem.time_s[index]
		stimes_ms	=telem.time_ms[index]
		sgratpos	=telem.gratpos[index]
		scounts		=telem.counts[index]
		stemps		=telem.temps[index]
	;
	; trim to time window
	;
	index=where((stimes_ms ge start_time) and (stimes_ms le end_time),ct)
		stimes_s	=stimes_s[index]
		stimes_ms	=stimes_ms[index]
		sgratpos	=sgratpos[index]
		scounts		=scounts[index]
		stemps		=stemps[index]
	;
	; if the grating position is valid, get the wavelength and binsize
	;
	med_dwave=(dw=-1)
	irr=(dirr=(dwaves=(gwaves=(delta_waves=replicate(!values.f_nan,ct)))))
	index=where((sgratpos gt 0.0),good_gratpos)
	if good_gratpos ge 1 then begin
		gtimes_ms=stimes_ms[index]
		gtimes_s=stimes_s[index]
		ggratpos=sgratpos[index]
		gcounts=scounts[index]
		gtemps=stemps[index]
		gratderiv=deriv(ggratpos)
		;
		; lets keep it simple, just focus on the main scan
		; (trim the backlash, if that is what it is)
		mgd=median(gratderiv)
		index=(mgd gt 0 ? where(gratderiv gt 0,ct) : where(gratderiv lt 0,ct))
		if ct ge 1 then begin
			gtimes_ms=gtimes_ms[index]
			gtimes_s=gtimes_s[index]
			ggratpos=ggratpos[index]
			gcounts=gcounts[index]
			gtemps=gtemps[index]
			gratderiv=gratderiv[index]
		endif
		if sort_bygratpos then begin
			;
			; sort by sgratpos, if requested
			;
			index=sort(ggratpos)
				gtimes_ms=gtimes_ms[index]
				gtimes_s=gtimes_s[index]
				ggratpos=ggratpos[index]
				gcounts=gcounts[index]
				gtemps=gtemps[index]
		endif

		gwaves=gp_to_wave(ggratpos)
		;
		; Ok, one last sort by wavelength, if requested
		;
		if sort_bywavelength then begin
			index=sort(gwaves)
				gwaves=gwaves[index]
				gtimes_ms=gtimes_ms[index]
				gtimes_s=gtimes_s[index]
				ggratpos=ggratpos[index]
				gcounts=gcounts[index]
				gtemps=gtemps[index]
		endif
		;
		; Get the Dispersion, which seems to be changing
		;
		; use (abs(left)+abs(right))/2 to get binsize
		;
		delta_waves=(abs(gwaves-shift(gwaves,-1))+abs(gwaves-shift(gwaves,1)))/2.0
		;
		; fix the edges, this probably doesn't work on the Quickscan
		;
		delta_waves[0:1]=delta_waves[2]
		delta_waves[-2:-1]=delta_waves[-3]
		;
		; Trim the edges
		;
		if Edge_Trim ge 1 then begin
			if verbose then message,/info,'Trimming Ends by '+string1i(Edge_Trim)
			gtimes_s =gtimes_s[Edge_Trim:(-Edge_Trim)]
			gtimes_ms=gtimes_ms[Edge_Trim:(-Edge_Trim)]
			ggratpos=ggratpos[Edge_Trim:(-Edge_Trim)]
			gcounts=gcounts[Edge_Trim:(-Edge_Trim)]
			gtemps=gtemps[Edge_Trim:(-Edge_Trim)]
			gwaves=gwaves[Edge_Trim:(-Edge_Trim)]
			delta_waves=delta_waves[Edge_Trim:(-Edge_Trim)]
		endif
		med_dwave=median(abs(delta_waves))
	endif else begin
		gtimes_ms=stimes_ms
		gtimes_s=stimes_s
		ggratpos=sgratpos
		gcounts=scounts
		gtemps=stemps
		med_dwave=!values.f_nan
	endelse
	;
	inttime_s=get_inttime(gtimes_ms,/in_sec)
	;
	; Make sure that no bogus binsizes crept in
	;
	index=where(delta_waves le 0.0,ct)
	if ct ge 1 then delta_waves[index]=!values.f_nan
	;
	if dark ne 1 then begin
		if verbose then message,/info,'Dwave = '+string1f(med_dwave,format=FF)+' nm'

		dwaves=doppcorr(gwaves,gtimes_ms,time_in_s=0,wave_in_m=0,dw=dw)
		waves=(add_doppcorr ? dwaves : gwaves)

		dcounts=distcorr(gcounts,gtimes_ms,time_in_s=0,dr=dr)
		counts=(add_distcorr ? dcounts : gcounts)

		bkgcounts=darkcorr(counts,inttime_s,gtemps,time_in_s=1,bkg=bkg)
		counts=(add_darkcorr ? bkgcounts : counts)
		;
		; Add distance and doppler corrections, if requested
		;
		irr=counts_to_irr(gtimes_ms,waves,counts,delta_waves,/time_in_ms,/wave_in_nm)

	endif else begin
		dr=-1
		bkgcounts=0
		bkg=0
		dcounts=gcounts
		counts=gcounts
		dwaves=gwaves
		waves=gwaves
		if verbose then message,/info,'Dark exposure, skipping counts_to_irr'
	endelse

	out={start_time:start_time,end_time:end_time,$
		times_ms:gtimes_ms,times_s:gtimes_s,$
		time_ms0:gtimes_ms[0],time_s0:gtimes_s[0],$
		temps:gtemps,$
		ggratpos:ggratpos,gwaves:gwaves,gcounts:gcounts,$
		irr:irr,$
		waves:waves,counts:counts,$
		delta_waves:delta_waves,binsize:med_dwave,$
		doppcorr:add_doppcorr,dwaves:dwaves,dw:dw,$
		distcorr:add_distcorr,dcounts:dcounts,dr:dr,$
		darkcorr:add_darkcorr,bkgcounts:bkgcounts,bkg:bkg,$
		inttime_s:inttime_s,$
		edge_trim:edge_trim}
	if debug then begin
		help,out,/str
	endif
	return,out
end
