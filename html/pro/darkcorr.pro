; docformat = 'rst'

;+
; NAME: DARKCORR
;
; PURPOSE: Apply background correction based upon telemetry from Dark orbit
;
; OPTIONAL INPUT PARAMETERS
;
;	VERBOSE :  Set if reporting of details is desired (default=0)
;	DEBUG     :  Set to report additional information useful in debugging.
;	TIME_IN_SEC : Set if time is input in seconds (default=0)
;
; OPTIONAL OUTPUT PARAMETERS
;
;	BKG 	The Background counts subtracted for the input temp and time
;
; OUTPUT
;
;	Background Subtracted Counts are returned.
;
;+
function darkcorr,counts,inttime,temp,verbose=verbose,time_in_s=time_in_s,bkg=bkg,debug=debug
	if n_elements(debug) ne 1 then debug=0
	if n_elements(time_in_ms) ne 1 then time_in_ms=0 ; default is s
	if n_elements(verbose) ne 1 then verbose=0
		FF='(F8.3)'
		if debug then help,inttime,temp,counts
		bkg=get_bkgcounts_byinttime(inttime,temp,time_in_ms=time_in_ms)
		if verbose then begin
			sunits=(' Counts')
			if debug then help,inttime,counts,bkg
			message,/info,'Time in ms = '+string1i(time_in_ms)
			message,/info,'max(BKG) = '+string1f(max(bkg),format=FF)+sunits
			message,/info,'min(BKG) = '+string1f(min(bkg),format=FF)+sunits
		endif
		return,double(counts)-bkg
end
