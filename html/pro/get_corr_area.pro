; docformat = 'rst'

;+
;	NAME: get_corr_area
;
;	USAGE: out=get_corr_area()
;
;-
function get_corr_area
;
;    apArea = .01 [cm^2] (aperture area)
;
	RCS_ID="$Id: get_corr_area.pro,v 1.3 2018/04/24 16:46:22 penton Exp $"
	area0=double(0.01)
	return,area0
end
