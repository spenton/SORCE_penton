;+
;  FUNCTION: get_ph_per_s_cm2_nm
;-
function get_ph_per_s_cm2_nm,time,raw_counts,binsize,area=area,verbose=verbose
; * counts/second/area :
;    integrationTime -> convert to seconds from ms
;    cr = counts / integrationTime [counts / sec / nm] (the per nm is from the sampling at the specific grating position)
;    apArea = .01 [cm^2] (aperature area)
;    photonspersecPerCm2PerNm = cr / apArea [photons/sec/cm^2/nm]
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(area) ne 1 then area=get_corr_area() ; cm^2
	if verbose then help,binsize
	cps=raw_counts_to_cps(raw_counts,time,binsize)
	photonspersecpercm2 = cps / area ; this is now counts/s/cm^2 in a 1nm bin
	; The flux equivalent is ergs/s/cm2/A, we just need to multiply by J/photon
	; to have Spectral irradiance in terms of, where J/s/cm^2/nm = W/cm^2/nm
	return,photonspersecpercm2
end
