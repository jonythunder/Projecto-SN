function [lat_out,lon_out] = NMEAcoords2signdeg(lat,lat_char,lon,lon_char)
%NMEACOORDS2SIGNDEG Summary of this function goes here
%   Detailed explanation goes here

%Place the decimal point right after degrees
lat=lat/100;
lon=lon/100;

%Get only the decimal part (degrees)
lat_deg=floor(lat);
lon_deg=floor(lon);

%Get only the fractional part (minutes), but put the decimal point in the
%right place
lat_min=(lat-lat_deg)*100;
lon_min=(lon-lon_deg)*100;

%convert minutes to degrees
lat_deg_frac=lat_min/60;
lon_deg_frac=lon_min/60;

%Get output in degrees
lat_out=lat_deg+lat_deg_frac;
lon_out=lon_deg+lon_deg_frac;


if lat_char=='S'
    lat_out=-lat_out;
end

if lon_char=='W'
    lon_out=-lon_out;
end

        

end

