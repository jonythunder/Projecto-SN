function [out_semicircles] = rad2semicircles(in_rad)
%RAD2SEMICIRCLES Summary of this function goes here
%   Detailed explanation goes here
    
    out_semicircles= rad2deg(in_rad) .* ( 2^31 ./ 180 );


end



