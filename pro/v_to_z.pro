function v_to_z,v,just_cz=just_cz,double=double
if n_elements(double) ne 1 then double=0
if n_elements(just_cz) ne 1 then just_cz=get_cz() ; relativistic or not ?
on_error,2 ;Return to caller
if N_params() ne 1 or n_elements(v) eq 0 then $
	message,'Syntax -> z=v_to_z(V,just_cz=just_cz,double=double)
	;
	c=get_c()
	dv=double(v)
	dvc=double(dv/c)
	if just_cz then return,(double ? dvc : dvc)
	one=double(1.0)
	z12=(one+dvc)/(one-dvc)
	z=sqrt(z12)-one
	return,(double ? z : float(z))
	;
end
