function [ionosphere_delay] = ionosphere_model(alpha,beta,position_xyz,satellite_xyz,gps_time)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global const

%Get receiver position in LLH
position_llh=xyz2llh(position_xyz,const.a,const.f);
%position_height=position_llh(3)-geoidheight(rad2deg(position_llh(1)),rad2deg(position_llh(1)));


    %Get the satellite's elevation
    for j=1:size(satellite_xyz,2)
        %Compute the receiver's position in LLH
        satellite_llh=xyz2llh(satellite_xyz(:,j),const.a,const.f);

        satellite_ENU = ECEF2ENU((satellite_xyz(:,j)-position_xyz)',rad2deg(satellite_llh(1)),rad2deg(satellite_llh(2)));
        [alpha_ENU,beta_ENU,gamma_ENU]=get_direction_cosines(satellite_ENU);

        az=atan2d(alpha_ENU,beta_ENU);
        el=asind(gamma_ENU);
        
        psi=(0.0137/(el+0.11))-0.022;
        
        phi_i=position_llh(1)+psi*cos(az);
        if phi_i > +0.416
            phi_i = 0.416;
        elseif phi_i < -0.416
            phi_i=-0.416;
        end
        
        lambda_i=position_llh(2)+(psi*sin(az))/cos(phi_i);
        
        t=(4.32*10^4)*lambda_i+gps_time;
        if t>=86400
            t=t-86400;
        elseif t<0
            t=t+86400;
        end
        
        phi_m=phi_i+0.064*cos(lambda_i-1.617);
        
        F=1+16*(0.53-el)^3;
        
        PER=beta(0)+beta(1)*phi_m+beta(2)*phi_m^2+beta(3)*phi_m^3;
        if PER < 72000
            PER=72000;
        end
        
        x=(2*pi*(t-50400))/PER;
        
        AMP=alpha(0)+alpha(1)*phi_m+alpha(2)*phi_m^2+alpha(3)*phi_m^3;
        if AMP<0
            AMP=0;
        end
        
        if abs(x)<1.57
            delay=F*(5*10^(-9)+AMP(1-((x^2)/2)+((x^4)/24)));
        else
            delay=F*5*10^(-9);
        end
        
        ionosphere_delay(j)=delay;
    end
end

