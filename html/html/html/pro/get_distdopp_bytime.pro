;+
;	NAME: get_distdopp_bytime
;
;	PURPOSE: Return Distance and Doppler factors from provided resource
;
;	USAGE: 	dd=get_distdopp_bytime(time ,[USE_interpol=use_interpol][,TIME_IN_S=time_in_s][VERBOSE=VERBOSE])
;
;	OPTIONAL INPUT PARAMETERS:
;
;      TIME_IN_S : Set if input is in seconds, output time will also be in seconds. Default = 0,
;                   Indicating that input and output time are in milli-seconds.
;   USE_INTERPOL : Set to use the IDL Interpol function instead of linterp (default=TRUE)
;		 VERBOSE :  Set if reporting of details is desired (default=0)
;-
function get_distdopp_bytime,time,time_in_s=time_in_s,verbose=verbose,use_interpol=use_interpol,debug=debug
	if n_elements(debug) ne 1 then debug=0
	if n_elements(use_interpol) ne 1 then use_interpol=1
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(time_in_s) ne 1 then time_in_s=0
	RCS_ID="$Id: get_distdopp_bytime.pro,v 1.1 2018/04/24 14:49:13 penton Exp $"
	dd=get_distdopp(verbose=verbose)
	if verbose then help,dd,/str
	ltime=(time_in_s ? dd.time_s : dd.time_ms)
	; linterps
	linterp,ltime,dd.distfactor,time,distfactor_out
	linterp,ltime,dd.doppfactor,time,doppfactor_out
	; interpols
	idistfactor_out=interpol(dd.distfactor,ltime,time)
	idoppfactor_out=interpol(dd.doppfactor,ltime,time)

	if debug then begin
		help,distfactor_out,idistfactor_out,$
			doppfactor_out,idoppfactor,_out,use_interpol
	endif
	return,{time:time,time_in_s:time_in_s,use_interpol:use_interpol,$
			distfactor:(use_interpol ? idistfactor_out: distfactor_out),$
			doppfactor:(use_interpol ? idoppfactor_out: doppfactor_out)}
end
