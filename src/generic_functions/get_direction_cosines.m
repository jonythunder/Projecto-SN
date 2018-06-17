function [alpha,beta,gamma] = get_direction_cosines(XYZ)
%GET_DIRECTION_COSINES Summary of this function goes here
%   Detailed explanation goes here

norm_XYZ=norm(XYZ);

alpha=XYZ(1)/norm_XYZ;

beta=XYZ(2)/norm_XYZ;

gamma=XYZ(3)/norm_XYZ;


end

