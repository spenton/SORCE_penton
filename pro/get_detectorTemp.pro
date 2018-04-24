; docformat = 'rst'

;+
;  NAME: get_detectorTemp
;
;  USAGE: out=get_detectorTemp([,VERBOSE=verbose],[DEBUG=DEBUG])
;
; INPUT PARAMETERS:
;
;  VERBOSE   :  Set if reporting of details is desired
;  DEBUG     :  Set to report additional information useful in debugging.
;
; OUTPUT PARAMETERS:
;     Structure of data products:
;
;-
function get_detectorTemp,verbose=verbose,debug=debug
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(debug) ne 1 then debug=0
	RCS_ID="$Id: get_detectorTemp.pro,v 1.4 2018/04/24 16:46:22 penton Exp $"
	tdir=get_laspdir(/txt)
	file='detectorTemp.txt'
	if verbose then message,/info,'Reading Detector Temperatures from '+tdir+file
	readcol,tdir+file,time_ms,detTemp,format='(D,F)',SKIPLINE=1,/NAN,delimiter=',',silent=(verbose ? 0 : 1)
	dTemp={time_s:time_ms/(1000.),time_ms:time_ms,detTemp:detTemp}
	return,dTemp
end
