lat = [0 1 1 0 0];
lon = [179.5 179.5 -179.5 -179.5 179.5];
h = 5000;
alt = ones(1,length(lat)) * h;
filename = 'cross180.kml';
kmlwritepolygon(filename,lat,lon,alt,'EdgeColor','r','FaceColor','w')


%% Create Polygon with Inner Ring
% 
%%
38.7367861111111;
center_lon=-9.13855833333334;
radius=40;
% Define the latitude and longitude coordinates of the center of the rings.
% For this example, the coordinates specify the Eiffel Tower. 
lat0 = 38.7367861111111;
lon0 = -9.13855833333334;
%%
% Define the inner radius and the outer radius of two small circles. The
% examples calls |poly2ccw| to change the direction of the vertex order of
% the second circle to counter-clockwise. This change of direction is
% needed to define the space between the two circles as a ring-shaped
% polygon.
outerRadius = .0004;
innerRadius = .00;
[lat1,lon1] = scircle1(lat0,lon0,outerRadius);
[lat2,lon2] = scircle1(lat0,lon0,innerRadius);
lat = [lat1; NaN; lat2];
lon = [lon1; NaN; lon2];
alt = 150;
%%
% Specify name of output KML file and write the data to the file.
filename = 'EiffelTower.kml';
kmlwritepolygon(filename,lat,lon, ...
      'EdgeColor','g','FaceColor','c','FaceAlpha',.5)
  
  %%
% Load latitude and longitude data that defines the coastlines of the
% continents.
load coastlines
%%
% Specify the name of output KML file that you want to create.
filename = 'coastlines.kml';
%%
% Write the coastline data to the file as a polygon.
kmlwritepolygon(filename,coastlat,coastlon)


center_lat=38.7367861111111;
center_long=-9.13855833333333;
center_h=129.999999999042;
%radius=area(1).radius;
[latc,longc] = scircle1(center_lat,center_long,40,[],earthRadius('m'));
kmlwritepolygon('circ.kml',latc,longc, ...
      'EdgeColor','g','FaceColor','c','FaceAlpha',.5)


%Test for box area
%[overlap_out_box] = intrusion_detection(input_nmea_test(:,1:3),area(3));
%Use the coordinates used to create the area
point1=[38.7374916666667 -9.13913611111111 120.000000000489];
point2=[38.7374916665995 -9.13901075648354 120.000009299696];
point3=[38.7373821164558 -9.13901075667503 120.000020927243];
point4=[38.737382116523 -9.13913611111111 120.000011626626];
lat_rec = [point1(1) point2(1) point3(1) point4(1)];
long_rec = [point1(2) point2(2) point3(2) point4(2)];
alt_rec = [point1(3) point2(3) point3(3) point4(3)];

kmlwritepolygon('rec.kml',lat_rec,long_rec,'EdgeColor','b','FaceColor','c','FaceAlpha',.5);




center_lat=38.7367861111111;
center_long=-9.13855833333333;
center_h=129.999999999042;
%radius=area(1).radius;
[latcil,longcil] = scircle1(center_lat,center_long,10,[],earthRadius('m'));
kmlwritepolygon('cil.kml',latc,longc, ...
      'EdgeColor','r','FaceColor','r','FaceAlpha',.5)
  
  
%   plotm(latcil,longcil,'m')
%   hold on
%   plotm(latc,longc,'m')
  
%   axesm('mercator','MapLatLimit',[-30 30],'MapLonLimit',[-30 30]);
%   [latc1,longc1] = scircle1(0,0,30,[],earthRadius('m'));
%   [latc2,longc2] = scircle1(0,0,40,[],earthRadius('m'));
%   plotm(latc1,longc1,'g')
%   hold on
%   plotm(latc2,longc2,'r')