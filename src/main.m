%% Startup
addpath('./generic_functions/');
warning('off','backtrace');

const.a = 6378137;
const.f = 1/298.257223563;
const.c = 299792458;

% fd_eph = fopen('ephemerides.eph'); % -- Verificao de presenca de ficheiro
% if fd_eph == -1
% 	error('File "ephemerides.eph" not found.');
% end
% 
% fd_gspr = fopen('pseudoranges.pr'); % -- Verificao de presenca de ficheiro
% if fd_gspr == -1
% 	error('File "presudoranges.pr" not found.');
% end

input_data_path = 'test_data/teste2.nmea'; % -- load input data
fin = fopen(input_data_path);
if fin == -1
    disp('Erro no ficheiro');
    return;
end

% Calcular os erros do pseudo-range com base na estação local
% satellites_prerror = gs_error;

%parse the NMEA data and get a vector of (Lat,Lon,Height,time) points
[position_points] = parse_NMEA(fin);

%% Position based on pseudo-ranges

% xyz = gnsspos_final(pr_current, satellites_prerror);

%% Overlap check
count = 0; triggered_lines = [];
for aux = 1:max(size(position_points))
	point = llh2xyz([deg2rad(position_points(aux,1:2)) position_points(aux,3)],const.a,const.f);
	if overlap_check(point)
		count = count + 1;
		triggered_lines = [triggered_lines aux];
	end
end