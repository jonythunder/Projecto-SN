function [UTC,Lat1,Lat2,Lat_deg,Lon1,Lon2,Lon_deg,Quality,NSats,HDOP,h_msl,h_msl_unit,h_wgs84,h_wgs84_unit,age,DGPS_station,checksum] = parse_GGA(input)
%PARSE_GGA Summary of this function goes here
%   Detailed explanation goes here

parsed_input=split(input,[",","*"]);


%Converts every parsed entry from cell to strings or doubles
% UTC = str2double(UTC{1});
% Lat1 = str2double(Lat1{1});
% Lat2 = Lat2{1};
% Lon1 = str2double(Lon1{1});
% Lon2 = Lon2{1};
% Quality = Quality{1};
% NSats = NSats{1};
% HDOP = str2double(HDOP{1});
% h_msl = str2double(h_msl{1});
% h_msl_unit = h_msl_unit{1};
% h_wgs84 = str2double(h_wgs84{1});
% h_wgs84_unit = h_wgs84_unit{1};
% age = str2double(age{1});
% DGPS_station = DGPS_station{1};
% checksum = str2double(checksum{1});



UTC = str2double(parsed_input{2});
Lat1 = str2double(parsed_input{3});
Lat2 = parsed_input{4};
Lon1 = str2double(parsed_input{5});
Lon2 = parsed_input{6};
Quality = str2double(parsed_input{7});
NSats = str2double(parsed_input{8});
HDOP = str2double(parsed_input{9});
h_msl = str2double(parsed_input{10});
h_msl_unit = parsed_input{11};
h_wgs84 = str2double(parsed_input{12});
h_wgs84_unit = parsed_input{13};
age = str2double(parsed_input{14});
DGPS_station = parsed_input{15};
checksum = parsed_input{16};

[Lat_deg,Lon_deg] = NMEAcoords2signdeg(Lat1,Lat2,Lon1,Lon2);

end

