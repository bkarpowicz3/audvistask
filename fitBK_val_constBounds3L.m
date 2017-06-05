function [ps_, rts_] = fitBK_val_constBounds3L(cohs, params, lapse)
% cohs are 0 ... 1. 
%   Assumes values are signed: 
%       + for stim corresponding to correct "A" choices
%       - for stim corresponding to correct "B" choices
%
% 5 parameters:
%   1   ... k    = drift rate 
%   2   ... A    = A bound -> CONSTANT
%   3   ... B    = B bound -> CONSTANT
%   4   ... Andt = non-decision time for A choices in msec
%   5   ... Bndt = non-decision time for B choices in msec
%
% lapse is optional

%separate parameters
params1 = params(1:5);
params2 = params([6 2 3 7 8]);
params3 = params([9 2 3 10 11]);
params4 = params([12 2 3 13 14]);
params5 = params([15 2 3 16 17]);

%drift rates
mu1 = (params1(1)/100000) .* cohs;
mu2 = (params2(1)/100000) .* cohs;
mu3 = (params3(1)/100000) .* cohs;
mu4 = (params4(1)/100000) .* cohs;
mu5 = (params5(1)/100000) .* cohs;

%scale bounds
A = params(2)/10;
B = params(3)/10;

% scale NTD
Andt1 = params1(4);
Bndt1 = params1(5);
Andt2 = params2(4);
Bndt2 = params2(5);
Andt3 = params3(4);
Bndt3 = params3(5);
Andt4 = params4(4);
Bndt4 = params4(5);
Andt5 = params5(4);
Bndt5 = params5(5);

% PMF
eA1 = exp(2 .* mu1 .* A);
eB1 = exp(2 .* mu1 .* B);
ps_1 = (eB1 .* eA1 - eA1) ./ (eB1 .* eA1 - 1);
ps_1(abs(cohs)<=eps) = B ./ (A + B);

eA2 = exp(2 .* mu2 .* A);
eB2 = exp(2 .* mu2 .* B);
ps_2 = (eB2 .* eA2 - eA2) ./ (eB2 .* eA2 - 1);
ps_2(abs(cohs)<=eps) = B ./ (A + B);

eA3 = exp(2 .* mu3 .* A);
eB3 = exp(2 .* mu3 .* B);
ps_3 = (eB3 .* eA3 - eA3) ./ (eB3 .* eA3 - 1);
ps_3(abs(cohs)<=eps) = B ./ (A + B);

eA4 = exp(2 .* mu4 .* A);
eB4 = exp(2 .* mu4 .* B);
ps_4 = (eB4 .* eA4 - eA4) ./ (eB4 .* eA4 - 1);
ps_4(abs(cohs)<=eps) = B ./ (A + B);

eA5 = exp(2 .* mu5 .* A);
eB5 = exp(2 .* mu5 .* B);
ps_5 = (eB5 .* eA5 - eA5) ./ (eB5 .* eA5 - 1);
ps_5(abs(cohs)<=eps) = B ./ (A + B);

% if lapse given
if nargin > 2
    ps_1 = lapse(1) + (1-2.*lapse(1)).*ps_1;
    ps_2 = lapse(2) + (1-2.*lapse(2)).*ps_2;
    ps_3 = lapse(3) + (1-2.*lapse(3)).*ps_3;
    ps_4 = lapse(4) + (1-2.*lapse(4)).*ps_4;
    ps_5 = lapse(5) + (1-2.*lapse(5)).*ps_5;
end

% CMF
rts_1 = NaN(size(cohs,1),1);
rts_2 = NaN(size(cohs,1),1);
rts_3 = NaN(size(cohs,1),1);
rts_4 = NaN(size(cohs,1),1);
rts_5 = NaN(size(cohs,1),1);

% positive ivar, T1 choice
Lpt1 = cohs > eps;
rts_1(Lpt1) = (A + B) ./ mu1(Lpt1) ./ tanh((A + B) .* mu1(Lpt1)) - ...
    B ./ mu1(Lpt1) ./ tanh(B .* mu1(Lpt1)) + Andt1;
Lpt2 = cohs > eps;
rts_2(Lpt2) = (A + B) ./ mu2(Lpt2) ./ tanh((A + B) .* mu2(Lpt2)) - ...
    B ./ mu2(Lpt2) ./ tanh(B .* mu2(Lpt2)) + Andt2;
Lpt3 = cohs > eps;
rts_3(Lpt3) = (A + B) ./ mu3(Lpt3) ./ tanh((A + B) .* mu3(Lpt3)) - ...
    B ./ mu3(Lpt3) ./ tanh(B .* mu3(Lpt3)) + Andt3;
Lpt4 = cohs > eps;
rts_4(Lpt4) = (A + B) ./ mu4(Lpt4) ./ tanh((A + B) .* mu4(Lpt4)) - ...
    B ./ mu4(Lpt4) ./ tanh(B .* mu4(Lpt4)) + Andt4;
Lpt5 = cohs > eps;
rts_5(Lpt5) = (A + B) ./ mu5(Lpt5) ./ tanh((A + B) .* mu5(Lpt5)) - ...
    B ./ mu5(Lpt5) ./ tanh(B .* mu5(Lpt5)) + Andt5;

% zero ivar, T1 choice
L0t1 = cohs >= 0 & cohs <= eps; 
rts_1(L0t1) = (A.^2 + 2 .* A .* B) ./ 3 + Andt1;
L0t2 = cohs >= 0 & cohs <= eps; 
rts_2(L0t2) = (A.^2 + 2 .* A .* B) ./ 3 + Andt2;
L0t3 = cohs >= 0 & cohs <= eps; 
rts_3(L0t3) = (A.^2 + 2 .* A .* B) ./ 3 + Andt3;
L0t4 = cohs >= 0 & cohs <= eps; 
rts_4(L0t4) = (A.^2 + 2 .* A .* B) ./ 3 + Andt4;
L0t5 = cohs >= 0 & cohs <= eps; 
rts_5(L0t5) = (A.^2 + 2 .* A .* B) ./ 3 + Andt5;

% negative ivar, T2 choice
Lnt1 = cohs < -eps;
rts_1(Lnt1) = (A + B) ./ mu1(Lnt1) ./ tanh((A + B) .* mu1(Lnt1)) - ...
    A ./ mu1(Lnt1) ./ tanh(A .* mu1(Lnt1)) + Bndt1;
Lnt2 = cohs < -eps;
rts_2(Lnt2) = (A + B) ./ mu2(Lnt2) ./ tanh((A + B) .* mu2(Lnt2)) - ...
    A ./ mu2(Lnt2) ./ tanh(A .* mu2(Lnt2)) + Bndt2;
Lnt3 = cohs < -eps;
rts_3(Lnt3) = (A + B) ./ mu3(Lnt3) ./ tanh((A + B) .* mu3(Lnt3)) - ...
    A ./ mu3(Lnt3) ./ tanh(A .* mu3(Lnt3)) + Bndt3;
Lnt4 = cohs < -eps;
rts_4(Lnt4) = (A + B) ./ mu4(Lnt4) ./ tanh((A + B) .* mu4(Lnt4)) - ...
    A ./ mu4(Lnt4) ./ tanh(A .* mu4(Lnt4)) + Bndt4;
Lnt5 = cohs < -eps;
rts_5(Lnt5) = (A + B) ./ mu5(Lnt5) ./ tanh((A + B) .* mu5(Lnt5)) - ...
    A ./ mu5(Lnt5) ./ tanh(A .* mu5(Lnt5)) + Bndt5;

% zero ivar, T2 choice
L0t1 = cohs <= 0 & cohs >= -eps; 
rts_1(L0t1) = (B.^2 + 2 .* A .* B) ./ 3 + Bndt1;
L0t2 = cohs <= 0 & cohs >= -eps; 
rts_2(L0t2) = (B.^2 + 2 .* A .* B) ./ 3 + Bndt2;
L0t3 = cohs <= 0 & cohs >= -eps; 
rts_3(L0t3) = (B.^2 + 2 .* A .* B) ./ 3 + Bndt3;
L0t4 = cohs <= 0 & cohs >= -eps; 
rts_4(L0t4) = (B.^2 + 2 .* A .* B) ./ 3 + Bndt4;
L0t5 = cohs <= 0 & cohs >= -eps; 
rts_5(L0t5) = (B.^2 + 2 .* A .* B) ./ 3 + Bndt5;

ps_ = [ps_1, ps_2, ps_3, ps_4, ps_5];
rts_ = [rts_1, rts_2, rts_3, rts_4, rts_5];

end

