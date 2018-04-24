; docformat = 'rst'

;+
;	FUNCTION	get_refspec
;
;	PURPOSE: Read reference spectrum file
;
;	USAGE: ref=get_refspec([DO_PLOT=DO_PLOT][,COLOR=COLOR])
;
;	OPTIONAL INPUT PARAMETERS:
;
;	COLOR: Pass in the reference color for plotting, if the
;          default reference color from get_ref_color is not appropriate
;	DO_PLOT: Set to make a quick plot of the reference spectrum
;
;-
function get_refspec,do_plot=do_plot,color=color
	; irradiance='watt/m^2'
	if n_elements(color) ne 1 then color=get_ref_color()
	if n_elements(do_plot) ne 1 then do_plot=0
	tdir=get_laspdir(/txt)
	file='referenceSpectrum.txt'
	readcol,tdir+file,nm,irr,format='(D,D)',SKIPLINE=1,/NAN,delimiter=','
	units='watts/m^2' ; irradiance
	sunits='watts/m^2/nm' ; spectral irradiance
	sp=(p=!values.f_nan)
	;wavelength(nm), irradiance (watts/m^2)
	;172.0, 7.792524528931793E-4
	;172.005, 7.924657419720116E-4

	binsize=(nm[1]-nm[0])
	spirr=irr/binsize
	if do_plot then begin
		p=plot(nm,irr,xtitle='Wavelength (nm)',ytitle='Irradiance ('+units+')',font_name='Times',font_size=14,color=color)
		sp=plot(nm,spirr,xtitle='Wavelength (nm)',ytitle='Spectral Irradiance ('+sunits+')',font_name='Times',font_size=14,color=color)
	endif
	out={wave_nm:nm,do_plot:do_plot,sp:sp,p:p,binsize:binsize,$
		irr:irr,units:units,$
		spirr:spirr,sunits:sunits}
	return,out
end
