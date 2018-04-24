function test_counts_to_irr,epochtime=epochtime,debug=debug,verbose=verbose
	if n_elements(verbose) ne 1 then verbose=1
	if n_elements(debug) ne 1 then debug=0
	if n_elements(epochtime) ne 1 then epochtime=avg([9.434251237500002E14, 9.434295278700002E14])
		counts=[10.,100.,1000]
		exptime=get_inttime(epochtime,/in_sec)
		times=[1,10,100] ; seconds
		waves=[185,185.5,186.1] ; nm
		binsize=[0.5,0.5,0.6] ; nm
		;
		; irradiance is in units of Watts/m^2
		; where 1 watt = 1 J/s = km/m/s^3
		;
		epp=get_energyperphoton(waves,/wave_in_nm) ; Joules
		area=.01 ;[cm^2] (aperature area)
		aream=area/double(100.*100)
		irr=(epp/exptime)/aream
		if verbose then help,epp,epochtime,exptime,area,irr,times,waves,counts,binsize
		irrt=counts_to_irr(times,waves,counts,binsize,time_in_ms=0,wave_in_nm=1,/verbose,/do_plot)
		forprint,irr,irrt
		success=abs(irr-irrt) le 0.1
		message,/info,(success eq 1 ? 'SUCCESS' : 'FAILED')
	return,success
end
