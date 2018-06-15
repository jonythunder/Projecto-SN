function [troposphere_delay] = troposphere_model(position_xyz,satellite_xyz,time_days)
%TROPOSPHERE_MODEL Computes the troposphere delay
<<<<<<< HEAD
%   Given a receiver's position (in WGS84, [x,y,z]), the day of the year and the satellite positions (in WGS84, , computes
=======
%   Given a receiver's position (in LLH), the day of the year and the satellite positions, computes
>>>>>>> b2a0de2579e75ab43ecc61f5b857423b1ddfb8ac
%   the troposphere delay vector for all the pseudoranges using the model found in RTCA-MOPS, 2006

global const

%Get receiver position in LLH
position_llh=xyz2llh(position_xyz,const.a,const.f);
position_height=position_llh(3)-geoidheight(rad2deg(position_llh(1)),rad2deg(position_llh(1)));


%Get the satellite's elevation
for j=1:size(satellite_xyz,2)
    %Compute the receiver's position in LLH
    satellite_llh=xyz2llh(satellite_xyz(:,j),const.a,const.f);
    
    satellite_ENU = ECEF2ENU((satellite_xyz(:,j)-position_xyz)',rad2deg(satellite_llh(1)),rad2deg(satellite_llh(2)));
    [~,~,gamma_ENU]=get_direction_cosines(satellite_ENU);
    
    el=asind(gamma_ENU);
    
    %Get the obliquity factor
    M=1.001./sqrt(0.002001+sind(el).^2);
    
    P=get_parameter_value(rad2deg(position_llh(1)),time_days,'P');
    T=get_parameter_value(rad2deg(position_llh(1)),time_days,'T');
    e=get_parameter_value(rad2deg(position_llh(1)),time_days,'e');
    beta=get_parameter_value(rad2deg(position_llh(1)),time_days,'beta');
    lambda=get_parameter_value(rad2deg(position_llh(1)),time_days,'lambda');
    
    k1=77.604;
    k2=382000;
    Rd=287.054;
    gm=9.784;
    g=9.80665;
    
    Tz0_dry=(10^(-6)*k1*Rd*P)/gm;
    Tz0_wet=((10^(-6)*k2*Rd)/((lambda+1)*gm-beta*Rd))*(e/T);
    
    Tz_dry=((1-(beta*position_height)/T)^(g/(Rd*beta)))*Tz0_dry;
    Tz_wet=((1-(beta*position_height)/T)^(((lambda+1)*g)/(Rd*beta)-1))*Tz0_wet;
    troposphere_delay(j)=(Tz_dry+Tz_wet)*M;
end


end

function [out]=get_parameter_value(lat,day,parameter)
    [parameter0,parameter_seasonal_var]=get_parameter_value_interpolated(lat,parameter);
    
    if lat>=0
        dmin=28;
    else
        dmin=211;
    end
    
    out=parameter0-parameter_seasonal_var*cos((2*pi()*(day-dmin))/(365.25));
end

function [avg,seasonal_var]=get_parameter_value_interpolated(lat,parameter)
    %Average values
    P_avg=[1013.25 1017.25 1015.75 1011.75 1013.00];
    T_avg=[299.65 294.15 283.15 272.15 263.65];
    e_avg=[26.31 21.79 11.66 6.78 4.11];
    beta_avg=[6.30 6.05 5.58 5.39 4.53]*0.001;
    lambda_avg=[2.77 3.15 2.57 1.81 1.55];

    %Seasonal variation values
    dP=[0.00 -3.75 -2.25 -1.75 -0.50];
    dT=[0.00 7.00 11.00 15.00 14.50];
    de=[0.00 8.85 7.24 5.36 3.39];
    dbeta=[0.00 0.25 0.32 0.81 0.62]*0.001;
    dlambda=[0.00 0.33 0.46 0.74 0.30];

    if strcmp(parameter,"P")
        avg_list=P_avg;
        var_list=dP;
    elseif strcmp(parameter,"T")
        avg_list=T_avg;
        var_list=dT;
    elseif strcmp(parameter,"e")
        avg_list=e_avg;
        var_list=de;
    elseif strcmp(parameter,"beta")
        avg_list=beta_avg;
        var_list=dbeta;
    elseif strcmp(parameter,"lambda")
        avg_list=lambda_avg;
        var_list=dlambda;
    end

    if abs(lat)<=15
        avg=avg_list(1);
        seasonal_var=var_list(1);
    elseif abs(lat) <=30
        avg1=avg_list(1);
        avg2=avg_list(2);
        x1=15;
        x2=30;
        avg=avg1+((avg2-avg1)/(x2-x1))*(abs(lat)-x1);

        var1=var_list(1);
        var2=var_list(2);
        seasonal_var=var1+((var2-var1)/(x2-x1))*(abs(lat)-x1);

    elseif abs(lat) <=45
        avg1=avg_list(2);
        avg2=avg_list(3);
        x1=30;
        x2=45;
        avg=avg1+((avg2-avg1)/(x2-x1))*(abs(lat)-x1);

        var1=var_list(2);
        var2=var_list(3);
        seasonal_var=var1+((var2-var1)/(x2-x1))*(abs(lat)-x1);

    elseif abs(lat) <=60
        avg1=avg_list(3);
        avg2=avg_list(4);
        x1=45;
        x2=60;
        avg=avg1+((avg2-avg1)/(x2-x1))*(abs(lat)-x1);

        var1=var_list(3);
        var2=var_list(4);
        seasonal_var=var1+((var2-var1)/(x2-x1))*(abs(lat)-x1);

    elseif abs(lat) <75
        avg1=avg_list(4);
        avg2=avg_list(5);
        x1=60;
        x2=75;
        avg=avg1+((avg2-avg1)/(x2-x1))*(abs(lat)-x1);

        var1=var_list(4);
        var2=var_list(5);
        seasonal_var=var1+((var2-var1)/(x2-x1))*(abs(lat)-x1);

    elseif abs(lat) >=75
        avg=avg_list(5);
        seasonal_var=var_list(5);
    end
end