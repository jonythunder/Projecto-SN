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
const.RF1 = [4918526.668, -791212.115, 3969767.140];%pos da base station RF2
const.RF2 = [4918533.320, -791212.572, 3969758.451];%pos da esta��o RF6

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


xyz_last = [];
xyz2_last = [];

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
    
    [H] = get_H(pr_filtered(:,2),sat_pos(:,2:4),xyz);
    [H_ENU] = get_H_ENU(xyz,const.a,const.f,H);
    
    %Get DOP matrix
    DOP_matrix=inv(transpose(H)*H);
    DOP_matrix_ENU=inv(transpose(H_ENU)*H_ENU);
    
    %Compute PDOP and HDOP from DOP matrix
    PDOP_1(pr_line)=sqrt(trace(DOP_matrix(1:3,1:3)));
    HDOP_1(pr_line)=sqrt(trace(DOP_matrix_ENU(1:2,1:2)));

    if PDOP_1(pr_line) > 2.5 && pr_line ~=1
        xyz=xyz_last;
    end
    
    
    
    xyz_last = xyz;
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
    
    for k=1:size(pr_filtered2,1)
        for i=1:size(sat_pos,1)
            for j=1:size(pr_filtered,1)
                
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
        not_dif_corected =[];
        m=size(pr_filtered2,1);
        for k=1:m
            if ~ismember(pr_filtered2(k,1),d_sv(:,1))
                not_dif_corected = [not_dif_corected,k];
            end
        end
        
            pr_filtered2(not_dif_corected(:),:)=[];
        
        [xyz2,sat_pos2,~,~]=calc_position(input_hui2,eph_aux2,input_eph2,TOW,WN,pr_filtered2);
        
%         [H] = get_H(pr_filtered2(:,2),sat_pos2(:,2:4),xyz2);
%         [H_ENU] = get_H_ENU(xyz2,const.a,const.f,H);
%         
%         %Get DOP matrix
%         DOP_matrix=inv(transpose(H)*H);
%         DOP_matrix_ENU=inv(transpose(H_ENU)*H_ENU);
%         
%         %Compute PDOP and HDOP from DOP matrix
%         PDOP_2(pr_line)=sqrt(trace(DOP_matrix(1:3,1:3)));
%         HDOP_2(pr_line)=sqrt(trace(DOP_matrix_ENU(1:2,1:2)));
        
%         if PDOP_2(pr_line) > 2.5 && pr_line ~=1
%             xyz2=xyz_last2;
%         end
        
        xyz_last2 = xyz2;
               
        xyz_history2=[xyz_history2;[xyz2(1),xyz2(2),xyz2(3)]];
        error_history2 = [error_history2,norm(const.RF2-xyz2(1:3))];
        TOW2(pr_line)=TOW;
        
end
 
load handel
player = audioplayer(y,Fs);
play(player)



figure
plot(1:size(input_raw,1),error_history)
title("Erro de posição RF1")
figure
plot(1:size(input_raw2,1),error_history2)
title("Erro de posição RF2")

sum1_x=0;
sum1_y=0;
sum1_z=0;
count1=0;
for i=1:size(xyz_history,1)
    
        sum1_x=sum1_x+xyz_history(i,1);
        sum1_y=sum1_y+xyz_history(i,2);
        sum1_z=sum1_z+xyz_history(i,3);
        count1=count1+1;
    
end

sum2_x=0;
sum2_y=0;
sum2_z=0;
count2=0;

for i=1:size(xyz_history2,1)
    
        sum2_x=sum2_x+xyz_history2(i,1);
        sum2_y=sum2_y+xyz_history2(i,2);
        sum2_z=sum2_z+xyz_history2(i,3);
        count2=count2+1;
    
end

avg_xyz1=[sum1_x,sum1_y,sum1_z]./count1;
avg_xyz2=[sum2_x,sum2_y,sum2_z]./count2;

avg_llh_RF1=xyz2llh(avg_xyz1,const.a,const.f);
avg_llh_RF1=[rad2deg(avg_llh_RF1(1)),rad2deg(avg_llh_RF1(2)),avg_llh_RF1(3)];
avg_llh_RF2=xyz2llh(avg_xyz2,const.a,const.f);
avg_llh_RF2=[rad2deg(avg_llh_RF2(1)),rad2deg(avg_llh_RF2(2)),avg_llh_RF2(3)];

fprintf("A posição média para RF1 é:\n");
disp(avg_llh_RF1);

fprintf("A posição média para RF2 é:\n")
disp(avg_llh_RF2);