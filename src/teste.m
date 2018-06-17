%Test file only
clear;
clc;
global const

const.a = 6378137;
const.f = 1/298.257223563;
const.c = 299792458;
const.F = - 4.442807633*(10^(-10));
const.mu_e = 3.986005e+14;
const.Omegadot_e = 7.2921151467e-5;

addpath('./generic_functions/');
warning('off','backtrace');

RF1 = [4918528.02 -791210.72 3969759.39];

WN = 1744;
%TOW = 327796;
TOW=(327839601/1000);





% satellites_prerror = gs_error;

fin = fopen('test_data/teste2.nmea'); % -- load input NMEA data
if fin == -1
    disp('Erro no ficheiro');
    return;
end

% Parse the NMEA data and get a vector of (Lat,Lon,Height,time) points
[input_nmea_test] = parse_NMEA(fin);

input_raw = load('test_data/ub1.ubx.1744.327600.raw');
input_raw = input_raw(1:17032,:); % File has duplicated data
input_eph = load('test_data/ub1.ubx.1744.327600.eph');
input_eph = input_eph(1:38,:); % File has duplicated data
input_hui = load('test_data/ub1.ubx.1744.327600.hui');
input_hui = input_hui(1,:); % File has duplicated data

alpha = [input_hui(1,13),input_hui(1,15),input_hui(1,17),input_hui(1,19)];
beta = [input_hui(1,21),input_hui(1,23),input_hui(1,25),input_hui(1,27)];


%Index all seen satellites
SVN_seen=[];
n=1;
for i=1:size(input_eph,1)
    %Exclude repeated satellites and satellites with bad Health indicators
    %(column 10 ~= 0)
    if input_eph(i,10)==0
      if ~ismember(input_eph(i,1),SVN_seen)
          SVN_seen=[SVN_seen,input_eph(i,1)];
          eph(n,:)=input_eph(i,:);
          n=n+1;
      end
   end
end

pr_raw = zeros(50,2); pr_filtered = []; pr_line = 18;

xyz_history=[];
llh_history=[];
pr_history=[];

for pr_line=1:5:size(input_raw,1)
    
TOW=input_raw(pr_line,1)/1000;
WN=input_raw(pr_line,2);
    
time_years=(WN*7)/365.25+1980;
time_days=floor((time_years-floor(time_years))*365.25+TOW/(24*3600))+5;


pr_raw = zeros(50,2); pr_filtered = [];

for aux = 1:50
	pr_raw(aux,:) = [input_raw(pr_line,(aux - 1)*10 + 4) input_raw(pr_line,(aux - 1)*10 + 11)];
	if (pr_raw(aux,1) > 0) && (pr_raw(aux,1) <= 32)
		pr_filtered = [pr_filtered; pr_raw(aux,:)];
	end
end

%Use auxiliary ephemerides for the satellites whose SVN is in the
%pseudoranges variable
eph_aux=[];
for i=1:size(pr_filtered,1)
    SVN=pr_filtered(i,1);
    for j=1:size(eph,1)
        if eph(j,1)==SVN
            eph_aux=[eph_aux;eph(j,:)];
        end
    end
end

%satellites_pos = satellite_positions(eph_aux,WN,TOW,RF1');

% %Using data from the exercises
% input=load('eph.eph');
% pseudoranges=load('npr.txt');
% TOW=213984;
% WN=1693;
% 
% nsats=size(input,1);
% t=TOW;
% for j=1:nsats
%         [SV_aux,WN_Sat,toe,SV_Health,A,dn,M0,e,argP,i0,IDOT,Omega0,OmegaDot,Cuc,Cus,Crc,Crs,Cic,Cis,AODO] = parse_ephemeris(input(j,:));
%         [S,niter] = get_sat_position(t,RF1,A,dn,M0,e,argP,i0,IDOT,Omega0,OmegaDot,Cuc,Cus,Crc,Crs,Cic,Cis,toe,WN_Sat,TOW,WN);
%         satellites_pos(j,:)=S';
% end
% 
% [xyz,niter_LS]=ls_estimation(pseudoranges(:,1),satellites_pos(:,1:3),RF1);
initial_estimate=[RF1,0];
stop=true;

while stop
    nsats=size(eph_aux,1);
    t=TOW;
    n=1;
    for j=1:nsats
        [SV_aux,WN_Sat,toe,SV_Health,A,dn,M0,e,argP,i0,IDOT,Omega0,OmegaDot,Cuc,Cus,Crc,Crs,Cic,Cis,AODO] = parse_ephemeris(eph_aux(j,:));
        [S,t_tx,E,niter] = get_sat_position(t,initial_estimate(1:3),A,dn,M0,e,argP,i0,IDOT,Omega0,OmegaDot,Cuc,Cus,Crc,Crs,Cic,Cis,toe,WN_Sat,TOW,WN);
        
        initial_estimate_llh=xyz2llh(initial_estimate(1:3),const.a,const.f);
        [ENU] = ECEF2ENU(S-initial_estimate,initial_estimate_llh(1),initial_estimate_llh(2));
        [alpha_ENU,beta_ENU,gamma_ENU]=get_direction_cosines(ENU);
        
        az=atan2d(alpha_ENU,beta_ENU);
        el=asind(gamma_ENU);
        
        if el>10
            satellites_pos(n,:)=S';
            satellites_ttx(n,:)=t_tx;
            satellites_E(n,:)=E;
            satellites_e(n,:)=e;
            eph_masked(n,:)=eph_aux(j,:);
            pr_masked(n,:)=pr_filtered(j,:);
            n=n+1;
        end
        
        
    end
    d_sv=calculate_clock_bias(satellites_ttx,eph_masked,satellites_e,satellites_E);
    %d_sv=calculate_clock_bias(satellites_ttx,eph_aux,satellites_e,satellites_E);
    
    pr_corrected=pr_masked;
    %pr_corrected=pr_filtered;
    pr_corrected(:,2)=pr_corrected(:,2)+d_sv';
    
    [xyz,satellites_pos,niter_LS]=ls_estimation(pr_corrected(:,2),satellites_pos(:,1:3),initial_estimate);
    
    
    
    tropospheric_delay=troposphere_model(xyz(1:3),satellites_pos(:,1:3)',time_days); %in meters
    ionospheric_delay=ionosphere_model(alpha,beta,xyz(1:3),satellites_pos(:,1:3)',satellites_ttx);
    
    pr_corrected(:,2)=pr_corrected(:,2)+tropospheric_delay'+ionospheric_delay'.*const.c;
    
    
    if abs(norm(xyz(1:3)'-initial_estimate(1:3)))
        stop=false;
    end
    
    initial_estimate=xyz';
    
    if pr_line==7771
        pr_line=7771;
    end
    
    pr_last=pr_masked;
    
end

[H] = get_H(pr_corrected,satellites_pos,xyz(1:3)');
[H_ENU] = get_H_ENU(xyz(1:3)',const.a,const.f,H);

%Get DOP matrix
DOP_matrix=inv(transpose(H)*H);
DOP_matrix_ENU=inv(transpose(H_ENU)*H_ENU);

%Compute PDOP and HDOP from DOP matrix
PDOP(pr_line)=sqrt(trace(DOP_matrix(1:3,1:3)));
HDOP(pr_line)=sqrt(trace(DOP_matrix_ENU(1:2,1:2)));


llh_out=xyz2llh(xyz(1:3),const.a,const.f);
llh_out(1:2)=rad2deg(llh_out(1:2));
xyz_history=[xyz_history;xyz(1:3)'];
llh_history=[llh_history;llh_out];

end

figure
plot(1:5:pr_line,llh_history(:,1))
title('latitude history')
figure
plot(1:5:pr_line,llh_history(:,2))
title('longitude history')
figure
plot(1:5:pr_line,llh_history(:,3))
title('altitude history')
figure
plot(1:5:pr_line,xyz_history(:,1))
title('X history')
figure
plot(1:5:pr_line,xyz_history(:,2))
title('Y history')
figure
plot(1:5:pr_line,xyz_history(:,3))
title('Z history')



function [d_sv]=calculate_clock_bias(t_tx,input_eph,e,E)

    global const
    
    for aux=1:size(input_eph,1)
        
        tr(aux) =(const.F*(e(aux)^(input_eph(aux,34)))*sin(E(aux)))*const.c;
        tgd(aux) = input_eph(aux,18)*const.c;
        t_poly_seconds(aux) = input_eph(aux,31)+input_eph(aux,28).*(t_tx(aux)-input_eph(aux,22))+ input_eph(aux,25).*(t_tx(aux)-input_eph(aux,22)).^2;
        
        t_poly(aux)=t_poly_seconds(aux).*const.c;
    end
    
    d_sv=tr-tgd+t_poly;
end