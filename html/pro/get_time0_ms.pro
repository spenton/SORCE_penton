; docformat = 'rst'

;+
; FUNCTION get_time0_ms
;
; PURPOSE: To avoid precision issues, all times are from time0
;
; USAGE: time0_ms=get_time0_ms()
;-
function get_time0_ms
	time0_ms=double(9.4340162100E+14)
	return,time0_ms
end
