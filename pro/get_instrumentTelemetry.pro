;+
;	FUNCTION get_instrumentTelemetry
;
;	PURPOSE: Read the raw telemetry and return as a structure
;
;	USAGE :     out=get_instrumentTelemetry( [,SORT_BYTIME=sort_bytime][,VERBOSE=verbose] [,DEBUG=DEBUG])
;
; INPUT PARAMETERS:
;
;   SORT_BYTIME : Set to sort the return structure in increasing time (default=1)
;   VERBOSE   :  Set if reporting of details is desired
;   DEBUG     :  Set to report additional information useful in debugging.
;
; OUTPUT PARAMETERS:
;     Sample Structure of telemetry products:
;
;   TIME_S          DOUBLE    Array[41892]
;   TIME_MS         DOUBLE    Array[41892]
;   TIME0_MS        DOUBLE       9.4340165e+14
;   TIME0_S         DOUBLE       9.4340165e+11
;   GRATPOS         FLOAT     Array[41892]
;   COUNTS          FLOAT     Array[41892]
;   TEMPS           FLOAT     Array[41892]
;
;-
function get_instrumentTelemetry,sort_bytime=sort_bytime,verbose=verbose,debug=debug
;
	if n_elements(sort_bytime) ne 1 then sort_bytime=1
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(debug) ne 1 then debug=0
	;
	RCS_ID="$Id: get_instrumentTelemetry.pro,v 1.2 2018/04/24 05:46:15 penton Exp $"
	;
	tdir=get_laspdir(/txt)
	time0_ms=get_time0_ms()
	time0_s=time0_ms/1000.0
	file='instrumentTelemetry.txt'
	if verbose then message,/info,'Reading telemetry from '+tdir+file
	readcol,tdir+file,time_ms,gratpos,counts,format='(D,F,F)',SKIPLINE=1,/NAN,delimiter=','
	if sort_bytime then begin
		index=sort(time_ms)
		times_ms=	time_ms[index]
		gratpos	=	gratpos[index]
		counts	=	counts[index]
	endif
	;
	; Determine the temperature for the given times
	;
	temps=get_detTemp_bytime(time_ms,verbose=verbose,debug=debug)
	;
	out={time_s:double(time_ms/1000.0),time_ms:double(time_ms),$
		time0_ms:time0_ms,time0_s:time0_s,$
		gratpos:gratpos,counts:counts,temps:temps}
	if debug then help,out,/str
	return,out
end
