%% Startup
addpath('./generic_functions/');
warning('off','backtrace');
format longg
clear
global const;
const.a = 6378137;
const.f = 1/298.257223563;
const.c = 299792458;
const.F = - 4.442807633*(10^(-10));
const.mu_e = 3.986005e+14;
const.Omegadot_e = 7.2921151467e-5;

RF1 = [4918528.02 -791210.72 3969759.39];
RF2 = [4918525.18 -791212.21 3969762.19];

WN = 1744;
TOW = 327793.6;

% satellites_prerror = gs_error;

fin = fopen('test_data/teste2.nmea'); % -- load input NMEA data
if fin == -1
    disp('Erro no ficheiro');
    return;
end

% Parse the NMEA data and get a vector of (Lat,Lon,Height,time) points
[input_nmea_test] = parse_NMEA(fin);

input_raw = load('test_data/ub1.ubx.1744.327600.raw');
input_eph = load('test_data/ub1.ubx.1744.327600.eph');
input_hui = load('test_data/ub1.ubx.1744.327600.hui');
input_raw2 = load('test_data/ub2.ubx.1744.327600.raw');
input_eph2 = load('test_data/ub2.ubx.1744.327600.eph');
input_hui2 = load('test_data/ub2.ubx.1744.327600.hui');


%% Calculating pseudo-ranges

pr_raw = zeros(50,2); pr_filtered = []; pr_line = [];

for aux = 1:size(input_raw,1)
	if (input_raw(aux,1) == TOW*1000) && isempty(pr_line)
		pr_line = aux;
	end
end

for aux = 1:50
	pr_raw(aux,:) = [input_raw(pr_line,(aux - 1)*10 + 4) input_raw(pr_line,(aux - 1)*10 + 11)];
	if (pr_raw(aux,1) > 0) && (pr_raw(aux,1) <= 32)
		pr_filtered = [pr_filtered; pr_raw(aux,:)];
	end
end

%% Position based on pseudo-ranges and satellite positions

% pr_filtered = [9 20536028.7375603;12 22166455.5048996;15 20444176.1682478;17 23963808.3735086;18 22366369.6169282;22 24915155.0699065;26 22419323.7026119;27 21167000.4665947];

xyz = gnsspos_final(input_eph,input_hui,pr_filtered,WN,TOW,RF1);


%%
% pr_raw2 = zeros(50,2); pr_filtered2 = []; pr_line2 = [];
% 
% sat_pos  = satellite_positions(input_eph,input_hui,WN,TOW,RF1);
% sat_pr_error = gs_error(sat_pos,pr_filtered,RF1);
% 
% for aux = 1:size(input_raw2,1)
% 	if (input_raw2(aux,1) == TOW*1000) && isempty(pr_line2)
% 		pr_line2 = aux;
% 	end
% end
% 
% for aux = 1:50
% 	pr_raw2(aux,:) = [input_raw2(pr_line,(aux - 1)*10 + 4) input_raw2(pr_line,(aux - 1)*10 + 11)];
% 	if (pr_raw2(aux,1) > 0) && (pr_raw2(aux,1) <= 32)
% 		pr_filtered2 = [pr_filtered2; pr_raw2(aux,:)];
% 	end
% end
% 
% % for i=1:size(pr_filtered,1)
% %     for j=1:size(sat_pr_error,1)
% %         if pr_filtered(i,1) == sat_pr_error(j,1)
% %             pr_filtered(i,2) = pr_filtered(i,2) - sat_pr_error(j,2);
% %         end
% %     end
% % end
% 
% xyz2 = gnsspos_final(input_eph2,input_hui2,pr_filtered2,WN,TOW,RF1);
%  
% disp(norm(xyz-xyz2));
%% Overlap check

% count = 0; triggered_lines = [];
% for aux = 1:max(size(input_nmea_test))
% 	point = llh2xyz([deg2rad(input_nmea_test(aux,1:2)) input_nmea_test(aux,3)],const.a,const.f);
% 	if overlap_check(point)
% 		count = count + 1;
% 		triggered_lines = [triggered_lines aux];
% 	end
% end

% [overlap,area] = overlap_check(xyz);
% if overlap
% 	warning('Current location is overlapping area %d.',area);
% end