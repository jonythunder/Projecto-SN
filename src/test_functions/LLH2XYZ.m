function [xyz] = LLH2XYZ(llh,a,f)
%LLH2XYZ Converts LLH into XYZ for any geoid, using the values of a and f
%   Detailed explanation goes here
%   Units:
%       lat    degrees [-90,90]
%       lon    degrees [-180,180]
%       h      meters


lat(:)=llh(:,1);
lon(:)=llh(:,2);
h(:)=llh(:,3);

    RN = a ./ (sqrt(1 - f .* (2 - f) .* sind(lat).^2));
    xyz(:,1) = (RN + h) .* cosd(lat) .* cosd(lon);
    xyz(:,2) = (RN + h) .* cosd(lat) .* sind(lon);
    xyz(:,3) = ((1-f).^2 .* RN + h) .* sind(lat);
end

