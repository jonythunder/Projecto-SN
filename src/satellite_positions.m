function satellites_pos = satellite_positions(input_eph,WN,TOW,ref)
	const.mu_e = 3.986005e+14;
	const.c = 299792458;
	const.Omegadot_e = 7.2921151467e-5;
	const.a = 6378137;
	const.f = 1/298.257223563;
	
	for aux = 1:size(input_eph,1)
		d = 0;
		d_prev = 1;

		WN_eph		= input_eph(aux,4);
		t_oe		= input_eph(aux,7);
		A			= input_eph(aux,34).^2;
		Delta_eta	= input_eph(aux,37);
		M_0			= input_eph(aux,40);
		e			= input_eph(aux,43);
		argper		= input_eph(aux,46);

		eta = sqrt(const.mu_e / A.^3) + Delta_eta;

% 		WN = wncheck(WN);
% 		WN_eph = wncheck(WN_eph);

		Delta_t = (WN*7*24*60*60 + TOW) - (WN_eph*7*24*60*60 + t_oe);

		M = M_0 + eta * Delta_t;

		E = eccanom(10e-12,e,M);

		phi_0 = atan2(sqrt(1 - e.^2) * sin(E),cos(E) - e);

		phi = phi_0 + argper;

		delta_u = input_eph(aux,61) * cos(2 * phi) + input_eph(aux,64) * sin(2 * phi);
		u = phi + delta_u;

		r_0 = A * (1 - e * cos(E));
		delta_r = input_eph(aux,67) * cos(2 * phi) + input_eph(aux,70) * sin(2 * phi);
		r = r_0 + delta_r;

		delta_i = input_eph(aux,73) * cos(2 * phi) + input_eph(aux,76) * sin(2 * phi);
		i = input_eph(aux,49) + delta_i + input_eph(aux,52) * Delta_t;

		lonasc = input_eph(aux,55) + (input_eph(aux,58) - const.Omegadot_e)...
			* Delta_t - const.Omegadot_e * t_oe;
		xyz = [r * cos(u), r * sin(u), 0]...
			* [	1,	0,			0;...
				0,	cos(-i),	-sin(-i);...
				0,	sin(-i),	cos(-i)]...
			* [	cos(-lonasc),	-sin(-lonasc),	0;
				sin(-lonasc),	cos(-lonasc),	0;
				0,				0,				1];


		while abs(d_prev - d) >= 0.001

			d_prev = d;

			t_tx = TOW - d_prev/const.c;
			Delta_t = t_tx - t_oe;

			M = M_0 + eta * Delta_t;

			E = eccanom(10e-12,e,M);

			phi_0 = atan2(sqrt(1 - e.^2) * sin(E),cos(E) - e);
			phi = phi_0 + argper;

			delta_u = input_eph(aux,61) * cos(2 * phi) + input_eph(aux,64) * sin(2 * phi);
			u = phi + delta_u;

			r_0 = A * (1 - e * cos(E));
			delta_r = input_eph(aux,67) * cos(2 * phi) + input_eph(aux,70) * sin(2 * phi);
			r = r_0 + delta_r;

			delta_i = input_eph(aux,73) * cos(2 * phi) + input_eph(aux,76) * sin(2 * phi);
			i = input_eph(aux,49) + delta_i + input_eph(aux,52) * Delta_t;

			lonasc = input_eph(aux,55) + (input_eph(aux,58) - const.Omegadot_e)...
				* Delta_t - const.Omegadot_e * t_oe;
			s = [r * cos(u), r * sin(u), 0]...
				* [	1,	0,			0		;...
					0,	cos(-i),	-sin(-i);...
					0,	sin(-i),	cos(-i)	]...
				* [	cos(-lonasc),	-sin(-lonasc),	0;...
					sin(-lonasc),	cos(-lonasc),	0;...
					0,				0,				1];

			deltaOmega = const.Omegadot_e * (d_prev/const.c);

			s = [cos(-deltaOmega),	-sin(-deltaOmega),	0;...
				sin(-deltaOmega),	cos(-deltaOmega),	0;...
				0,					0,					1] * s';
			s = s';

			d = norm(s - ref);
		end
		
		satellites_pos(aux,:) = [input_eph(aux,1), s];
	end
end

function E = eccanom(delta,e,M)
	E = 0; E_prev = 0;
	delta_temp = inf;
	while delta_temp > delta
		E_prev = E;
		E = M + e * sin(E);
		delta_temp = abs(E_prev - E);
	end
end