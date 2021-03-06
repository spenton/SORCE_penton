; docformat = 'rst'

;+
; NAME: EVAL_QUICKSCAN
;
; PURPOSE: One off program to evaluate QuickScan data
;
;-
pro eval_quickscan
		rcs_id="$Id: eval_quickscan.pro,v 1.4 2018/04/24 16:46:22 penton Exp $"
		pngdir=get_laspdir(/png)
		colors=tag_names(!color)
		QuickScan=[9.434017775100002E14, 9.434062192200002E14]
		QS_telem=get_telem(QuickScan,/add_darkcorr,/add_doppcorr,/add_distcorr)
		up_color=get_up_color()
		dn_color=get_dn_color()
		rf_color=get_ref_color()
		zwb=get_waveband()
		dwb=get_default_waveband()
		time0=min(QS_telem.times_s)
		time=QS_telem.times_s-time0
		tQS=plot(time,QS_telem.Temps,xtitle='Time (s)',ytitle='Temp',name='Quick Scan',$
			font_size=12,font_name='Times',$
			color='HOT PINK',linestyle=6,symbol='o')
		tQS.title='QuickScan Orbit Temperature'
		tQS.save,pngdir+'tQS_temp.png'
		refspec=get_refspec(do_plot=0)
		gwaves=QS_telem.gwaves
		gtemps=QS_telem.temps
		irr=QS_telem.irr
		derivs=deriv(gwaves)
		index=where(derivs ge 7,count)
		forprint,gwaves[index],irr[index]
		index=[0,index,-1]
		rwave=gwaves[index[0]:index[1]]
		it=sort(rwave)
		rwave=rwave[it]
		rflux=interpol(refspec.irr,refspec.wave_nm,rwave)
		reference_flux=rflux
		op=plot(refspec.wave_nm,refspec.irr,color=rf_color,thick=3,$
			name='Reference',linestyle=2)
		med_temps=(offsets=fltarr(count/2))
		ii=0
		for i=0,count-1,2 do begin
			waves=gwaves[index[i]:index[i+1]]
			temps=gtemps[index[i]:index[i+1]]
			it=sort(waves)
			waves=waves[it]
			counts=irr[index[i]:index[i+1]]
			counts=counts[it]
			cross_correlate,counts,reference_flux,offset,corr,width=50
			offsets[ii]=offset*(waves[3]-waves[2])
			med_temps[ii]=median(temps)
		print,ii,offset,waves[3],waves[2],(waves[3]-waves[2]),offsets[ii]
			ii++
			p=plot(waves,counts+((i/2+1.0)*0.001),/overplot,xrange=zwb,$
				xtitle='Wavelength (nm)',ytitle='Irr + 0.001*(scan#)',font_name='Times',$
				font_size=14,color=colors[i+5],dimensions=[800,800],thick=2)
		endfor
		p=plot(offsets)
		t=plot(med_temps)
		stop
		p.title='QuickScan Alignment'
		op.save,pngdir+'tQS_scans.png'
end
