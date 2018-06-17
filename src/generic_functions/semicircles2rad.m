function [out_rad] = semicircles2rad(in_semicircles)
%SEMICIRCLES2RAD Summary of this function goes here
%   Detailed explanation goes here

    out_rad = deg2rad(in_semicircles .* ( 180 ./ 2^31 ));


end

