;+
;	NAME: get_distdopp
;
;	PURPOSE: Return Distance and Doppler factors from provided resource
;
;	USAGE: 	dd=get_distdopp([VERBOSE=VERBOSE])
;
;	OPTIONAL INPUT PARAMETERS:
;
;		VERBOSE :  Set if reporting of details is desired (default=0)
;
;	OUTPUT:
;		A structure with the SunObserverDistanceCorrection and SunObserverDopplerCorrection factors
;	are returned with times in seconds and milli-seconds.  Shortened named variables of
;	distfactor and doppfactor are also included.
;
;-
function get_distdopp,verbose=verbose
	if n_elements(verbose) ne 1 then verbose=0
	RCS_ID="$Id: get_distdopp.pro,v 1.2 2018/04/24 14:49:13 penton Exp $"
	tdir=get_laspdir(/txt)
	file='distanceAndDoppler.txt'
	if verbose then message,/info,'Reading DOPP/DIST factors from '+tdir+file
	readcol,tdir+file,msSince,distance,dopp,format='(D,F,F)',SKIPLINE=1,/NAN,delimiter=','
	out={time_s:msSince/1000.0,time_ms:msSince, $
		distfactor:distance,sunObserverDistanceCorrection:distance,$
		doppfactor:dopp,sunObserverDopplerFactor:dopp}
	return,out
end
