format longg
clear
clc
tic
filename='test_data/ub1.ubx.1744.327600';
fid=fopen(filename,'r');

data=fread(fid);
%data=data{1};%Convert from 1x1 cell into cell array
data_hex=dec2hex(data);

[raw,eph,~] = parse_raw(data_hex);

toc