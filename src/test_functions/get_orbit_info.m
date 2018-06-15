function [T,n,M,E,r_corrected,true_anomaly,arg_lat_corrected,i_corrected,Omega_corrected]=get_orbit_info(A,dn,M0,e,argP,i0,IDOT,Omega0,OmegaDot,Cuc,Cus,Crc,Crs,Cic,Cis,TOW,WN,toe,WN_Sat)
%GET_ORBIT Summary of this function goes here
%   Detailed explanation goes here

grav_c=3.986005*10^14;

T=2.*pi.*sqrt((A.^3)./(grav_c));

n=2.*pi./T+dn;

TOW=WN*7*24*3600+TOW;
toe_=WN_Sat*7*24*3600+toe;

dt=TOW-toe_;
%M=n*(tcurr-tPer);
M=M0+n.*dt;

%Iterative calculation of the excentric anomaly
E=M;
err=1*10^-12;
E_=E;
E=M+e.*sin(E);
while abs(E-E_)>err
E_=E;
E=M+e.*sin(E);
end

true_anomaly=atan2(sqrt(1-e.^2).*sin(E),cos(E)-e);

arg_lat=true_anomaly+argP;
du=Cuc.*cos(2.*arg_lat)+Cus.*sin(2.*arg_lat);
arg_lat_corrected=arg_lat+du;

r=A.*(1-e.*cos(E));
dr=Crc.*cos(2.*arg_lat)+Crs.*sin(2.*arg_lat);
r_corrected=r+dr;

di=Cic.*cos(2.*arg_lat)+Cis.*sin(2.*arg_lat);
i_corrected=i0+di+IDOT.*dt;

OmegaDotEarth=7.2921151467*10^-5;
Omega_corrected=Omega0+(OmegaDot-OmegaDotEarth).*dt-OmegaDotEarth.*toe;