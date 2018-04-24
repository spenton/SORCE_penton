; docformat = 'rst'

;+
;	NAME: nm_to_m
;
;	PURPOSE: Simple nm to meter conversion
;-
function nm_to_m,nm
	return,double(1.0E-9)*nm
end
