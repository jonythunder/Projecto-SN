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

xyz = gnsspos_final(pr_current, satellites_prerror);

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