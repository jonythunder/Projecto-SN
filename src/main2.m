clear;
clc;
global const
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

input_raw = load('test_data/ub1.ubx.1744.327600.raw');
input_eph = load('test_data/ub1.ubx.1744.327600.eph');
input_hui = load('test_data/ub1.ubx.1744.327600.hui');

base_pos = 0;

[xyz_history]=calc_position(input_hui,input_raw,input_eph,base_pos);



input_raw2 = load('test_data/ub2.ubx.1744.327600.raw');
input_eph2 = load('test_data/ub2.ubx.1744.327600.eph');
input_hui2 = load('test_data/ub2.ubx.1744.327600.hui');


[xyz_history2]=calc_position(input_hui2,input_raw2,input_eph2,xyz_history);


 

