%% Startup
clear
clc

addpath('./generic_functions/');
warning('off','backtrace');


% satellites_prerror = gs_error;

fin = fopen('test_data/teste2.nmea'); % -- load input NMEA data
if fin == -1
    disp('Erro no ficheiro');
    return;
end

% Parse the NMEA data and get a vector of (Lat,Lon,Height,time) points
[input_nmea_test] = parse_NMEA(fin);

erro=[];
for i=1:size(input_nmea_test,1)
    for j=1:4
        if isnan(input_nmea_test(i,j))
            erro=[erro,i];
        end
    end
end
input_nmea_test(erro(:),:)=[];

kmlwritepoint('kml_teste.kml', input_nmea_test(:,1), input_nmea_test(:,2), 'Name', []);

