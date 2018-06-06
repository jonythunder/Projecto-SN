%% Startup
addpath('./generic_functions/');
warning('off','backtrace');

const.a = 6378137;
const.f = 1/298.257223563;
const.c = 299792458;

WN = 1744;
TOW = 327796;

% fd_eph = fopen('ephemerides.eph'); % -- Verificao de presenca de ficheiro
% if fd_eph == -1
% 	error('File "ephemerides.eph" not found.');
% end
% 
% fd_gspr = fopen('pseudoranges.pr'); % -- Verificao de presenca de ficheiro
% if fd_gspr == -1
% 	error('File "presudoranges.pr" not found.');
% end

input_nmea_path = 'test_data/teste2.nmea'; % -- load input NMEA data
fin = fopen(input_nmea_path);
if fin == -1
    disp('Erro no ficheiro');
    return;
end

% Calcular os erros do pseudo-range com base na estação local
% satellites_prerror = gs_error;

%parse the NMEA data and get a vector of (Lat,Lon,Height,time) points
[position_points] = parse_NMEA(fin);

%% Calculating pseudo-ranges
input_raw = load('test_data/ub1.ubx.1744.327600.raw');

pr_raw = zeros(50,2); pr_line = 13;
for aux = 1:50
	pr_raw(aux,:) = [input_raw(pr_line,(aux - 1)*10 + 4) input_raw(pr_line,(aux - 1)*10 + 11)];
end

input_eph = load('test_data/ub1.ubx.1744.327600.eph');

%% Position based on pseudo-ranges

satellites_test = [12 23954057.4169302 -11218474.0657221 -341693.401251755 293.790403789559;15 20624126.3122062 -1195547.13253004 16800120.6658581 267.820416306825;18 9603779.70052487 -18418364.6520372 16713889.9451206 293.581793086853;26 22527224.2081114 12377924.0029190 6773448.60650130 292.891910159391;27 14949962.2554318 -3754576.39522038 22183132.5866638 273.119264511141];
pr_raw = [1 22008526.3942958;2 20164251.7162603;3 22130483.2263822;4 22046572.8415926;5 20883366.9715182];
satellites_test = [1 23954057.4169302 -11218474.0657221 -341693.401251755;2 20624126.3122062 -1195547.13253004 16800120.6658581;3 9603779.70052487 -18418364.6520372 16713889.9451206;4 22527224.2081114 12377924.0029190 6773448.60650130;5 14949962.2554318 -3754576.39522038 22183132.5866638];

xyz = gnsspos_final([0,0,0],satellites_test,pr_raw);

%% Overlap check

% count = 0; triggered_lines = [];
% for aux = 1:max(size(position_points))
% 	point = llh2xyz([deg2rad(position_points(aux,1:2)) position_points(aux,3)],const.a,const.f);
% 	if overlap_check(point)
% 		count = count + 1;
% 		triggered_lines = [triggered_lines aux];
% 	end
% end

[overlap,area] = overlap_check(xyz);
if overlap
	warning('Current location is overlapping area %d.',area);
end