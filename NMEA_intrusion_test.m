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