; docformat = 'rst'

;+
;	NAME get_laspdir
;
;	PURPOSE: Set the local working directory
;
;	USAGE: dir=get_lampdir([,PNG=PNG][,TXT=TXT])
;
; OUTPUT PARAMETERS:
;     Local directory of data products
;-
function get_laspdir,png=png,txt=txt
	if keyword_set(txt) ne 1 then txt=0
	if keyword_set(png) ne 1 then png=0
	RCS_ID="$Id: get_laspdir.pro,v 1.3 2018/04/24 16:46:22 penton Exp $"
	dir='~/Dropbox/LASP/'
	if png then dir+='png/'
	if txt then dir+='txt/'
	return,dir
end
