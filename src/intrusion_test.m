format longg
clear
clc


addpath('./generic_functions/');
addpath('./test_functions/');

warning('off','backtrace');

global const
const.a = 6378137;
const.f = 1/298.257223563;

input_data_path = 'test_data/teste2.nmea'; % -- load input data
fin = fopen(input_data_path);
if fin == -1
    disp('Erro no ficheiro');
    return;
end


% Parse the NMEA data and get a vector of (Lat,Lon,Height,time) points
[input_nmea_test] = parse_NMEA(fin);

%Remove NaN errors in the NMEA file
erro=[];
for i=1:size(input_nmea_test,1)
    for j=1:4
        if isnan(input_nmea_test(i,j))
            erro=[erro,i];
        end
    end
end
input_nmea_test(erro(:),:)=[];

%Generate a KML file with all the test points
kmlwritepoint('kml_teste.kml', input_nmea_test(:,1), input_nmea_test(:,2), 'Name', []);


%Test areas where created using the script generate_bounding_boxes,
%their areas saved as a .mat file and loaded here
load areas.mat;

%Test for spherical area
[overlap_out_sphere] = intrusion_detection(input_nmea_test(:,1:3),area(1));
%Use the coordinates used to create the area
center_lat=38.7367861111111;
center_lon=-9.13855833333334;
center_h=136.719999995178;
radius=area(1).radius;
kmlwrite


%Test for cylindrical area
[overlap_out_cylinder] = intrusion_detection(input_nmea_test(:,1:3),area(2));
%Use the coordinates used to create the area
center_lat=38.7367861111111;
center_lon=-9.13855833333333;
center_h=129.999999999042;
radius=area(1).radius;



%Test for box area
[overlap_out_box] = intrusion_detection(input_nmea_test(:,1:3),area(3));
%Use the coordinates used to create the area
point1=[38.7374916666667 -9.13913611111111 120.000000000489];
point2=[38.7374916665995 -9.13901075648354 120.000009299696];
point3=[38.7373821164558 -9.13901075667503 120.000020927243];
point4=[38.737382116523 -9.13913611111111 120.000011626626];

