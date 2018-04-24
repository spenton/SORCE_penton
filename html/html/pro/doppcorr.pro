; docformat = 'rst'

;+
; NAME: DOPPCORR
;
; PURPOSE: Apply Doppler correction based upon provided factors
;		 : There is a big assumption here, that is that the
;		   DOPPFACTOR = (1.0+V/C)
;
; OPTIONAL INPUT PARAMETERS
;
;		VERBOSE :  Set if reporting of details is desired (default=0)
;		WAVE_IN_M : Set if input wavelengths are in meters (default=0).
;                   If not set, assume they are in nm
;		DEBUG     :  Set to report additional information useful in debugging.
;
; OPTIONAL OUTPUT PARAMETERS
;
;	DW 	The Doppler shifts are returned separately in this parameter
;
; OUTPUT
;
;	Doppler corrected wavelengths (in the passed in units) are returned.
;
;+
function doppcorr,wave,time,verbose=verbose,time_in_s=time_in_s,dw=dw,$
	wave_in_m=wave_in_m,debug=debug
	if n_elements(debug) ne 1 then debug=0
	if n_elements(time_in_s) ne 1 then time_in_s=0 ; default is ms
	if n_elements(wave_in_m) ne 1 then wave_in_m=0
	if n_elements(verbose) ne 1 then verbose=1
		FF='(F8.3)'
		dd=get_distdopp_bytime(time,time_in_s=time_in_s)
		; assume that doppfactor is (1.0+v/c)
		dv=dd.doppfactor-(1.0D) ; convert to v/c
		dw=wave*dv ; wave can be in any units
		if verbose then begin
			sunits=(wave_in_m ? ' m' : ' nm')
			if debug then help,wave,time,dv,dw
			message,/info,'Orbital period of 90 minutes suggests v ~ 8 km/s'
			message,/info,'Time in s = '+string1i(time_in_s)
			message,/info,'max(Dv) = '+string1f(max(dv)*get_c()/1000.,format=FF)+' km/s'
			message,/info,'max(Dw) = '+string1f(max(dw),format=FF)+sunits
			message,/info,'min(Dv) = '+string1f(min(dv)*get_c()/1000.,format=FF)+' km/s'
			message,/info,'min(Dw) = '+string1f(min(dw),format=FF)+sunits
		endif
		;
		; A positive velocity would be away from the Sun, so that's a redshift (+)
		; A negative velocity would be towards the Sun, so that's a blueshift (-)
		;
		; so dwave=wave+Dw
		; a 5km/s shift at 1800Å (180nm) is 0.03Å (0.003 nm)
		;
		return,wave+dw
end
