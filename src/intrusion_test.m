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

[lat1,lon1] = scircle1(center_lat,center_lon,radius,[],earthRadius('m'));
kmlwritepolygon('spherical_area_projection.kml',lat1,lon1,'EdgeColor','c','FaceColor','c','FaceAlpha',.5);


%Test for cylindrical area
[overlap_out_cylinder] = intrusion_detection(input_nmea_test(:,1:3),area(2));
%Use the coordinates used to create the area
center_lat=38.7367861111111;
center_lon=-9.13855833333333;
center_h=129.999999999042;
radius=area(2).radius;

[lat1,lon1] = scircle1(center_lat,center_lon,radius,[],earthRadius('m'));
kmlwritepolygon('cylindrical_area_projection.kml',lat1,lon1,'EdgeColor','r','FaceColor','r','FaceAlpha',.5);


%Test for box area
[overlap_out_box] = intrusion_detection(input_nmea_test(:,1:3),area(3));
%Use the coordinates used to create the area
point1=[38.7374916666667 -9.13913611111111 120.000000000489];
point2=[38.7374916665995 -9.13901075648354 120.000009299696];
point3=[38.7373821164558 -9.13901075667503 120.000020927243];
point4=[38.737382116523 -9.13913611111111 120.000011626626];

kmlwritepolygon('box_area_projection.kml',[point1(1) point2(1) point3(1) point4(1)],...
     [point1(2),point2(2),point3(2),point4(2)],'CutPolygons',false,'EdgeColor','g','FaceColor','g','FaceAlpha',.5);