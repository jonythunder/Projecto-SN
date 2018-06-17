function [LLH] = XYZ2LLH(xyz,method,a,f)
%XYZ2LLH Summary of this function goes here
%   Detailed explanation goes here
%   The input variable method determines the computation method:
%       'Bowring' uses the Vermeille+Bowring(1976 and 1985)
%       methods for Longitude, Latitude and Altitude respectively
%       'Heikkinen' uses the Heikkinen method ,with Vermeille method for
%       Latitude.
%       'Fukushima' uses the Bowring approximate solution with the
%       Fukushima fast implementation, as well as the Vermeille method for
%       the Latitude

x=xyz(:,1);
y=xyz(:,2);
z=xyz(:,3);

switch method
    case 'Bowring'
        
        norms=sqrt(sum([x,y].^2,2));
        
        %Vermeille method for XY -> Longitude
        if y > eps
            LLH(:,2)=rad2deg((pi/2)-2.*atan(x./(norms+y)));
        else
            LLH(:,2)=rad2deg(-(pi/2)+2.*atan(x./(norms-y)));
        end
        
        
        %Bowring method (1976) for XYZ -> Latitude
        
        b=a*(1-f);
        p=norms;
        e2=1-(b^2)/(a^2);
        e_dash2=(a^2)/(b^2)-1;
        beta=atan2((a.*z),(b*p));
        
        LLH(:,1)=rad2deg(atan2(z+e_dash2*b*(sin(beta).^3),p-e2*a*(cos(beta).^3)));
        
        
        %Bowring method (1985) for XYZ -> Altitude
        RN = a ./ (sqrt(1 - f .* (2 - f) .* sind(LLH(:,1)).^2));
        LLH(:,3)=p.*cosd(LLH(:,1))+z.*sind(LLH(:,1))-(a^2)/RN;
        
        
        
        
    case 'Heikkinen'
        norms=sqrt(sum([x,y].^2,2));
        
        %Vermeille method for XY -> Longitude
        if y > eps
            LLH(:,2)=rad2deg((pi/2)-2.*atan(x./(norms+y)));
        else
            LLH(:,2)=rad2deg(-(pi/2)+2.*atan(x./(norms-y)));
        end
        
        
        %Heikkinen method
        
        b=a*(1-f);
        r=norms;
        e2=1-(b^2)/(a^2);
        e_dash2=(a^2)/(b^2)-1;
        
        F=54*(b^2)*(z.^2);
        G=r.^2 + (1-e2).*z.^2 - e2*(a^2-b^2);
        c=e2^2*F.*r.^2./G.^3;
        s=nthroot((1+c+sqrt(c.^2+2*c)),3);
        P=F./(3.*(s+(1./s)+1).^2.*G.^2);
        Q=sqrt(1+2*e2^2.*P);
        r0=-((P.*e2.*r)./(1+Q))+sqrt(0.5*a^2*(1+Q.^-1)-((P.*(1-e2).*z.^2)/(Q.*(1+Q)))-0.5*P.*r.^2);
        U=sqrt((r-e2.*r0).^2+z.^2);
        V=sqrt((r-e2.*r0).^2+(1-e2).*z.^2);
        z0=(b^2.*z)./(a.*V);
        LLH(:,3)=U.*(1-b.^2./(a.*V));
        LLH(:,1)=atan2d((z+e_dash2.*z0),(r));

        
    case 'Fukushima'
        norms=sqrt(sum([x,y].^2,2));
        
        %Vermeille method for XY -> Longitude
        if y > eps
            LLH(:,2)=rad2deg((pi/2)-2.*atan(x./(norms+y)));
        else
            LLH(:,2)=rad2deg(-(pi/2)+2.*atan(x./(norms-y)));
        end
        
        %Fukushima fast implementation
        p=norms;
        f_dash=1-f;
        z_dash=f_dash.*z;
        b=a*(1-f);
        e2=1-(b^2)/(a^2);
        a_dash=a*e2;
        
        T=z./(f_dash.*p);
        C=1./sqrt(1+T.^2);
        S=C.*T;
        T=(z_dash+a_dash.*S.^3)/(p-a_dash.*C.^3);
        LLH(:,1)=atan2d(T,f_dash);
        
        if p > z
            LLH(:,3)= sqrt(1+(T./f_dash).^2).*(p-a./(sqrt(1+T.^2)));
        else
            LLH(:,3)=sqrt(f_dash.^2+T.^2).*(z./T-b./sqrt(1+T.^2));
        end     
end

end

