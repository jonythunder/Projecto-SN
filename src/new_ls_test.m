%A new test for the least squares method.

%Implementation pseudocode (taken from
%http://www.telesens.co/2017/07/17/calculating-position-from-raw-gps-data/)
% Input: Raw pseudoranges, satellite ephemeris information
%  
% Output: User position in ECEF and user clock bias
%  
% Initialize user clock bias = 0, user position = [0 0 0] (amazing that this works!)
%  
% For each satellite:
%  
% 	1. Calculate satellite clock bias
% 	2. Correct measured pseudorange by the calculated satellite clock bias
% 	3. Apply ionospheric and tropospheric corrections if available
%  
% End For
%  
% Do until change in user clock bias, user position < threshold
%  
% 	For each satellite:
%  
% 		1. Correct pseudorange by current estimate of the user clock bias
% 		2. Calculate signal transmission time tau by dividing pseudorange by speed of light
% 		3. Calculate satellite position at t-tau
% 		4. Rotate satellite position by earth's rotation in time tau to align with user's ECEF frame at time t
% 		5. Form G matrix by concatenating unit vectors from the user to the satellite
% 		6. Calculate delta pseudoranges by taking the difference between the corrected pesudorange (step 1) and expected pseudorange, given the current estimate of the user's position and user clock bias
% 	
% 	End For
%  
% 	Solve for corrections in user position and clock bias and calculate new user position and clock bias
%  
% End Do


%% Initialization

clear;
clc;
global const

const.a = 6378137;
const.f = 1/298.257223563;
const.c = 299792458;

addpath('./generic_functions/');
warning('off','backtrace');

initial_estimate=[0,0,0];


%% Replacement for function Input values
%Index all seen satellites
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

pr_raw = zeros(50,2); pr_filtered = []; pr_line = 13;

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
    for j=1:size(eph,1)
        if eph(j,1)==SVN
            eph_aux=[eph_aux;eph(j,:)];
        end
    end
end


%% Proper code















function [t_poly]=caculate_clock_polynomial(t_tx,input_eph)

    global const
    
    tr =(const.F*(e^(input_eph(aux,34)))*sin(E))*const.c;
    tgd = input_eph(aux,18)*const.c;
    t_poly_seconds = input_eph(aux,31)+input_eph(aux,28)*(t_tx-input_eph(aux,22))+ input_eph(aux,25)*(t_tx-input_eph(aux,22)).^2;

    t_poly=t_poly_seconds*const.c;
        



end