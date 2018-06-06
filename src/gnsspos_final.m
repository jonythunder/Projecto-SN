% Função que calcula a posição actual utilizando DGPS, recebendo os
% pseudo-ranges corrigidos via DGPS, uma posição de referência e as
% posições dos satélites
function xyz = gnsspos_final(last_pos,sat_pos,pr_corrected)
	
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
	end
	
	xyz = ref;
end