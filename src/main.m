addpath('./generic_functions/');
warning('off','backtrace');

const.a = 6378137;
const.f = 1/298.257223563;
const.c = 299792458;

%Este ficheiro tem como objectivo utilizar dados NMEA para validar o
%algoritmo de detecção de intrusão.

%load input data
input_data_path = 'test_data/teste2.nmea';
fin = fopen(input_data_path);
if fin == -1
    disp('Erro no ficheiro');
    return;
end

%parse the NMEA data and get a vector of (Lat,Lon,Height,time) points
[position_points] = parse_NMEA(fin);

count = 0; triggered_lines = [];
for aux = 1:max(size(position_points))
	point = llh2xyz([deg2rad(position_points(aux,1:2)) position_points(aux,3)],const.a,const.f);
	if overlap_check(point)
		count = count + 1;
		triggered_lines = [triggered_lines aux];
	end
end