function v_to_wave,v,just_cz=just_cz,rest=rest,double=double
	if n_elements(double) ne 1 then double=0
	if n_elements(just_cz) eq 0 then just_cz=get_cz() ; relativistic or not ?
	if n_elements(rest) eq 0 then rest=get_lya()
	if total(finite(v)) ne n_elements(v) then begin
		index=where(finite(v) ne 1,ct)
		message,'Invalid Velocity! -> '+string1f(v[index],format='(F10.3)')
	endif
	z=v_to_z(double(v),just_cz=just_cz)
	dwave=rest*double(1.0+z)
	return,(double ? dwave : float(dwave))
end
