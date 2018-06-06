% Função que recebe o a tabela das ephemerides, a posição do reciever[x,y,z]m, time
% of week (seconds) e week number e devolve a posição do satelite at time of
% transmition in the format [sat_number,x,y,z]m

function sat_pos=calc_sat_pos(eph,r_pos,tow,wn)
S=eph
sat_pos=zeros(32,4);
for Sat=1:32
    week_number_oe = S(Sat,4)+1024;
    t_oe = S(Sat,7);
    SV=S(Sat,1);
    week_number = wn;
    TOW = tow;
    t_calculado = (TOW)-(t_oe)+(week_number-week_number_oe)*604800 
    sqrtA = S(Sat,34);
    A = sqrtA^2;
    e = S(Sat,43);
    omega = S(Sat,46);
    M0 = S(Sat,40);
    delta_angular1 = S(Sat,37);
    OMEGAdot=S(Sat,58);
    OMEGA0 = S(Sat,55);
    Cuc = S(Sat,61);
    Cus = S(Sat,64);
    Cic = S(Sat,73);
    Cis = S(Sat,76);
    Crc = S(Sat,67);
    Crs = S(Sat,70);
    i0 = S(Sat,49);
    IDOT = S(Sat,52);
    [mu,A,e,omega,T,mean_angular1,M,E,true_anom,r0,argument_lat,u,r,i,OMEGA,x,y,z] = Contas_efemerides(A,e,t_oe,t_calculado,omega,M0,delta_angular1,OMEGAdot,OMEGA0,Cuc,Cus,Cic,Cis,Crc,Crs,IDOT,i0);
    fprintf('ex 2 done \nex 3\n');
    t_rc = TOW+(week_number*604800);
    d_linha = 0;
    valid2 = true;
    c = 299792458;
    d_limite = 0.001;
    rka = r_pos;
    count2=0;
    while valid2
        count2=count2+1;
        d=d_linha;
        t_trans = t_rc-(d/c);
        t_Trans = num2str(t_trans-week_number*604800)
        t_calculado = t_trans - (t_oe+(week_number_oe*604800)); 
        [mu,A,e,omega,T,mean_angular1,M,E,true_anom,r0,argument_lat,u,r,i,OMEGA,x2,y2,z2] = Contas_efemerides(A,e,t_oe,t_calculado,omega,M0,delta_angular1,OMEGAdot,OMEGA0,Cuc,Cus,Cic,Cis,Crc,Crs,IDOT,i0);
        deltaOMEGA = 7.292115146*10^-5*(d/c)
        Rotz_neg_deltaOMEGA=[cos(-deltaOMEGA),-sin(-deltaOMEGA),0;sin(-deltaOMEGA),cos(-deltaOMEGA),0;0,0,1];s = Rotz_neg_deltaOMEGA*[x2;y2;z2]
        super = s-rka;
        d_linha = norm(super)
        X_sat=num2str(s(1));
        ddd=abs(d_linha-d)
        if abs(d_linha-d)<d_limite
            valid2 = false;
        end
        fprintf('next\n');
    end
end
sat_pos(Sat)=[SV, super]

end

%% Função auxliar que calcula a posição do satelite baseado nas ephemerides
function [mu,A,e,omega,T,mean_angular1,M,E,true_anom,r0,argument_lat,u,r,i,OMEGA,x,y,z,count] = Contas_efemerides(A,e,t_oe,t_calculado,omega,M0,delta_angular1,OMEGAdot,OMEGA0,Cuc,Cus,Cic,Cis,Crc,Crs,IDOT,i0)
mu = 3.986005*(10^14);



OMEGAdot_e = 7.2921151467*10^-5;
T = 2*pi*sqrt((A^3)/mu);

mean_angular1 = (2*pi)/T+delta_angular1;

M = M0+mean_angular1*(t_calculado);

valid = true;
d_limite = 1*10^(-12);
E = M;
count=0;
while valid
    count = count+1;
    E_linha = E;
    E = M + e*sin(E);
    d=abs(E-E_linha);
    if d<d_limite
        valid = false;
    end
end

true_anom = atan2(sqrt(1-e^2)*sin(E),cos(E)-e);
r0 = A*(1-e*cos(E));

argument_lat = true_anom + omega;

delta_u = Cuc*cos(2*argument_lat)+Cus*sin(2*argument_lat);
u=argument_lat+delta_u;

delta_r=Crc*cos(2*argument_lat)+Crs*sin(2*argument_lat);
r=r0+delta_r

delta_i=Cic*cos(2*argument_lat)+Cis*sin(2*argument_lat);
i=i0+delta_i+IDOT*t_calculado
OMEGA=OMEGA0+(OMEGAdot-OMEGAdot_e)*t_calculado-OMEGAdot_e*t_oe

Rotx_neg_i=[1,0,0;
      0,cos(-i),-sin(-i);
      0,sin(-i),cos(-i)];
  
Rotz_neg_OMEGA=[cos(-OMEGA),-sin(-OMEGA),0;
      sin(-OMEGA),cos(-OMEGA),0;
      0,0,1];


xyz = [r*cos(u), r*sin(u),0]*Rotx_neg_i*Rotz_neg_OMEGA
x=xyz(1);
y=xyz(2);
z=xyz(3);
end

