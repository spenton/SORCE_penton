;+
;	NAME: get_wattsperm2
;
;	PURPOSE: Convert from counts to Watts/m^2
;
;	USAGE: out=get_wattsperm2(times,waves,counts,binsize)
;
;	OPTIONAL_PARAMETERS:
;
;		TIME_IN_MS : Set if time is in ms (default=1)
;		WAVE_IN_NM : Set if wavelengths are in nm (default=1)
;		VERBOSE   :  Set if reporting of details is desired
;		DEBUG     :  Set to report additional information useful in debugging.
;
;
;    wavelengthInMeters -> convert to meters from nm
;    h = 6.62606957E-34 [J*s]
;    c = 299792458.0 [m/s]
;    energyPerPhoton = h * c / wavelengthInMeters [J]
;    wattsPerM2 = photonsPerSecondPerArea * 1e2 * 1e2 * energyPerPhoton [watts/m^2/nm]
;
;-
function get_wattsperm2,times,waves,counts,binsize,time_in_ms=time_in_ms,wave_in_nm=wave_in_nm,$
	verbose=verbose,debug=debug,area=area
	if n_elements(debug) ne 1 then debug=0
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(wave_in_nm) ne 1 then wave_in_nm=1
	if n_elements(time_in_ms) ne 1 then time_in_ms=1
	if n_elements(area) ne 1 then area=get_corr_area() ; cm^2
	if verbose then help,binsize
	photonspersecpercm2pernm = get_ph_per_s_cm2_nm(times,counts,binsize,area=area)
	energyperphoton=get_energyperphoton(waves,wave_in_nm=wave_in_nm)
	wattsperm2 = photonspersecpercm2pernm * double(1e2) * double(1e2) * energyperphoton;[watts/m^2]
	if debug then forprint,times,waves,energyperphoton,wattsperm2,photonspersecpercm2pernm,binsize
	return,wattsperm2
end

