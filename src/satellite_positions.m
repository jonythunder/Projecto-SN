function [satellites_pos] = satellite_positions(input_eph,input_hui,WN,TOW,ref)
	
	global const
	
    
	
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
        
        alpha = [input_hui(1,13),input_hui(1,15),input_hui(1,17),input_hui(1,19)];
        beta = [input_hui(1,21),input_hui(1,23),input_hui(1,25),input_hui(1,27)];
        tropo = troposphere_model(ref,s,WN,TOW);
        iono = ionosphere_model(alpha,beta,ref,s,t_tx);
        t1 =(const.F*(e^(input_eph(aux,34)))*sin(E));
        t2 = input_eph(aux,18)*const.c;
		t3 = (input_hui(1,13)+(input_hui(1,15)*(t_tx-input_eph(aux,22)))+(input_hui(1,17)*((t_tx-input_eph(aux,22))^(2))))*const.c;
        
        delta_tsv = t1-t2+t3-iono;%-tropo;
    
		satellites_pos(aux,:) = [input_eph(aux,1), s, delta_tsv];
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