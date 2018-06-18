clear;
clc;global const
format longg
const.a = 6378137;
const.f = 1/298.257223563;
const.c = 299792458;
const.F = - 4.442807633*(10^(-10));
const.mu_e = 3.986005e+14;
const.Omegadot_e = 7.2921151467e-5;
addpath('./test_functions/');
addpath('./generic_functions/');
warning('off','backtrace');
const.RF1 = [4918528.02 -791210.72 3969759.39];%pos da base station
const.RF2 = [4918525.18 -791212.21 3969762.19];

input_raw = load('test_data/ub1.ubx.1744.327600.raw');
input_eph = load('test_data/ub1.ubx.1744.327600.eph');
input_hui = load('test_data/ub1.ubx.1744.327600.hui');
input_raw2 = load('test_data/ub2.ubx.1744.327600.raw');
input_eph2 = load('test_data/ub2.ubx.1744.327600.eph');
input_hui2 = load('test_data/ub2.ubx.1744.327600.hui');

%%

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

SVN_seen2=[];
n2=1;
for i=1:size(input_eph2,1)
    %Exclude repeated satellites and satellites with bad Health indicators
    %(column 10 ~= 0)
    if input_eph2(i,10)==0
        if ~ismember(input_eph2(i,1),SVN_seen2)
            SVN_seen2=[SVN_seen2,input_eph2(i,1)];
            eph2(n2,:)=input_eph2(i,:);
            n2=n2+1;
        end
    end
end

pr_raw = zeros(50,2); pr_filtered = []; pr_line = [];

history_size_eph_aux = [];
history_size_eph_masked = [];
history_size_pr_masked = [];
history_eph_masked = zeros(size(input_raw,1),8);
history_pr_masked = zeros(size(input_raw,1),8);
error_history = [];
error_history2 = [];
clock_bias_history=[];




xyz_history=[];
xyz_history2=[];

llh_history=[];
pr_history=[];
flag=0;
for n=1:size(input_raw,1)
    for m=1:size(input_raw2,1)
        if abs(input_raw(n,1)-input_raw2(m,1))<200 && n>m
            input_raw(1:n,:)=[];
            flag=1;
            break;
        elseif abs(input_raw(n,1)-input_raw2(m,1))<200 && n<m
            input_raw2(1:m,:)=[];
            flag=1;
            break;
        end
    end
    if flag==1
        break;
    end
end

if size(input_raw,1) > size(input_raw2,1)
    input_raw = input_raw(1:size(input_raw2,1),:);
elseif size(input_raw,1) < size(input_raw2,1)
    input_raw2 = input_raw2(1:size(input_raw,1),:);
end




for pr_line=1:size(input_raw,1)
    TOW=input_raw(pr_line,1)/1000;
    WN=input_raw(pr_line,2);
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
        for n=1:size(eph,1)
            for j=1:size(eph,1)
                if pr_line==464
                    pr_line=464;
                end
                if eph(j,1)==SVN && eph(n,1)==SVN && j~=n
                    if (TOW+WN*604800)-(eph(j,4)+eph(j,6)*604800) < (TOW+WN*604800)-(eph(n,4)+eph(n,6)*604800)
                        eph_aux=[eph_aux;eph(j,:)];
                    else
                        eph_aux=[eph_aux;eph(n,:)];
                    end
                elseif eph(j,1)==SVN && eph(n,1)==SVN && j==n
                    eph_aux=[eph_aux;eph(j,:)];
                end
            end
        end
    end
    
    
    base_pos = 0;
    [xyz,sat_pos,clock_bias,d_sv]=calc_position(input_hui,eph_aux,input_eph,TOW,WN,pr_filtered);
    xyz_history=[xyz_history;[xyz(1),xyz(2),xyz(3)]];
    error_history = [error_history,norm(const.RF1-xyz(1:3))];
    clock_bias_history=[clock_bias_history,clock_bias];
    TOW1(pr_line)=TOW;
    
    
    TOW=input_raw2(pr_line,1)/1000;
    WN=input_raw2(pr_line,2);
    pr_raw2 = zeros(50,2); pr_filtered2 = [];
    for aux = 1:50
        pr_raw2(aux,:) = [input_raw2(pr_line,(aux - 1)*10 + 4) input_raw2(pr_line,(aux - 1)*10 + 11)];
        if (pr_raw2(aux,1) > 0) && (pr_raw2(aux,1) <= 32)
            pr_filtered2 = [pr_filtered2; pr_raw2(aux,:)];
        end
    end
    %Use auxiliary ephemerides for the satellites whose SVN is in the
    %pseudoranges variable
    eph_aux2=[];
    for i=1:size(pr_filtered2,1)
        SVN2=pr_filtered2(i,1);
        for n=1:size(eph2,1)
            for j=1:size(eph2,1)
                if pr_line==464
                    pr_line=464;
                end
                if eph2(j,1)==SVN2 && eph2(n,1)==SVN2 && j~=n
                    if (TOW+WN*604800)-(eph2(j,4)+eph2(j,6)*604800) < (TOW+WN*604800)-(eph2(n,4)+eph2(n,6)*604800)
                        eph_aux2=[eph_aux2;eph2(j,:)];
                    else
                        eph_aux2=[eph_aux2;eph2(n,:)];
                    end
                elseif eph2(j,1)==SVN2 && eph2(n,1)==SVN2 && j==n
                    eph_aux2=[eph_aux2;eph2(j,:)];
                end
            end
        end
    end
    
    
    
    
    
    
    [~,~,clock_bias2,~]=calc_position(input_hui2,eph_aux2,input_eph2,TOW,WN,pr_filtered2);
    
    for i=1:size(sat_pos,1)
        for j=1:size(pr_filtered,1)
            for k=1:size(pr_filtered2,1)
                for l=1:size(d_sv,1)
                    if sat_pos(i,1)==pr_filtered(j,1) && sat_pos(i,1) == pr_filtered2(k,1) && sat_pos(i,1)== d_sv(l,1)
                        r=norm(const.RF1-sat_pos(i,2:4));
                        satellites_prerror=r-pr_filtered(j,2);
                        CF=satellites_prerror+(clock_bias2-clock_bias)-d_sv(l,2);
                        pr_filtered2(k,2)=pr_filtered2(k,2)+CF;
                    end
                    
                end
            end
        end
    end 
        
        [xyz2,sat_pos2,~,~]=calc_position(input_hui2,eph_aux2,input_eph2,TOW,WN,pr_filtered2);
        xyz_history2=[xyz_history2;[xyz2(1),xyz2(2),xyz2(3)]];
        error_history2 = [error_history2,norm(const.RF2-xyz2(1:3))];
        TOW2(pr_line)=TOW;
        
end
 
load handel
player = audioplayer(y,Fs);
play(player)
plot(1:size(input_raw,1),error_history)
hold on
plot(1:size(input_raw2,1),error_history2)
%plot(1:size(input_raw,1),error_history)
% 
% 
% [xyz_history2]=calc_position(input_hui2,input_raw2,input_eph2,xyz_history);
% 
% 
%  
% 
