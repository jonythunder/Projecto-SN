function [XYZ] = get_sat_XYZ(r,u,i,Omega)
%GET_SAT_XYZ Computes the position of the satellite at t_rx
%   Detailed explanation goes here

ROTx=[1 0 0;
      0 cos(-i) -sin(-i);
      0 sin(-i) cos(-i)];
  
  
ROTz=[cos(-Omega) -sin(-Omega) 0;
      sin(-Omega) cos(-Omega) 0;
      0 0 1];
  
XYZ=[r.*cos(u) r.*sin(u) 0]*ROTx*ROTz;


end

