addpath('./generic_functions/');
warning('off','backtrace');

const.a = 6378137;
const.f = 1/298.257223563;
const.c = 299792458;

%Este ficheiro tem como objectivo utilizar dados NMEA para validar o
%algoritmo de detecção de intrusão.

%load input data
input_data_path='test_data/20170529162136.txt';
fin=fopen(input_data_path);
if fin == -1
    disp('Erro no ficheiro');
    return;
end

%parse the NMEA data and get a vector of (Lat,Lon,Height,time) points
[position_points] = parse_NMEA(fin);
point1 = llh2xyz([deg2rad(position_points(1,1:2)) position_points(1,3)],const.a,const.f);

overlap_check(point1);