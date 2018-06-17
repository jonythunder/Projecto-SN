% Funcao para obter latitude, longitude e altitude a partir de coordenadas cartesianas via o metodo de Heikkinen
function llh = xyz2llh(xyz,a,f)
	llh = [];
	b = a * (1 - f);
	r = sqrt(xyz(1).^2 + xyz(2).^2);
	e2 = 1 - (b.^2 / a.^2);
	ed2 = (a.^2 / b.^2) - 1;
	e = sqrt(e2);
	
	llh(2) = atan2(xyz(2),xyz(1));
	
	F = 54 * b.^2 * xyz(3).^2;
	G = r.^2 + (1 - e.^2) * xyz(3).^2 - e.^2 * (a.^2 - b.^2);
	c = e.^4 * F * r.^2 / G.^3;
	s = nthroot(1 + c + sqrt(c.^2 + 2 * c), 3);
	P = F / (3 * (s + 1/s + 1).^2 * G.^2);
	Q = sqrt(1 + 2 * e.^4 * P);
	r_0 = -(P * e.^2 * r)/(1 + Q) + sqrt((a.^2 / 2) * (1 + 1/Q)...
		- (P * (1 - e.^2) * xyz(3).^2)/(Q * (1 + Q)) - P * r.^2 / 2);
	U = sqrt((r - e.^2 * r_0).^2 + xyz(3).^2);
	V = sqrt((r - e.^2 * r_0).^2 + (1 - e.^2) * xyz(3).^2);
	z_0 = (b.^2 * xyz(3)) / (a * V);
	llh(3) = U * (1 - b.^2 / (a * V));
	llh(1) = atan2((xyz(3) + ed2 * z_0), r);
end