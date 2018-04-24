; docformat = 'rst'

;+
;	NAME: get_detTemp_bytime,time_ms,use_interpol=use_interpol,verbose=verbose,debug=debug
;
;	PURPOSE:
;
;	USAGE: out=get_detTemp_bytime(time_ms,[USE_interpol=use_interpol][,VERBOSE=verbose] [,DEBUG=DEBUG])
;
; INPUT PARAMETERS:
;
;   TIME_MS   : Scalar or Vector of times (in milliseconds)
;   USE_INTERPOL : Set to use the IDL Interpol function instead of linterp (default=TRUE)
;   VERBOSE   :  Set if reporting of details is desired
;   DEBUG     :  Set to report additional information useful in debugging.
;
; OUTPUT PARAMETERS:
;     Array of temperatures, to match the input time or time_array
;
;-
function get_detTemp_bytime,time_ms,use_interpol=use_interpol,verbose=verbose,debug=debug
	if n_elements(debug) ne 1 then debug=0
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(use_interpol) ne 1 then use_interpol=1
	RCS_ID="$Id: get_detTemp_bytime.pro,v 1.2 2018/04/24 05:46:15 penton Exp $"
	detTemp=get_detectorTemp(verbose=verbose,debug=debug)
	if verbose then help,detTemp,/str
	dtime_ms=double(time_ms)
	; check this, interpolate may be better
	linterp,detTemp.time_ms,detTemp.detTemp,dtime_ms,temp_out
	Temp_outi=interpol(detTemp.detTemp,detTemp.time_ms,dtime_ms)
	if  debug then help,Temp_out,Temp_outi,use_interpol
	return,(use_interpol ? Temp_outi : Temp_out)
end
