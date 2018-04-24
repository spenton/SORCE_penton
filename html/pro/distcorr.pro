; docformat = 'rst'

;+
; NAME: DISTCORR
;
; PURPOSE: Apply DISTANCE correction based upon provided factors
;		 : There is a big assumption here, that is that the
;		   DISTFACTOR = R/R0 ; where R0=1AU
;          The correction based up a 1/R^2 assumption, or
;          Corrected Flux = Input Flux * 1.0/(DISTFACTOR)^2
;
; OPTIONAL INPUT PARAMETERS
;
;		VERBOSE :  Set if reporting of details is desired (default=0)
;		TIME_IN_S: Set if the time is in seconds instead of ms
;		DEBUG     :  Set to report additional information useful in debugging.
;
; OPTIONAL OUTPUT PARAMETERS
;
;	DR 	The DISTANCE shifts are returned separately in this parameter
;
; OUTPUT
;
;	DISTANCE corrected flux (in the passed in units, which could be counts) are returned.
;
;+
function distcorr,flux,time,verbose=verbose,time_in_s=time_in_s,dr=dr,debug=debug
	if n_elements(debug) ne 1 then debug=0
	if n_elements(time_in_s) ne 1 then time_in_s=0 ; default is ms
	if n_elements(verbose) ne 1 then verbose=1
		FF='(F8.3)'
		dd=get_distdopp_bytime(time,time_in_s=time_in_s)
		; assume that distfactor is (R/R0)
		dr=(dd.distfactor)^(-2) ; convert to 1/R^2
		if verbose then begin
			if debug then help,flux,time,distfactor,dv,dw
			message,/info,'max(dr) = '+string1f(max(dr),format=FF)
			message,/info,'min(dr) = '+string1f(min(dr),format=FF)
		endif
		return,flux*dr
end
