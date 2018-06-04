function [ifoverlap, overlap_areas] = overlap_check(xyz)
	const.a = 6378137;
	const.f = 1/298.257223563;
	overlap_areas = [];
	
	% -- Definition of restricted areas
	area1.id = 1;
	area1.type = "sphere"; % -- Types: sphere, cylinder, box
	area1.radius = 1000000; % -- Meters
	area1.center = llh2xyz([	dirchk(dms2rad([38,44,12.46]),'N')...
								dirchk(dms2rad([9,08,18.91]),'W')...
								102],const.a,const.f); % -- xyz, meters

	% -- Check intrusion
	if area1.type == "sphere"
		dist = norm(xyz - area1.center);
		if dist < area1.radius
			ifoverlap = 1; overlap_areas = [overlap_areas area1.id];
		end
	end
end