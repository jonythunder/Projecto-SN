function [SV,WN,toe,SV_Health,A,dn,M0,e,argP,i0,IDOT,Omega0,OmegaDot,Cuc,Cus,Crc,Crs,Cic,Cis,AODO] = parse_ephemeris(input)
%PARSE_EPHEMERIS Summary of this function goes here
%   Detailed explanation goes here

SV=input(:,1);
WN=input(:,4)+1024; %Já fez rollover
toe=input(:,7);
SV_Health=input(:,10);
A=input(:,34).^2;
dn=input(:,37);
M0=input(:,40);
e=input(:,43);
argP=input(:,46);
i0=input(:,49);
IDOT=input(:,52);
Omega0=input(:,55);
OmegaDot=input(:,58);
Cuc=input(:,61);
Cus=input(:,64);
Crc=input(:,67);
Crs=input(:,70);
Cic=input(:,73);
Cis=input(:,76);
AODO=input(:,79);
end

