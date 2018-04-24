; docformat = 'rst'

;+
;	NAME: make_plots
;
;	USAGE: make_plots,[add_allcorrs=add_allcorrs]
;
;	OPTIONAL INPUT PARAMETERS:
;
;	ADD_ALLCORRS: Set to turn on DIST, DOPP, and DARKCORR (default=0)
;-
pro make_plots,add_allcorrs=add_allcorrs,verbose=verbose
	if n_elements(verbose) ne 1 then verbose=0
	if n_elements(add_allcorrs) ne 1 then add_allcorrs=0

	s_ex=(add_allcorrs ? '_dddcorr' : '')
	s_tit=(add_allcorrs ? ' (w/ DDDcorr)' : '')
	;
	; First just plot the UpScan, DownScan and ReF
	;
	FF='(F8.3)'
	close_gwin
	pngdir=get_laspdir(/png)
	txtdir=get_laspdir(/txt)
	DownScan=[9.434134508500002E14, 9.434178736700002E14]
	UpScan=[9.434251237500002E14, 9.434295278700002E14]
	up_color=get_up_color()
	dn_color=get_dn_color()
	rf_color=get_ref_color()
	zwb=get_waveband()
	dwb=get_default_waveband()
	DS_telem=get_telem(DownScan,add_doppcorr=0,add_distcorr=0,add_darkcorr=0)
	US_telem=get_telem(UpScan,add_doppcorr=0,add_distcorr=0,add_darkcorr=0)
	DS_telem_ddd=get_telem(DownScan,add_doppcorr=1,add_distcorr=1,add_darkcorr=1)
	US_telem_ddd=get_telem(UpScan,add_doppcorr=1,add_distcorr=1,add_darkcorr=1)

	DS_telem=(add_allcorrs ? DS_telem_ddd : DS_telem)
	US_telem=(add_allcorrs ? US_telem_ddd : US_telem)
	refspec=get_refspec(do_plot=do_plot)
	scale=1.0
	wDS=plot(DS_telem.waves,DS_telem.irr,name='Down Scan',color=up_color,thick=3,xtitle='Wavelength (nm)',$
		ytitle='Irradiance (W/m$^2$)',$
		dimensions=[800,800],font_name='Times',font_size=14,xrange=dwb,$
		title='UpScan vs DownScan'+s_tit)
	wUS=plot(US_telem.waves,US_telem.irr+0.001,name='Up Scan + 0.001',color=dn_color,/overplot,thick=2)
	rp=plot(refspec.WAVE_NM,refspec.irr,/overplot,color=rf_color,name='Reference',thick=2)
	l=legend(font_name=Times,font_size=12,shadow=0,linestyle=6,position=[0.4,0.8],/normal)

	wDS.save,pngdir+'UpDn'+s_ex+'.png'
	wDSz=plot(DS_telem.waves,DS_telem.irr,name='Down Scan',color=up_color,thick=3,xtitle='Wavelength (nm)',$
		ytitle='Irradiance (W/m$^2$)',$
		dimensions=[800,800],font_name='Times',font_size=14,xrange=dwb,$
		title='UpScan vs DownScan'+s_tit)
	wUSz=plot(US_telem.waves,US_telem.irr,name='Up Scan',color=dn_color,/overplot,thick=2)
	rp=plot(refspec.WAVE_NM,refspec.irr,/overplot,color=rf_color,name='REFERENCE',thick=2)
	l=legend(font_name=Times,font_size=12,shadow=0,linestyle=6,position=[0.4,0.8],/normal)
	;
	; interpolate onto reference spectrum scale and plot
	;
	rwaves=refspec.WAVE_NM
	rflux=refspec.irr
	dflux=interpol(DS_telem.irr,DS_telem.waves,rwaves)
	uflux=interpol(US_telem.irr,US_telem.waves,rwaves)
	findex=where((rwaves ge dwb[0]) and (rwaves le dwb[1]),ct)
	rfwave=rwaves[findex]
	udf=uflux[findex]/dflux[findex]
	urf=uflux[findex]/rflux[findex]
	drf=dflux[findex]/rflux[findex]
	;
	index=where((rwaves ge zwb[0]) and (rwaves le zwb[1]),ct)
	rw=rwaves[index]
	rf=refspec.irr[index]
	uf=uflux[index]
	df=dflux[index]
	ud=uf/df
	ur=uf/rf
	dr=df/rf
	if verbose then help,df,rf,uf,udf,urf,drf
	rindex=where((rw ge 181.1) and (rw le 181.4),ct)
	rflux=rf[rindex]
	rmed_flux=median(rflux)

	cross_correlate,uf,df,udoffset,corr
	cross_correlate,uf,rf,uroffset,corr
	cross_correlate,df,rf,droffset,corr
	if verbose then help,udoffset,uroffset,droffset

	sudoffset=udoffset*(rw[2]-rw[1])
	suroffset=uroffset*(rw[2]-rw[1])
	sdroffset=droffset*(rw[2]-rw[1])
	if verbose then help,sudoffset,suroffset,sdroffset

	wUSz.title='UpScan vs DownScan: Shift is '+string1f(sudoffset,format=FF)+' nm'+s_tit
	l=legend(font_name=Times,font_size=12,shadow=0,linestyle=6,position=[0.4,0.8],/normal)
	wUSz.xrange=zwb
	wUSz.save,pngdir+'UpDn_Zoom'+s_ex+'.png'
	rS=plot(rfwave,udf,name='UP_DOWN_ratio',thick=3,xtitle='Wavelength (nm)',ytitle='UpScan/DownScan',$
		dimensions=[800,800],font_name='Times',font_size=14,xrange=dwb,$
		color='BLUE')
	rS.title='Ratio of UpScan/DownScan: Shift is '+string1f(sudoffset,format=FF)+' nm'+s_tit
	rS.save,pngdir+'UD'+s_ex+'.png'
	rS.xrange=zwb
	rp=plot(refspec.WAVE_NM,refspec.irr/rmed_flux,/overplot,color=rf_color,name='Reference',thick=2)
	l=legend(font_name=Times,font_size=12,shadow=0,linestyle=6,position=[0.5,0.8],/normal)
	rs.save,pngdir+'UD_Zoom'+s_ex+'.png'
	;
	; It is kindof a repeat, but scale UP and DOWN wrt ref and plot
	; in full and zoomed format
	;
	; We already have the common wavelength scale, so we are good to go
	;
	Ascale=plot(rfwave,urf,color=up_color,name='UpScan_div_Ref',xtitle='Wavelength (nm)',ytitle='UpScan & DownScan !C Normalized by Reference Spectrum',$
		dimensions=[800,800],font_name='Times',font_size=14,xrange=dwb,thick=3)
	Ascale_d=plot(rfwave,drf,/overplot,color=dn_color,name='DnScan_div_Ref',thick=2)
	Ascale.title='UpScan/Reference & DownScan/Reference '+s_tit
	l=legend(font_name=Times,font_size=12,shadow=0,linestyle=6,position=[0.5,0.8],/normal)
	;
	Ascale.save,pngdir+'Ascaled'+s_ex+'.png'
	Ascale.xrange=zwb
	Ascale.save,pngdir+'Ascaled_zoom'+s_ex+'.png'
end
