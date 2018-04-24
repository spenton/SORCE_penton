; docformat = 'rst'

;+
;	NAME: GP_TO_WAVE
;
;	USAGE: wave=gp_to_wave(gratingpos,[ANG1=ANG1],[,VERBOSE=verbose] [,DEBUG=DEBUG])
;
;	PURPOSE: Given a grating position, return the corresponding wavelength (in nm)
;
;	INPUT PARAMETERS:
;		GRATINGPOS = Input Grating Position
;
; 	OPTIONAL PARAMETERS:
;
;		ANG1: Return the ANG1 angle, if needed for other purposes
;		VERBOSE   :  Set if reporting of details is desired
;		DEBUG     :  Set to report additional information useful in debugging.
;
;-
function gp_to_wave,gratpos,ang1=ang1,verbose=verbose,debug=debug
	;
	; we need gratingPostion to get ang1
	; we need ang1 to get wavelength
	;
	offset = 239532.38D
	stepSize = 2.4237772022101214E-6
	d = 277.77777777777777D
	phiGInRads = 0.08503244115716374D
	ang1 = (offset - gratpos) * stepSize
	wave_in_nm = 2.0D * d * sin(ang1) * cos(phiGInRads / 2.0) ; angle is in radians, so this will mork[nm]
	return,wave_in_nm
end
