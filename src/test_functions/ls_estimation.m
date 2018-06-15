function [position_estimate,sat_positions,niter_LS] = ls_estimation(pseudoranges,sat_positions,initial_estimate)
%LS_ESTIMATION Summary of this function goes here
%   Detailed explanation goes here

stop=true;
precision=10^-3;  
niter_LS=0;

while stop
    
pseudoranges=pseudoranges+initial_estimate(4);

[H,z]=get_H(pseudoranges,sat_positions,initial_estimate(1:3));
position_estimate=(transpose(H)*H)\transpose(H)*z;

if abs(transpose(position_estimate(1:3))-initial_estimate(1:3))<precision
    stop=false;
end
niter_LS=niter_LS+1;
initial_estimate=transpose(position_estimate);

end

end


