;+
;  NAME: raw_counts_to_cps
;
; PURPOSE: Used in COUNTS_TO_IRR to convert from counts to irradiance. This
;          routine determines the integration time and binsize and adjusts the
;          counts array appropriately.
;
; USAGE: out=raw_counts_to_cps(raw_counts,time,binsize)
;
; OPTIONAL INPUT KEYWORDS:
;
;   VERBOSE   :  Set if reporting of details is desired
;-
function raw_counts_to_cps,raw_counts,time,binsize,verbose=verbose
	if n_elements(verbose) ne 1 then verbose=0
	;
	; Counts come in as per bin (nm) bin for the integration time (s).
	; Convert to counts = (in_counts/exptime)/binsize
	;					= (counts/bin for exptime)
	;	bin_to_nm = bin
	;
	; counts*exptime/binsize=[counts*exptime/nm] / exptime(s) * binsize (nm)
	;
	dt=get_inttime(time,/in_sec) ; return time in seconds
	message,/info,'DT='+string1f(dt[0])+' seconds.'
	cr=double(raw_counts)/double(dt) ; this is now in count/s in a bin convert to cps per nm
	if verbose then help,binsize
	; This is commented out, but it just doesn't feel right, but
	; it gets it close to the scale of the reference spectrum
	;
	cps=cr ;* binsize ; this is now counts/s/nm
	return,cps
end
