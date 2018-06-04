% Converter de latitude, longitude e altitude (vector de 3 casas) para coordenadas cartesianas, considerando semieixo maior a e factor de achatamento f
function xyz = llh2xyz(llh,a,f)
	xyz = [];
	R_n = a / (sqrt(1 - f * (2 - f) * sin(llh(1)).^2));
	xyz(1) = (R_n + llh(3)) * cos(llh(1)) * cos(llh(2));
	xyz(2) = (R_n + llh(3)) * cos(llh(1)) * sin(llh(2));
	xyz(3) = ((1 - f).^2 * R_n + llh(3)) * sin(llh(1));
end