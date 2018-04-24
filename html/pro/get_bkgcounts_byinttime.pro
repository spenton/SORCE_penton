; docformat = 'rst'

;+
;	NAME: get_bkgcounts_byinttime
;
;	PURPOSE: Return temperature dependent background counts
;			Integration time is assumed to be in seconds, unless time_in_ms iset
;
;			A simple 3rd order polynomial is assumed for the background vs temp
;			relationship. This is stored in the dark_coeff.dat IDL save file that
;			is produced by eval_darkcorr.pro
;
;	OPTIONAL PARAMETERS:
;
;	TIME_IN_MS	Set this keyword to indicate that the integration time was passed in
;               in milli-seconds instead of seconds (default=0)
;-
function get_bkgcounts_byinttime,inttime,temp,time_in_ms=time_in_ms
	if n_elements(time_in_ms) ne 1 then time_in_ms=0

	inttime_in_s=(time_in_ms ? inttime*1000.0 : inttime)
	txtdir=get_laspdir(/txt)
	restore,txtdir+'dark_coeff.dat' ; counts/s background based upon temp
	bkg_cps=c[0]+c[1]*temp+c[2]*temp^2
	bkg=abs(bkg_cps*inttime_in_s) > 0
	return,bkg
end
