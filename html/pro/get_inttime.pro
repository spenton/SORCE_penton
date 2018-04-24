; docformat = 'rst'

;+
;	NAME: get_inttime
;
;	PURPOSE: Returns integration time based upon input elapsed time
;
;	USAGE: out=get_inttime(time[,in_sec=in_sec])
;
;	OPTIONAL INPUT PARAMETERS:
;
;	IN_SEC: Set if output intergration time should be in seconds (default=1)
;-
function get_inttime,time,in_sec=in_sec
	if n_elements(in_sec) ne 1 then in_sec=1
	inttimes=get_inttimes()
	linterp,inttimes.time_ms,(in_sec ? inttimes.intTime_sec:inttimes.intTime),time,iTime
	return,iTime
end
