% Função que calcula a posição actual utilizando DGPS, recebendo os
% pseudo-ranges corrigidos via DGPS, uma posição de referência e as
% posições dos satélites
function xyz = gnsspos_final(input_eph,input_hui,pr_filtered,WN,TOW,ref)
	
global	const

    
	last_pos = ref;
	ref = ref';
	
	satellites_pos = satellite_positions(input_eph,input_hui,WN,TOW,ref');
	
	satellites_used = [];
	pr_used = [];
	[satellites_used,pr_used] = satellites_filter(satellites_pos,pr_filtered,ref);
	satellites_used = satellites_used';
	
	e0result = []; h = []; z = []; xest = [];
	valid = true;
	while valid
		for aux = 1:size(satellites_used,2)
			e0 = (satellites_used(:,aux) - ref)/norm(satellites_used(:,aux) - ref);
			e0result = [e0result e0];
			z(aux,1) = pr_used(aux,1) - e0' * satellites_used(:,aux);
			h(aux,1:4) = [-e0' 1];
		end
		
		xest = (h' * h)^(-1) * h' * z;
		
		if norm(xest(1:3) - ref) < 0.001
	 		ref = xest(1:3);
	 		valid=false;
	 	end

		ref = xest(1:3);
        %disp(norm(ref-last_pos'));
		
		satellites_pos = satellite_positions(input_eph,input_hui,WN,TOW,ref');
		
		satellites_used = [];
		pr_used = [];
		[satellites_used,pr_used] = satellites_filter(satellites_pos,pr_filtered,ref);
		satellites_used = satellites_used';
	end
	
	xyz = ref;
	
% 	n = z - h * xest;
% 	M = (h' * h)^(-1);
% 
% 	GDOP = sqrt(trace(M));
% 
% 	PDOP = sqrt(trace(M(1:3,1:3)));
% 	TDOP = sqrt(M(4,4));
% 
% 	xest_llh = xyz2llh(xest',const.a,const.f);
% 	satellites_used_enu = satellites_used;
% 	for aux = 1:size(satellites_used,2)
% 		[satellites_used_enu(1,aux),satellites_used_enu(2,aux),satellites_used_enu(3,aux)] = ecef2enu(satellites_used(1,aux),...
% 			satellites_used(2,aux),satellites_used(3,aux),xest_llh(1),xest_llh(2),xest_llh(3),referenceEllipsoid('wgs84'),'radians');
% 	end

% 	for aux = 1:size(satellites_used,2)
% 		e0_enu = (satellites_used_enu(:,aux))/norm(satellites_used_enu(:,aux));
% 		h_enu(aux,1:4) = [-e0_enu' 1];
% 	end
% 
% 	M_enu = (h_enu' * h_enu)^(-1);
% 	HDOP = sqrt(trace(M_enu(1:2,1:2)));
% 	VDOP = sqrt(M_enu(3,3));
end

function [satellites_out,pr_out] = satellites_filter(satellites_in,pr_in,ref)
	global	const
	
	ref_llh = xyz2llh(ref,const.a,const.f);
	
% 	[satenu(1),satenu(2),satenu(3)] = ecef2enu(s(1),s(2),s(3),...
% 		ref_llh(1),ref_llh(2),ref_llh(3),referenceEllipsoid('wgs84'),'radians');
% 	satellites_enu(line_counter,:) = [s2dc(temp{1}), satenu];
% 	satellites_enu_norm(line_counter,:) = [s2dc(temp{1}),...
% 		satenu/(norm(ref - s))];
% 	
% 	az = atan2(satenu(1),satenu(2));
% 	el = atan2(satenu(3),sqrt(satenu(1).^2 + satenu(2).^2));
% 	satellites_azel(line_counter,:) = [s2dc(temp{1}), az, el];
	
	for aux = 1:size(satellites_in,1)
		satellites_enu(aux,1) = satellites_in(aux,1);
		[satellites_enu(aux,2),satellites_enu(aux,3),satellites_enu(aux,4)] = ecef2enu(satellites_in(aux,2),satellites_in(aux,3),satellites_in(aux,2),...
			ref_llh(1),ref_llh(2),ref_llh(3),referenceEllipsoid('wgs84'),'radians');
		az = atan2(satellites_enu(aux,2),satellites_enu(aux,3));
		el = atan2(satellites_enu(aux,4),sqrt(satellites_enu(aux,2).^2 + satellites_enu(aux,3).^2));
		satellites_azel(aux,:) = [satellites_in(aux,1) az el];
	end
	satellites_out = []; pr_out = [];
	for aux1 = 1:size(satellites_in,1)
		for aux2 = 1:size(pr_in,1)
			if (satellites_in(aux1,1) == pr_in(aux2,1)) && (satellites_azel(aux,3) > deg2rad(5))
				satellites_out = [satellites_out; satellites_in(aux1,2:4)];
				pr_out = [pr_out;pr_in(aux2,2)+ satellites_in(aux1,5)];%*const.c];
			end
		end
	end
end