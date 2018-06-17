function [H] = get_H_ENU(initial_estimate,a,f,H)
%GET_H_ENU Summary of this function goes here
%   Detailed explanation goes here

[initial_estimate_llh]=XYZ2LLH(initial_estimate,'Heikkinen',a,f);
    
H_ENU=ECEF2ENU(H,initial_estimate_llh(1),initial_estimate_llh(2));

H=[H_ENU ones(size(H_ENU,1),1)];

end

