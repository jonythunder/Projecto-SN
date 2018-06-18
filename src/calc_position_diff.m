function [xyz,satellites_pos_out]=calc_position_diff(input_hui,eph_aux,input_eph,TOW,WN,pr_filtered)

global const
time_years=(WN*7)/365.25+1980;
time_days=floor((time_years-floor(time_years))*365.25+TOW/(24*3600))+5;

alpha = [input_hui(1,13),input_hui(1,15),input_hui(1,17),input_hui(1,19)];
beta = [input_hui(1,21),input_hui(1,23),input_hui(1,25),input_hui(1,27)];
error_history = [];

%Index all seen satellites
satellites_pos_out = [];
    
    
  
    initial_estimate=[const.RF1,0];
    stop=true;
    
    satellites_pos=[];
    satellites_ttx=[];
    satellites_E=[];
    satellites_e=[];
    eph_masked=[];
    pr_masked=[];
    
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
            
            if el>5
                
                satellites_pos(n,:)=[S'];
                satellites_ttx(n,:)=t_tx;
                satellites_E(n,:)=E;
                satellites_e(n,:)=e;
                eph_masked(n,:)=eph_aux(j,:);
                pr_masked(n,:)=pr_filtered(j,:);
                n=n+1;
            end
            satellites_pos_out=[satellites_pos_out;SV_aux,S'];
            
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
        
        
        if abs(norm(xyz(1:3)'-initial_estimate(1:3)))<10^-3
            break;
        end
        satellites_pos_out = [];
        initial_estimate=xyz';       
    end
 xyz=xyz(1:3)';
end






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