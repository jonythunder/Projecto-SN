% Converter de graus, minutos e segundos (em vector) para radianos
function out = dms2rad(dms)
	out = deg2rad(dms(1) + dms(2)/60 + dms(3)/(60.^2));
end