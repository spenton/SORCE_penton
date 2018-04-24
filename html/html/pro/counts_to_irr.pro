; docformat = 'rst'

;+
;	NAME: COUNTS_TO_IRR
;
;	PURPOSE: Given an array of times, wavelengths, counts, and binsizes, convert from
;            counts to irradiance.
;
;	USAGE:  IRR=counts_to_irr(times,waves,in_counts,binsize,[time_in_ms=time_in_ms],[wave_in_nm=wave_in_nm],$
;	[debug=debug][,verbose=verbose])
;
;	OPTIONAL PARAMETERS:
;
;  VERBOSE   :  Set if reporting of details is desired
;  DEBUG     :  Set to report additional information useful in debugging.
;	OUTPUT:
;		Irradiance Array, whose size matches the input waves, in_counts, and binsize
;
;-
function counts_to_irr,times,waves,in_counts,binsize,time_in_ms=time_in_ms,wave_in_nm=wave_in_nm,$
	debug=debug,verbose=verbose
	if n_elements(verbose) ne 1 then verbose=1
	if n_elements(debug) ne 1 then debug=0
	if n_elements(wave_in_nm) ne 1 then wave_in_nm=1
	if n_elements(time_in_ms) ne 1 then time_in_ms=1
	if debug or verbose then help,times,waves,counts,binsize
	;
	; times is the observational time (in ms),
	; get_wattsperm2 will use the times to interpolate into the telemetry to get the actual integration time
	; Note that irradiance is in units of Watts/m^2
	;
	; Counts come in as per bin (nm) bin for the integration time (s).
	; Convert to counts = (in_counts/exptime)/binsize
	;					= (counts/bin for exptime)
	;	bin_to_nm = bin
	;
	; counts*exptime/binsize=[counts*exptime/nm] / exptime(s) * binsize (nm)
	;
	counts_nm=double(in_counts)  ; / binsize
	;
	; get_wattsperm2 handles the exptime part
	;
	; irr   =get_wattsperm2(times,waves,in_counts,binsize,time_in_ms=time_in_ms,verbose=verbose)
	irr_nm=get_wattsperm2(times,waves,counts_nm,binsize,time_in_ms=time_in_ms,verbose=verbose)
	return,irr_nm
end
