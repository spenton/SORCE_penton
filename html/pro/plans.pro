; docformat = 'rst'

;+
;	NAME: PLANS
;
;	PURPOSE: Sandbox to test analysis code and results
;
;***** Background:
;This data is similar to what the SORCE SOLSTICE instrument has available (though
;it is a small subset of the wavelength range). This specific data set is a
;simulation around the Si 2 emission lines (~180nm).
;
;SOLSTICE collects data by looking at the sun. Light enters the aperture, follows
;the optical path which includes a grating, then lands on a photomultiplier tube
;(pmt) which counts the number of photon events. The position of the grating can
;be changed, which changes the wavelength of light hitting the pmt, which allows
;for the measurement of the solar spectrum.
;
;The SORCE spacecraft is in an orbit with roughly a ninety minute period.
;Unfortunately the spacecraft batteries are going bad. It cannot maintain the
;power required to keep the instrument at it's ideal temperature (22 deg C) and
;so the heaters are turned off during eclipse. This has created significant
;temperature swings. Another unfortunate side effect is that the grating position
;is reset with each orbit and it never returns to the exact fiducial. This
;creates a small grating offset from orbit to orbit which effects the actual
;grating position from what is being reported.
;
;From orbit to orbit, the spacecraft will execute different experiments, to
;measure different effects. The included data covers about five orbits worth of
;data, with different experiments on each orbit.
;
;Over this time period, it is reasonable to assume the solar variability for this
;wavelength range is not measureable by this detector.
;
;***** Task: Please calculate the irradiance in watts/m^2 and compare the scan
;data. Provide plots of your results along with your code. Specifically, plot the
;region around the two emission lines at ~180nm. Also, calculate the ratio of
;each scan wrt the reference spectrum and plot the results. What are your
;thoughts? Use any language you are comfortable with.
;
; From plans.txt: planName, startTime, endTime
;
; Orbit 1 =	QuickScan, 9.434017775100002E14, 9.434062192200002E14
; Orbit 2 =	ConstantWavelength, 9.434076142300002E14, 9.434120464800002E14
; Orbit 3 =	DownScan, 9.434134508500002E14, 9.434178736700002E14
; Orbit 4 =	Dark, 9.434192873600002E14, 9.434237008000002E14
; Orbit 5 =	UpScan, 9.434251237500002E14, 9.434295278700002E14
;
; 1) Why is there a "down spectrum" during the CW portion ?
;	Blake reports this scan is fine to use
;
;***** Equations
;
; * Wavelength (the grating equation) :
;    offset = 239532.38
;    stepSize = 2.4237772022101214E-6 [rad]
;    d = 277.77777777777777 [nm]
;    phiGInRads = 0.08503244115716374 [rad]
;    ang1 = (offset - gratingPosition) * stepSize
;    wavelength = 2 * d * sin(ang1) * cos(phiGInRads / 2.0) [nm]
;
; * counts/second/area :
;    integrationTime -> convert to seconds from ms
;    cr = counts / integrationTime [counts / sec / nm] (the per nm is from the sampling at the specific grating position)
;    apArea = .01 [cm^2] (aperture area)
;    photonspersecPerCm2 = cr / apArea [photons/sec/cm^2/nm]
;
; * watts/meter^2
;    wavelengthInMeters -> convert to meters from nm
;    h = 6.62606957E-34 [J*s]
;    c = 299792458.0 [m/s]
;    energyPerPhoton = h * c / wavelengthInMeters [J]
;    wattsPerM2 = photonspersecPerArea * 1e2 * 1e2 * energyPerPhoton [watts/m^2/nm]
;
;***** Files
;All files are comma separated with a one line header.
;
;  * detectorTemp.txt : in degrees Celsius. It is roughly sampled at 1 second.
;  * distanceAndDoppler.txt : These are the corrections used to adjust for the changing
;    distance and velocity of the spacecraft relative to the sun.
;  * instrumentTelemetry.txt : Includes grating position and measured detector counts. It is sampled
;    proportional to the current integration time. (keep in mind that this is measured counts which
;    which could be dependent on other variables)
;  * integrationTime.txt : This is the current set integration time (ms) of the instrument.
;    Assume the value is constant until there is a new value.
;  * plans.txt : This file includes the experiment names with start/end times. You can find the
;    time ranges of the plans of interest her. [start, end)
;  * referenceSpectrum.txt : This is a reference spectrum with accurate wavelengths. The current
;    irradiance measurements will be within 15% of this spectrum.
;
; w = 182nm = 1.85E-7m
;
; Plan:
;  Read in the intrumentTelementry for a given time range and return the graPos & counts



pro plans,plot_counts=plot_counts,plot_gratpos=plot_gratpos,plot_waves=plot_waves,plot_irr,$
	op=op,verbose=verbose,plot_temps=plot_temps,make_final=make_final,plot_all=plot_all
	if n_elements(plot_all) ne 1 then plot_all=0
	if n_elements(make_final) ne 1 then make_final=1
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(op) ne 1 then op=1
	if n_elements(plot_counts) ne 1 then plot_counts=0
	if n_elements(plot_gratpos) ne 1 then plot_gratpos=0
	if n_elements(plot_waves) ne 1 then plot_waves=0
	if n_elements(plot_irr) ne 1 then plot_irr=1
	if n_elements(plot_temps) ne 1 then plot_temps=0

	pngdir=get_laspdir(/png)
	up_color=get_up_color()
	dn_color=get_dn_color()
	rf_color=get_ref_color()
	;planName, startTime, endTime
	names=['QuickScan','ConstantWavelength','DownScan','Dark','UpScan']
	QuickScan=[9.434017775100002E14, 9.434062192200002E14]
	ConstantWavelength=[9.434076142300002E14, 9.434120464800002E14] ; 9.4340988e+14
	DownScan=[9.434134508500002E14, 9.434178736700002E14]
	Dark=[9.434192873600002E14, 9.434237008000002E14]
	UpScan=[9.434251237500002E14, 9.434295278700002E14]
	;
	; For each plan, get the basic telemetry
	;
	message,/info,'************ '+names[0]
	QS_telem=get_telem(QuickScan)
	message,/info,'************ '+names[1]
	CW_telem=get_telem(ConstantWavelength)
	message,/info,'************ '+names[2]
	DS_telem=get_telem(DownScan)
	message,/info,'************ '+names[3]
	DK_telem=get_telem(Dark,/dark)
	message,/info,'************ '+names[4]
	US_telem=get_telem(UpScan)
	;
	; plot them to see what we have
	;
	close_gwin
	if plot_counts or plot_all then begin
		pQS=plot(QS_telem.times_s,QS_telem.counts,xtitle='Time (s)',ytitle='Counts',name='Quick Scan',font_size=12,font_name='Times')
		pCW=plot(CW_telem.times_s,CW_telem.counts,xtitle='Time (s)',ytitle='Counts',name='Constant Wavelength',/overplot)
		pDS=plot(DS_telem.times_s,DS_telem.counts,xtitle='Times (s)',ytitle='Counts',name='Down Scan',/overplot,color=dn_color)
		pDK=plot(DK_telem.times_s,DK_telem.counts,xtitle='Times (s)',ytitle='Counts',name='Dark',/overplot)
		pUS=plot(US_telem.times_s,US_telem.counts,xtitle='Times (s)',ytitle='Counts',name='Up Scan',/overplot,color=up_color)
		l=legend(/auto_text_color,shadow=0,linestyle=6,font_name='Times')
		pQS.save,pngdir+'plot_counts.png'
	endif
	if plot_gratpos or plot_all then begin
		gQS=plot(QS_telem.times_s,QS_telem.ggratpos,xtitle='Times (s)',ytitle='Grating Position',name='Quick Scan',font_size=12,font_name='Times')
		gCW=plot(CW_telem.times_s,CW_telem.ggratpos,xtitle='Times (s)',ytitle='Grating Position',name='Constant Wavelength',/overplot)
		gDS=plot(DS_telem.times_s,DS_telem.ggratpos,xtitle='Times (s)',ytitle='Grating Position',name='Down Scan',/overplot,color=dn_color)
		;gDK=plot(DK_telem.times_s,DK_telem.ggratpos,xtitle='Times (s)',ytitle='Grating Position',name='Dark',/overplot)
		gUS=plot(US_telem.times_s,US_telem.ggratpos,xtitle='Times (s)',ytitle='Grating Position',name='Up Scan',/overplot,color=up_color)
		l=legend(/auto_text_color,shadow=0,linestyle=6,font_name='Times')
		gQS.save,pngdir+'plot_gratpos.png'
	endif

	refspec=get_refspec(/do_plot)

	if plot_waves or plot_all then begin
		wQS=plot(QS_telem.waves,QS_telem.counts,xtitle='Wavelength (nm)',ytitle='Counts',name='Quick Scan',font_size=12,font_name='Times',$
			xrange=[174,190],color='HOT PINK')
		wCW=plot(CW_telem.waves,CW_telem.counts,xtitle='Wavelength (nm)',ytitle='Counts',name='Constant Wavelength',/overplot,color='RED')
		wDS=plot(DS_telem.waves,DS_telem.counts,xtitle='Wavelength (nm)',ytitle='Counts',name='Down Scan',/overplot,color=up_color)
		;wDK=plot(DK_telem.waves,DK_telem.counts,xtitle='Wavelength (nm)',ytitle='Counts',name='Dark',/overplot,color='BLACK')
		wUS=plot(US_telem.waves,US_telem.counts,xtitle='Wavelength (nm)',ytitle='Counts',name='Up Scan',/overplot,color=dn_color)
		l=legend(/auto_text_color,shadow=0,linestyle=6,font_name='Times')
		wQS.save,pngdir+'plot_waves.png'
	endif
	if plot_temps or plot_all then begin
		tQS=plot(QS_telem.times_s,QS_telem.Temps,xtitle='Time (s)',ytitle='Temp',name='Quick Scan',font_size=12,font_name='Times',$
			xrange=[174,190],color='HOT PINK')
		tCW=plot(CW_telem.times_s,CW_telem.Temps,xtitle='Time (s)',ytitle='Temp',name='Constant Wavelength',/overplot,color='RED')
		tDS=plot(DS_telem.times_s,DS_telem.Temps,xtitle='Time (s)',ytitle='Temp',name='Down Scan',/overplot,color=dn_color)
		tDK=plot(DK_telem.times_s,DK_telem.Temps,xtitle='Time (s)',ytitle='Temp',name='Dark',/overplot,color='BLACK')
		tUS=plot(US_telem.times_s,US_telem.Temps,xtitle='Time (s)',ytitle='Temp',name='Up Scan',/overplot,color=up_color)
		l=legend(/auto_text_color,shadow=0,linestyle=6,font_name='Times')
		tQS.save,pngdir+'plot_temps.png'
	endif
	;
	; Convert counts to irradiance
	;
	if plot_irr or plot_all then begin
		wQS=plot(QS_telem.waves,QS_telem.irr,xtitle='Wavelength (nm)',ytitle='Irradiance',name='Quick Scan',font_size=12,font_name='Times',$
			xrange=[174,190],color='HOT PINK')
		wQS.title='Orbit 1 : QuickScan'
		wDS=plot(DS_telem.waves,DS_telem.irr,xtitle='Wavelength (nm)',ytitle='Irradiance',name='Down Scan',overplot=op,color=dn_color)
		;wDK=plot(DK_telem.waves,DK_telem.irr,xtitle='Wavelength (nm)',ytitle='Irradiance',name='Dark',overplot=op,color='BLACK')
		wUS=plot(US_telem.waves,US_telem.irr,xtitle='Wavelength (nm)',ytitle='Irradiance',name='Up Scan',overplot=op,color=up_color)
		l=legend(/auto_text_color,shadow=0,linestyle=6,font_name='Times')
			wQS.save,pngdir+'wQS.png'
		wb=get_waveband()
		wQS.xrange=wb
		wQS.save,pngdir+'wQS_zoom.png'
		wCW=plot(CW_telem.waves,CW_telem.irr,xtitle='Wavelength (nm)',ytitle='Irradiance',name='Constant Wavelength',title='Constant Wavelength',color='RED')
		wCW.title='Orbit 2 : Constant Wavelength'
		wCW.save,pngdir+'wCW.png'
		wCW.xrange=wb
		wCW.save,pngdir+'wCW_zoom.png'

		wDS=plot(DS_telem.waves,DS_telem.irr,xtitle='Wavelength (nm)',ytitle='Irradiance',name='Constant Wavelength',title='Constant Wavelength',color='RED')
		wDS.title='Orbit 3 : Down Scan'
		wDS.save,pngdir+'wDS.png'
		wDS.xrange=wb
		wDS.save,pngdir+'wDS_zoom.png'

		;wDK=plot(DK_telem.waves,DK_telem.irr,xtitle='Wavelength (nm)',ytitle='Irradiance',name='Constant Wavelength',title='Constant Wavelength',color='RED')
		;w.DK.title='Orbit 4 : Dark'
		;wDK.save,pngdir+'wDK.png'
		;wDK.xrange=wb
		;wDK.save,pngdir+'wDK_zoom.png'

		wUS=plot(US_telem.waves,US_telem.irr,xtitle='Wavelength (nm)',ytitle='Irradiance',name='Constant Wavelength',title='Constant Wavelength',color='RED')
		wUS.title='Orbit 5 : UpScan'
		wUS.save,pngdir+'wUS.png'
		wUS.xrange=wb
		wUS.save,pngdir+'wUS_zoom.png'

		wUPD=plot(DS_telem.waves,US_telem.irr-DS_telem.irr,xtitle='Wavelength (nm)',ytitle='$\Delta$ Irradiance',name='Up-Down',color='DARK BLUE')
		wUPD.save,pngdir+'wUPD.png'
		wUPD.xrange=wb
		wUPD.save,pngdir+'wUPD_zoom.png'

		wUPR=plot(DS_telem.waves,US_telem.irr-DS_telem.irr,xtitle='Wavelength (nm)',ytitle='$\Delta$ Irradiance',name='Reference-Up',color='DARK BLUE')
		wDNR=plot(DS_telem.waves,US_telem.irr-DS_telem.irr,name='Reference-Down',color=dn_color,/overplot)
		wUPR.save,pngdir+'wUPR.png'
		wUPR.xrange=wb
		wUPR.save,pngdir+'wUPR_zoom.png'
	endif

	if make_final or plot_all then begin
		wRF=plot(nm,irr,xtitle='Wavelength (nm)',ytitle='Irradiance',font_name='Times',font_size=14,color=rf_color,name='Reference Spectrum')
		wDS=plot(DS_telem.waves,DS_telem.irr,name='Down Scan',color=up_color,/overplot)
		wUS=plot(US_telem.waves,US_telem.irr,name='Up Scan',color=dn_color,/overplot)
		wRF.save,pngdir+'make_final.png'
	endif
	if debug then stop
end
