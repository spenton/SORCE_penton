; docformat = 'rst'

;+
;	NAME:  get_inttimes
;
;  USAGE: out=get_inttimes([,VERBOSE=verbose] [,DEBUG=DEBUG])
;
; INPUT PARAMETERS:
;
;   TIME_IN_SEC : Set to return the integratian timein seconds instead of milli-seconds (default=0)
;   VERBOSE   :  Set if reporting of details is desired
;   DEBUG     :  Set to report additional information useful in debugging.
;
; OUTPUT PARAMETERS:
;
;  Integration time (in milli-seconds, unless /TIME_IN_SEC is set )
;-
function get_inttimes,verbose=verbose,debug=debug
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(debug) ne 1 then debug=0
	RCS_ID="$Id: get_inttimes.pro,v 1.2 2018/04/24 05:46:15 penton Exp $"
	tdir=get_laspdir(/txt)
	file='integrationTime.txt'
	readcol,tdir+file,time_ms,intTime,format='(D,F)',SKIPLINE=1,/NAN,delimiter=','
	inttime_sec=intTime/1000.
	out={time_s:time_ms/1000.0,time_ms:time_ms, intTime:intTime,intTime_sec:intTime_sec}
	return,out
end
