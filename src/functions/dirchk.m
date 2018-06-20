% Recebe um angulo e um caracter de direccao e devolve o angulo real orientado
function out = dirchk(ang,dir)
	if dir == 'S' || dir == 's' || dir == 'W' || dir == 'w'
		out = -ang;
	else
		out = ang;
	end
end