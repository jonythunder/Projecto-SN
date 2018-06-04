% Função que recebe um ponto e verifica se está dentro de alguma área
% restrita, devolvendo o primeiro argumento como 1 se existir overlap
% e um segundo argumento como um vector com o ID das áreas transpostas.
function [ifoverlap, overlap_areas] = overlap_check(xyz)
	const.a = 6378137;
	const.f = 1/298.257223563;
	overlap_areas = [];
	ifoverlap = false;
	
	% -- Definition of restricted areas
	% Sphere
	area1.id = 1;
	area1.type = "sphere"; % -- Types: sphere, cylinder, box
	area1.radius = 20; % -- Meters
	area1.center = llh2xyz([	dirchk(dms2rad([38,44,12.46]),'N')...
								dirchk(dms2rad([9,08,18.91]),'W')...
								102],const.a,const.f); % -- xyz, meters

	% Cylinder
	area2.id = 2;
	area2.type = "cylinder"; % -- Types: sphere, cylinder, box
	area2.radius = 20; % -- Meters
	area2.height = 20; % -- Meters
	area2.bottom_xyz = llh2xyz([	dirchk(dms2rad([38,44,12.46]),'N')...
								dirchk(dms2rad([9,08,18.91]),'W')...
								102],const.a,const.f); % -- xyz, meters
	area2.bottom_llh = ([	dirchk(dms2rad([38,44,12.46]),'N')...
								dirchk(dms2rad([9,08,18.91]),'W')...
								102],const.a,const.f); % -- xyz, meters



	% -- Check intrusion
	if area1.type == "sphere"
		dist = norm(xyz - area1.center);
		if dist <= area1.radius
			ifoverlap = true; overlap_areas = [overlap_areas area1.id];
		end
	end

	if area2.type == "cylinder"
		%Fazer a divisão do cilindro em fatias, e usar a altitude do receptor móvel para 
		%determinar a intrusão
		% -- Converter para LLH para obter a altitude -- %
		[llh]=xyz2llh(xyz,const.a,const.f);
		if llh(3)<=area2.height
			%Define the slice height
			slice_center=([area2.bottom_llh(1);area2.bottom_llh(2);llh(3)]);
			slice_center_xyz=llh2xyz(slice_center,const.a,const.f);
			dist = norm(xyz - slice_center_xyz);
			if dist <= area2.radius
				ifoverlap = true; overlap_areas = [overlap_areas area2.id];
			end
		end
	end
end