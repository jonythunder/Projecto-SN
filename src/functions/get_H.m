function [H,z] = get_H(pseudoranges,sat_positions,initial_estimate)
%GET_H Summary of this function goes here
%   Detailed explanation goes here

%sat_positions=transpose(sat_positions);
e0=[];
for j=1:size(sat_positions,1)
    e0=[e0;(sat_positions(j,:)-initial_estimate)/norm(sat_positions(j,:)-initial_estimate)];
end

H=[-e0];
H=[H ones(size(H,1),1)];

z=[];
for j=1:size(H,1)
    z_aux=pseudoranges(j)-e0(j,:)*transpose(sat_positions(j,:));
    z=[z;z_aux];
end
end

