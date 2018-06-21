lat = [0 1 1 0 0];
lon = [179.5 179.5 -179.5 -179.5 179.5];
h = 5000;
alt = ones(1,length(lat)) * h;
filename = 'cross180.kml';
kmlwritepolygon(filename,lat,lon,alt,'EdgeColor','r','FaceColor','w')


%% Create Polygon with Inner Ring
% 
%%
% Define the latitude and longitude coordinates of the center of the rings.
% For this example, the coordinates specify the Eiffel Tower. 
lat0 = 48.858288;
lon0 = 2.294548;
%%
% Define the inner radius and the outer radius of two small circles. The
% examples calls |poly2ccw| to change the direction of the vertex order of
% the second circle to counter-clockwise. This change of direction is
% needed to define the space between the two circles as a ring-shaped
% polygon.
outerRadius = .02;
innerRadius = .00;
[lat1,lon1] = scircle1(lat0,lon0,outerRadius);
[lat2,lon2] = scircle1(lat0,lon0,innerRadius);
lat = [lat1; NaN; lat2];
lon = [lon1; NaN; lon2];
alt = 500;
%%
% Specify name of output KML file and write the data to the file.
filename = 'EiffelTower.kml';
kmlwritepolygon(filename,lat,lon,alt, ...
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