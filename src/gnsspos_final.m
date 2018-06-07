% Função que calcula a posição actual utilizando DGPS, recebendo os
% pseudo-ranges corrigidos via DGPS, uma posição de referência e as
% posições dos satélites
function xyz = gnsspos_final(last_pos,sat_pos,pr_corrected)
	
	const.a = 6378137;
	const.f = 1/298.257223563;
	const.c = 299792458;
	
	satellites_used = [];
	pr_used = [];
	
	for aux1 = 1:size(sat_pos,1)
		for aux2 = 1:size(pr_corrected,1)
			if sat_pos(aux1,1) == pr_corrected(aux2,1)
				satellites_used = [satellites_used; sat_pos(aux1,2:4)];
				pr_used = [pr_used;pr_corrected(aux2,2)];
			end
		end
	end
	
	ref = last_pos';
	satellites_used = satellites_used';
	
	e0result = []; h = []; z = []; xest = [];
	
	while 1
		for aux = 1:size(satellites_used,2)
			e0 = (satellites_used(:,aux) - ref)/norm(satellites_used(:,aux) - ref);
			e0result = [e0result e0];
			z(aux,1) = pr_used(aux,1) - e0' * satellites_used(:,aux);
			h(aux,1:4) = [-e0' 1];
		end
		
		xest = (h' * h)^(-1) * h' * z;
		
		if norm(xest(1:3) - ref) < 0.001
	 		ref = xest(1:3);
	 		break;
	 	end

		ref = xest(1:3);
        disp(norm(ref-last_pos'));
	end
	
	xyz = ref;
	
	n = z - h * xest;
	M = (h' * h)^(-1);

	GDOP = sqrt(trace(M));

	PDOP = sqrt(trace(M(1:3,1:3)));
	TDOP = sqrt(M(4,4));

	xest_llh = xyz2llh(xest',const.a,const.f);
	satellites_used_enu = satellites_used;
	for aux = 1:size(satellites_used,2)
		[satellites_used_enu(1,aux),satellites_used_enu(2,aux),satellites_used_enu(3,aux)] = ecef2enu(satellites_used(1,aux),...
			satellites_used(2,aux),satellites_used(3,aux),xest_llh(1),xest_llh(2),xest_llh(3),referenceEllipsoid('wgs84'),'radians');
	end

	for aux = 1:size(satellites_used,2)
		e0_enu = (satellites_used_enu(:,aux))/norm(satellites_used_enu(:,aux));
		h_enu(aux,1:4) = [-e0_enu' 1];
	end

	M_enu = (h_enu' * h_enu)^(-1);
	HDOP = sqrt(trace(M_enu(1:2,1:2)));
	VDOP = sqrt(M_enu(3,3));
end