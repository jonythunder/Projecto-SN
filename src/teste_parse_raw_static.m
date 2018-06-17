format longg
clear
clc
tic
filename='test_data/ub1.ubx.1744.327600';
fid=fopen(filename,'r');

data=fread(fid);
%data=data{1};%Convert from 1x1 cell into cell array
data_hex=dec2hex(data);

input_raw = load('test_data/ub1.ubx.1744.327600.raw');
input_raw = input_raw(1:17032,:); % File has duplicated data
input_eph = load('test_data/ub1.ubx.1744.327600.eph');
input_eph = input_eph(1:19,:); % File has duplicated data
input_hui = load('test_data/ub1.ubx.1744.327600.hui');
input_hui = input_hui(1,:); % File has duplicated data

[raw,eph,hui] = parse_raw(data_hex);

raw_double=double(raw);

eph_double=double(eph);

hui_double=double(hui);

values_to_check_eph=[1,2,3,4,7,10,11,14,15,18,19,22,25,28,31,34,37,40,43,36,39,52,55,58,61,64,67,70,73,76,79];
values_to_check_raw=[1,2,3,4,5,6,7,9,11,13];
values_to_check_hui=[1,3,5,6,7,8,9,10,11,13,15,17,19,21,24,25,27];
for N=2:50
    values_to_check_raw=[values_to_check_raw,4+10*(N-1),5+10*(N-1),6+10*(N-1),7+10*(N-1),9+10*(N-1),11+10*(N-1),13+10*(N-1)];
end

% %Check if same output
for i=1:size(input_raw,1)
    for index=1:size(values_to_check_raw,2)
            if input_raw(i,values_to_check_raw(index)) ~= raw_double(i,values_to_check_raw(index))
                fprintf("Erro em Raw, linha %d, coluna %d\n",i,values_to_check_raw(index));
            end
    end
end

%Check if same output
for i=1:size(input_eph,1)
    for index=1:size(values_to_check_eph,2)
            if input_eph(i,values_to_check_eph(index)) ~= eph_double(i,values_to_check_eph(index))
                fprintf("Erro em EPH, linha %d, coluna %d\n",i,values_to_check_eph(index));
            end
    end
end

%Check if same output
for i=1:size(input_hui,1)
    for index=1:size(values_to_check_hui,2)
            if input_eph(i,values_to_check_eph(index)) ~= eph_double(i,values_to_check_eph(index))
                fprintf("Erro em EPH, linha %d, coluna %d\n",i,values_to_check_eph(index));
            end
    end
end
        
toc