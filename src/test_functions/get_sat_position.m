function [S,t_tx,E,count] = get_sat_position(t_rx,R,A,dn,M0,e,argP,i0,IDOT,Omega0,OmegaDot,Cuc,Cus,Crc,Crs,Cic,Cis,toe,WN_Sat,TOW,WN)
%UNTITLED Computes the position of the satellite at t_tx
%   Detailed explanation goes here

%1mm precision
precision=1*10^-6;

%Speed of light
c=299792458;

%Earth rotation rate
OmegaDotEarth=7.2921151467*10^-5;


%convert R to a column vector
R=transpose(R);

d_=0;
stop=0;
count=0;
while stop ~=1
    d=d_;
    t_tx=t_rx-d/c;
    [~,~,~,E,r_corrected,~,arg_lat_corrected,i_corrected,Omega_corrected]=get_orbit_info(A,dn,M0,e,argP,i0,IDOT,Omega0,OmegaDot,Cuc,Cus,Crc,Crs,Cic,Cis,t_tx,WN,toe,WN_Sat);
    S=get_sat_XYZ(r_corrected,arg_lat_corrected,i_corrected,Omega_corrected);
    
    dOmega=OmegaDotEarth*d/c;
    
    ROTz=[cos(-dOmega) -sin(-dOmega) 0;
      sin(-dOmega) cos(-dOmega) 0;
      0 0 1];
  
  
    S=ROTz*transpose(S);
    d_=norm(S-R);
    count=count+1;
    if (abs(d_-d))<precision
        stop=1;
    end
end

end

