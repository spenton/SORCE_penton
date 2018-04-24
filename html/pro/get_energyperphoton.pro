; docformat = 'rst'

;+
;	NAME: get_energyphoton
;
;	USAGE: Energy=get_energyphoton(wavelength [,WAVE_IN_NM=WAVE_IN_NM])
;
;	PURPOSE: Convert from wavelength to photon energy
;
; INPUT PARAMETERS:
;
;   WAVE_IN_NM : Set to if the input wavelength is in NM (default=1)
;   VERBOSE   :  Set if reporting of details is desired
;   DEBUG     :  Set to report additional information useful in debugging.
;
; OUTPUT PARAMETERS:
;
;	Photon energy in J
;-
function get_energyperphoton,wave,wave_in_nm=wave_in_nm,verbose=verbose,debug=debug
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(debug) ne 1 then debug=0
	if n_elements(wave_in_nm) ne 1 then wave_in_nm=1 ; otherwise, it's in meters
	RCS_ID="$Id: get_energyperphoton.pro,v 1.2 2018/04/24 05:46:15 penton Exp $"
	h=get_h()
	c=get_c()
	if debug then help,wave
	wave_m=double(wave_in_nm ? nm_to_m(wave) : wave )
	energyperphoton= h * c / wave_m ; m2*kg/s * m/s / m = m2*kg/s2 = J
	return,energyperphoton
end
