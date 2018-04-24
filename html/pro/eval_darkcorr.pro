; docformat = 'rst'

;+
;	NAME: EVAL_DARKCOR
;
;	PURPOSE; One off program to calibrate DARK with Temperature
;-
pro eval_darkcorr
	pngdir=get_laspdir(/png)
	txtdir=get_laspdir(/txt)
	close_gwin
	Dark=[9.434192873600002E14, 9.434237008000002E14]
	DK_telem=get_telem(Dark,/dark)
	times=DK_telem.times_s
	p=plot(times,DK_telem.counts)
	dtimes=abs(shift(times,-2)-(times))/2.0
	dtimes[-1]=dtimes[-3]
	dtimes[-2]=dtimes[-3]
	dtimes[0]=dtimes[2]
	dtimes[1]=dtimes[2]
	p=plot(DK_telem.temps,smooth(DK_telem.counts,7)/dtimes,ytitle='BKG CPS',xtitle='Temperature (C)',$
		font_size=14,font_name='Times')
	c=poly_fit(DK_telem.temps,smooth(DK_telem.counts,7)/dtimes,2,yfit=yfit)
	forprint,c
	q=plot(DK_telem.temps,yfit,color='RED',/overplot,thick=2)
	p.save,pngdir+'DARK_vs_TEMP.png'
	save,file=txtdir+'dark_coeff.dat',c,/verbose
end

