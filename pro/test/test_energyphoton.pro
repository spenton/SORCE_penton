;+
;	Function test_energyphoton
;-
function test_energyphoton,verbose=verbose
	if n_elements(verbose) ne 1 then verbose=1
	epsilon=1E-23
	answer=(1.07375E-18)
	FE='(E10.4)'
	energy=get_energyperphoton(185.0,/wave_in_nm)
	pass1=(abs(energy-answer) le epsilon)
	spass1=(pass1 ? 'PASSED' : 'FAILED')
	message,/info,'Energy Test 1  '+string1f(energy,format=FE)+' J : '+spass1
	energym=get_energyperphoton(nm_to_m(185),wave_in_nm=0)
	pass2=(abs(energym-answer) le epsilon)
	spass2=(pass2 ? 'PASSED' : 'FAILED')
	message,/info,'Energy Test 2  '+string1f(energym,format=FE)+' J : '+spass2
	message,/info,'Answer should be '+string1f(answer,format=FE)+' J'
	success=(pass1 and pass2)
	message,/info,(success eq 1 ? 'SUCCESS' : 'FAILED')
	return,success
end
