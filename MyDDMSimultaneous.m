function MyDDMSimultaneous(block_size)
%% Set up

% Data File being used:
% 1st column: percentage of high tone (mapped this percentage to signed coherence like this: (proportion-50).*2)
% 2nd column: monkey's choice (1: high-tone choice, 0: low-tone choice)
% 3rd column: response time (sec)
% 4th column: success of choice (1: correct, 0: incorrect)

close all

%cd into file that holds data 
cd ('/Users/briannakarpowicz/Documents/Cohen Lab/Auditory-Visual Task/Data/');
%load in data
PopBehavior = csvread('DDM_AudVisTask_v1_Diana_Sad_170606_1547.csv', 1, 0); %block size 80
%csvread('DDM_AudVisTask_v1_Brianna_170530_1345.csv', 1, 0); %block size 25
%csvread('SampleData.csv'); %block size 15
Headings = load('AudVisTask_v1_Diana_Sad_170606_1547_table.mat');
h = Headings.data_table_stim(:, 2);

%extract block visual modes from matrix
block1 = h{1, 1};
block2 = h{block_size + 1,1};
block3 = h{2*block_size + 1,1};
block4 = h{3*block_size + 1,1};
block5 = h{4*block_size + 1, 1};
  
%coherence bins
cbins = [ ...
        -100  -99
        -99   -60
        -60   -40
        -40   -28
        -28   -12
        -12    -8
         -8     8
          8    12
         12    28
         28    40
         40    60
         60    99
         99   100];

%calculate number of coherence bins 
nbins = size(cbins,1);
%calculate average value of each coherence bin - output vector 
cax   = mean(cbins,2);
%create vector from -100 to 100
cfax  = -100:.1:100;
%initialize vectors to hold pmf and cmf values
pmf1   = NaN(nbins,1);
cmf1   = NaN(nbins,2);
pmf2   = NaN(nbins,1);
cmf2   = NaN(nbins,2);
pmf3   = NaN(nbins,1);
cmf3   = NaN(nbins,2);
pmf4   = NaN(nbins,1);
cmf4   = NaN(nbins,2);
pmf5   = NaN(nbins,1);
cmf5   = NaN(nbins,2);

%set data to variable
Behavior1 = PopBehavior(1:block_size, :);
Behavior2 = PopBehavior(block_size+1:2*block_size, :);
Behavior3 = PopBehavior(2*block_size+1:3*block_size, :);
Behavior4 = PopBehavior(3*block_size+1:4*block_size, :);
Behavior5 = PopBehavior(4*block_size+1:5*block_size, :);

%enter file for fit functions
cd ('/Users/briannakarpowicz/Documents/Cohen Lab/Auditory-Visual Task/');

%calculate number of trials 
ntrials = block_size;

%% Data formatting

%create vector of true = high false = low; ensures all values are 0 or 1 
Lch1     = Behavior1(:,2)==1;
Lch2     = Behavior2(:,2)==1;
Lch3     = Behavior3(:,2)==1;
Lch4     = Behavior4(:,2)==1;
Lch5     = Behavior5(:,2)==1;

% create a data matrix for each visual mode, columns are:
%   1. re-scale signal strength to [-100, 100]
%   2. choice (1: high-tone choice, 0: low-tone choice)
%   3. RT (ms)
%   4. correct (1) or error (0)

scoh1 = Behavior1(:,1).*200-100;
Lcor1 = Behavior1(:,4);
data1 = cat(2, scoh1, Behavior1(:,2), Behavior1(:,3), double(Lcor1));
scoh2 = Behavior2(:,1).*200-100;
Lcor2 = Behavior2(:,4); 
data2 = cat(2, scoh2, Behavior2(:,2), Behavior2(:,3), double(Lcor2));
scoh3 = Behavior3(:,1).*200-100;
Lcor3 = Behavior3(:,4); 
data3 = cat(2, scoh3, Behavior3(:,2), Behavior3(:,3), double(Lcor3));
scoh4 = Behavior4(:,1).*200-100;
Lcor4 = Behavior4(:,4); 
data4 = cat(2, scoh4, Behavior4(:,2), Behavior4(:,3), double(Lcor4));
scoh5 = Behavior5(:,1).*200-100;
Lcor5 = Behavior5(:,4); 
data5 = cat(2, scoh5, Behavior5(:,2), Behavior5(:,3), double(Lcor5));

%calculate lapse to account for subject not paying attention
Llapse1 = abs(scoh1)>=90;
lapse1 = 1-sum(Llapse1&Lcor1)./sum(Llapse1);
Llapse2 = abs(scoh2)>=90;
lapse2 = 1-sum(Llapse2&Lcor2)./sum(Llapse2);
Llapse3 = abs(scoh3)>=90;
lapse3 = 1-sum(Llapse3&Lcor3)./sum(Llapse3);
Llapse4 = abs(scoh4)>=90;
lapse4 = 1-sum(Llapse4&Lcor4)./sum(Llapse4);
Llapse5 = abs(scoh5)>=90;
lapse5 = 1-sum(Llapse5&Lcor5)./sum(Llapse5);

%% Independent Curve Fits

%fit the curves independently (full model)

% make selection array, compute pmf and cmf
% PMF - a function that gives the probability that a discrete random variable is exactly equal to some value
% CMF -  the probability that X will take a value less than or equal to x
Lcoh1  = false(ntrials, nbins);
for cc = 1:nbins
    Lcoh1(:,cc) = scoh1>=cbins(cc,1) & scoh1<cbins(cc,2);
    cax1(cc) = mean(scoh1(Lcoh1(:,cc)));
    
    pmf1(cc) = sum(Behavior1(Lcoh1(:,cc)&Lch1,2))./sum(Lcoh1(:,cc)).*100;
    
    cmf1(cc,1) = nanmean(data1(Lcoh1(:,cc)& Lch1,3));
    cmf1(cc,2) = nanmean(data1(Lcoh1(:,cc)&~Lch1,3));
end

Lcoh2  = false(ntrials, nbins);
for cc = 1:nbins
    Lcoh2(:,cc) = scoh2>=cbins(cc,1) & scoh2<cbins(cc,2);
    cax2(cc) = mean(scoh2(Lcoh2(:,cc)));
    
    pmf2(cc) = sum(Behavior2(Lcoh2(:,cc)&Lch2,2))./sum(Lcoh2(:,cc)).*100;
    
    cmf2(cc,1) = nanmean(data2(Lcoh2(:,cc)& Lch2,3));
    cmf2(cc,2) = nanmean(data2(Lcoh2(:,cc)&~Lch2,3));
end

Lcoh3  = false(ntrials, nbins);
for cc = 1:nbins
    Lcoh3(:,cc) = scoh3>=cbins(cc,1) & scoh3<cbins(cc,2);
    cax3(cc) = mean(scoh3(Lcoh3(:,cc)));
    
    pmf3(cc) = sum(Behavior3(Lcoh3(:,cc)&Lch3,2))./sum(Lcoh3(:,cc)).*100;
    
    cmf3(cc,1) = nanmean(data3(Lcoh3(:,cc)& Lch3,3));
    cmf3(cc,2) = nanmean(data3(Lcoh3(:,cc)&~Lch3,3));
end

Lcoh4  = false(ntrials, nbins);
for cc = 1:nbins
    Lcoh4(:,cc) = scoh4>=cbins(cc,1) & scoh4<cbins(cc,2);
    cax4(cc) = mean(scoh4(Lcoh4(:,cc)));
    
    pmf4(cc) = sum(Behavior4(Lcoh4(:,cc)&Lch4,2))./sum(Lcoh4(:,cc)).*100;
    
    cmf4(cc,1) = nanmean(data4(Lcoh4(:,cc)& Lch4,3));
    cmf4(cc,2) = nanmean(data4(Lcoh4(:,cc)&~Lch4,3));
end

Lcoh5  = false(ntrials, nbins);
for cc = 1:nbins
    Lcoh5(:,cc) = scoh5>=cbins(cc,1) & scoh5<cbins(cc,2);
    cax5(cc) = mean(scoh5(Lcoh5(:,cc)));
    
    pmf5(cc) = sum(Behavior5(Lcoh5(:,cc)&Lch5,2))./sum(Lcoh5(:,cc)).*100;
    
    cmf5(cc,1) = nanmean(data5(Lcoh5(:,cc)& Lch5,3));
    cmf5(cc,2) = nanmean(data5(Lcoh5(:,cc)&~Lch5,3));
end

X0  = [200 200 200 200 200];
Xlb = [0.01 0.01 0.01 0.01 0.01];
Xub = [50000 50000 50000 2000 2000];

% get err from initial fit
err0_1 = fitJT_err(X0, data1, lapse1);
err0_2 = fitJT_err(X0, data2, lapse2);
err0_3 = fitJT_err(X0, data3, lapse3);
err0_4 = fitJT_err(X0, data4, lapse4);
err0_5 = fitJT_err(X0, data5, lapse5);

% fit it using pattern search
[fits1,err1] = patternsearch(@(x)fitJT_err(x, data1, lapse1), ...
    X0, [], [], [], [], Xlb, Xub, [], ...
    psoptimset('MaxIter', 5000, 'MaxFunEvals', 5000));
[fits2,err2] = patternsearch(@(x)fitJT_err(x, data2, lapse2), ...
    X0, [], [], [], [], Xlb, Xub, [], ...
    psoptimset('MaxIter', 5000, 'MaxFunEvals', 5000));
[fits3,err3] = patternsearch(@(x)fitJT_err(x, data3, lapse3), ...
    X0, [], [], [], [], Xlb, Xub, [], ...
    psoptimset('MaxIter', 5000, 'MaxFunEvals', 5000));
[fits4,err4] = patternsearch(@(x)fitJT_err(x, data4, lapse4), ...
    X0, [], [], [], [], Xlb, Xub, [], ...
    psoptimset('MaxIter', 5000, 'MaxFunEvals', 5000));
[fits5,err5] = patternsearch(@(x)fitJT_err(x, data5, lapse5), ...
    X0, [], [], [], [], Xlb, Xub, [], ...
    psoptimset('MaxIter', 5000, 'MaxFunEvals', 5000));

% possibly seed as init values
if err1 < err0_1
    X0g1  = fits1;
    err0_1 = err1;
else
    X0g1 = X0;
end

if err2 < err0_2
    X0g2  = fits2;
    err0_2 = err2;
else
    X0g2 = X0;
end

if err3 < err0_3
    X0g3  = fits3;
    err0_3 = err3;
else
    X0g3 = X0;
end

if err4 < err0_4
    X0g4  = fits4;
    err0_4 = err4;
else
    X0g4 = X0;
end

if err5 < err0_5
    X0g5  = fits5;
    err0_5 = err5;
else
    X0g5 = X0;
end

% now gradient descent
[fitsg1,errg1] = fmincon(@(x)fitJT_err(x, data1, lapse1), ...
    X0g1, [], [], [], [], Xlb, Xub, [], ...
    optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));%, 'Display', 'iter'));
[fitsg2,errg2] = fmincon(@(x)fitJT_err(x, data2, lapse2), ...
    X0g2, [], [], [], [], Xlb, Xub, [], ...
    optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));%, 'Display', 'iter'));
[fitsg3,errg3] = fmincon(@(x)fitJT_err(x, data3, lapse3), ...
    X0g3, [], [], [], [], Xlb, Xub, [], ...
    optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));%, 'Display', 'iter'));
[fitsg4,errg4] = fmincon(@(x)fitJT_err(x, data4, lapse4), ...
    X0g4, [], [], [], [], Xlb, Xub, [], ...
    optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));%, 'Display', 'iter'));
[fitsg5,errg5] = fmincon(@(x)fitJT_err(x, data5, lapse5), ...
    X0g5, [], [], [], [], Xlb, Xub, [], ...
    optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));%, 'Display', 'iter'));

% save the best fit between the two methods
if errg1 < err0_1
    fits1 = fitsg1;
    err0_1 = errg1;
end
if errg2 < err0_2
    fits2 = fitsg2;
    err0_2 = errg2;
end
if errg3 < err0_3
    fits3 = fitsg3;
    err0_3 = errg3;
end
if errg4 < err0_4
    fits4 = fitsg4;
    err0_4 = errg4;
end
if errg5 < err0_5
    fits5 = fitsg5;
    err0_5 = errg5;
end

%total error
err_indep = (err0_1 + err0_2 + err0_3 + err0_4 + err0_5);

%% Simultaneous curve fit, holding accumulation rate parameter constant

data_all = cat(2, data1, data2, data3, data4, data5);

%define x0, lower and upper bounds
X0  = [200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200, ...
    200 200 200 200];
Xlb = [0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01...
    0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01];
Xub = [50000 50000 50000 2000 2000 50000 50000 2000 2000 50000, ...
    50000 2000 2000 50000 50000 2000 2000 50000 50000 2000 2000];

%fit holding mu constant
[fits_mu,err_mu] = patternsearch(@(fits)fitBK_err_constDrift(fits, ...
    data_all, [lapse1, lapse2, lapse3, lapse4, lapse5]), ...
    X0, [], [], [], [], Xlb, Xub, [], optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));
[fits_mu2,err_mu2] = fmincon(@(fits)fitBK_err_constDrift(fits, data_all,...
    [lapse1, lapse2, lapse3, lapse4, lapse5]), ...
    X0, [], [], [], [], Xlb, Xub, [], ...
    optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 40000));

% save the best fit between the two methods
if err_mu2 < err_mu
    fits_mu = fits_mu2;
    err_mu = err_mu2;
end

%% Simultaneous curve fit, holding bounds parameters constant

X0  = [200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200];
Xlb = [0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01...
    0.01 0.01 0.01 0.01];
Xub = [50000 50000 50000 2000 2000 50000 2000 2000 50000 2000 2000, ...
     50000 2000 2000 50000 2000 2000];

%fit holding both A and B bounds constant
[fits_AB,err_AB] = patternsearch(@(f)fitBK_err_constBothBounds(f, ...
    data_all, [lapse1, lapse2, lapse3, lapse4, lapse5]), ...
    X0, [], [], [], [], Xlb, Xub, [], optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));
[fits_AB2, err_AB2] = fmincon(@(f)fitBK_err_constBothBounds(f, ...
    data_all, [lapse1, lapse2, lapse3, lapse4, lapse5]), ...
    X0, [], [], [], [], Xlb, Xub, [], optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 40000));

% save the best fit between the two methods
if err_AB2 < err_AB
    fits_AB = fits_AB2;
    err_AB = err_AB2;
end

%% Simultaneous curve fit, holding ONLY bound A constant

%define x0, lower and upper bounds
X0  = [200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200, ...
    200 200 200 200];
Xlb = [0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01...
    0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01];
Xub = [50000 50000 50000 2000 2000 50000 50000 2000 2000 50000, ...
    50000 2000 2000 50000 50000 2000 2000 50000 50000 2000 2000];

[fits_A,err_A] = patternsearch(@(ft)fitBK_err_constBoundA(ft, ...
    data_all, [lapse1, lapse2, lapse3, lapse4, lapse5]), ...
    X0, [], [], [], [], Xlb, Xub, [], optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));
[fits_A1, err_A1] = fmincon(@(ft)fitBK_err_constBoundA(ft, data_all, ...
    [lapse1, lapse2, lapse3, lapse4, lapse5]), X0, [], [], [], [], ...
    Xlb, Xub, [], optimset('Algorithm', 'active-set', 'MaxIter', 30000, ...
    'MaxFunEvals', 40000));

% save the best fit between the two methods
if err_A1 < err_A
    fits_A = fits_A1;
    err_A = err_A1;
end

%% Simultaneous curve fit, holding ONLY bound B constant 

%define x0, lower and upper bounds
X0  = [200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200, ...
    200 200 200 200];
Xlb = [0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01...
    0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01];
Xub = [50000 50000 50000 2000 2000 50000 50000 2000 2000 50000, ...
    50000 2000 2000 50000 50000 2000 2000 50000 50000 2000 2000];

[fits_B,err_B] = patternsearch(@(fitt)fitBK_err_constBoundA(fitt, ...
    data_all, [lapse1, lapse2, lapse3, lapse4, lapse5]), ...
    X0, [], [], [], [], Xlb, Xub, [], optimset('Algorithm', 'active-set', ...
    'MaxIter', 30000, 'MaxFunEvals', 30000));
[fits_B2, err_B2] = fmincon(@(fitt)fitBK_err_constBoundB(fitt, data_all, ...
    [lapse1, lapse2, lapse3, lapse4, lapse5]), X0, [], [], [], [], ...
    Xlb, Xub, [], optimset('Algorithm', 'active-set', 'MaxIter', 30000, ...
    'MaxFunEvals', 40000));

% save the best fit between the two methods
if err_B2 < err_B
    fits_B = fits_B2;
    err_B = err_B2;
end

%% Determine the best of the models
%use BIC or AIC to determine the best fit model

% err_indep = -100000000;
% err_AB = -100000000;
% err_mu = -100000000;
% err_A = -100000000;
% err_B = -100000000;

%%%BIC is "harsher" on free parameters than AIC
errors = [err_indep, err_mu, err_AB, err_A, err_B];
[aic, bic] = aicbic(errors, [5, 4, 3, 4, 4], block_size .* ones(5,1));
[~, index] = min(aic);

if index == 1
    [ps1,rts1] = fitJT_val_simple5L(cfax, fits1, lapse1);
    [ps2,rts2] = fitJT_val_simple5L(cfax, fits2, lapse2);
    [ps3,rts3] = fitJT_val_simple5L(cfax, fits3, lapse3);
    [ps4,rts4] = fitJT_val_simple5L(cfax, fits4, lapse4);
    [ps5,rts5] = fitJT_val_simple5L(cfax, fits5, lapse5);
    
    t = 'Independent Fits';
elseif index == 2
    M = repmat(cfax', 1, 5);
    [ps, rts] = fitBK_val_constDrift4L(M, fits_mu, [lapse1, lapse2,...
        lapse3, lapse4, lapse5]);
    
    ps1 = ps(:, 1);
    ps2 = ps(:, 2);
    ps3 = ps(:, 3);
    ps4 = ps(:, 4);
    ps5 = ps(:, 5);
    
    rts1 = rts(:, 1);
    rts2 = rts(:, 2);
    rts3 = rts(:, 3);
    rts4 = rts(:, 4);
    rts5 = rts(:, 5);
    
    t = 'Constant Drift Rate';
elseif index == 3
    M = repmat(cfax', 1, 5);
    [ps, rts] = fitBK_val_constBounds3L(M, fits_AB, [lapse1, lapse2, ...
        lapse3, lapse4, lapse5]);
    
    ps1 = ps(:, 1);
    ps2 = ps(:, 2);
    ps3 = ps(:, 3);
    ps4 = ps(:, 4);
    ps5 = ps(:, 5);
    
    rts1 = rts(:, 1);
    rts2 = rts(:, 2);
    rts3 = rts(:, 3);
    rts4 = rts(:, 4);
    rts5 = rts(:, 5);
    
    t = 'Constant Both Bounds';
elseif index == 4
    M = repmat(cfax', 1, 5);
    [ps, rts] = fitBK_val_constBoundA4L(M, fits_A, [lapse1, lapse2, lapse3, ...
        lapse4, lapse5]);
    
    ps1 = ps(:, 1);
    ps2 = ps(:, 2);
    ps3 = ps(:, 3);
    ps4 = ps(:, 4);
    ps5 = ps(:, 5);
    
    rts1 = rts(:, 1);
    rts2 = rts(:, 2);
    rts3 = rts(:, 3);
    rts4 = rts(:, 4);
    rts5 = rts(:, 5);
    
    t = 'Constant Bound A';
elseif index == 5
    M = repmat(cfax', 1, 5);
    [ps, rts] = fitBK_val_constBoundB4L(M, fits_B, [lapse1, lapse2, lapse3, ...
        lapse4, lapse5]);
    
    ps1 = ps(:, 1);
    ps2 = ps(:, 2);
    ps3 = ps(:, 3);
    ps4 = ps(:, 4);
    ps5 = ps(:, 5);
    
    rts1 = rts(:, 1);
    rts2 = rts(:, 2);
    rts3 = rts(:, 3);
    rts4 = rts(:, 4);
    rts5 = rts(:, 5);
    
    t = 'Constant Bound B';
end
%% PLOTZ

figure()
%INDEPENDENT
if index == 1
    subplot(3,1,1); cla reset; hold on;
    %%%block 1
    plot(cax1, pmf1, 'k.', 'MarkerSize', 12);
    p1 = plot(cfax, ps1.*100, 'k-', 'LineWidth', 0.75);
    plot([-100 0], [lapse1*100 lapse1*100], 'k--');
    plot([0 100], [100-lapse1*100 100-lapse1*100], 'k--');
    %%%block 2
    plot(cax2, pmf2, 'r.', 'MarkerSize', 12);
    p2 = plot(cfax, ps2.*100, 'r-', 'LineWidth', 0.75);
    plot([-100 0], [lapse2*100 lapse2*100], 'r--');
    plot([0 100], [100-lapse2*100 100-lapse2*100], 'r--');
    %%%block 3
    plot(cax3, pmf3, 'b.', 'MarkerSize', 12); hold on;
    p3 = plot(cfax, ps3.*100, 'b-', 'LineWidth', 0.75);
    plot([-100 0], [lapse3*100 lapse3*100], 'b--'); hold on;
    plot([0 100], [100-lapse3*100 100-lapse3*100], 'b--');
    %%%block 4
    plot(cax4, pmf4, 'g.', 'MarkerSize', 12);
    p4 = plot(cfax, ps4.*100, 'g-', 'LineWidth', 0.75);
    plot([-100 0], [lapse4*100 lapse4*100], 'g--');
    plot([0 100], [100-lapse4*100 100-lapse4*100], 'g--');
    %%%block5
    plot(cax5, pmf5, 'm.', 'MarkerSize', 12);
    p5 = plot(cfax, ps5.*100, 'm-', 'LineWidth', 0.75);
    plot([-100 0], [lapse5*100 lapse5*100], 'm--');
    plot([0 100],[100-lapse5*100 100-lapse5*100], 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('high-tone choice (%)')
    legend([p1, p2, p3, p4, p5], [block1, block2, block3, block4, block5])
    title(t);
    
    %Horizontal shifts of these lines imply changes in the mean rate-of-rise
    %swivels about a fixed point at infinite RT imply changes in the bound height
    subplot(3,1,2); cla reset; hold on;
    %%%block 1
    plot(cax1(cax1>=0), cmf1(cax1>=0,1), 'k.', 'MarkerSize', 12);
    plot(cax1(cax1<=0), cmf1(cax1<=0,2), 'k.', 'MarkerSize', 12);
    g1 = plot(cfax, rts1, 'k-', 'LineWidth', 0.75);
    plot([0 100], fits1([4 4]), 'k--');
    plot([-100 0], fits1([5 5]), 'k--');
    %%%block 2
    plot(cax2(cax2>=0), cmf2(cax2>=0,1), 'r.', 'MarkerSize', 12);
    plot(cax2(cax2<=0), cmf2(cax2<=0,2), 'r.', 'MarkerSize', 12);
    g2 = plot(cfax, rts2, 'r-', 'LineWidth', 0.75);
    plot([0 100], fits2([4 4]), 'r--');
    plot([-100 0], fits2([5 5]), 'r--');
    %%%block 3
    plot(cax3(cax3>=0), cmf3(cax3>=0,1), 'b.', 'MarkerSize', 12);
    plot(cax3(cax3<=0), cmf3(cax3<=0,2), 'b.', 'MarkerSize', 12);
    g3 = plot(cfax, rts3, 'b-', 'LineWidth', 0.75);
    plot([0 100], fits3([4 4]), 'b--');
    plot([-100 0], fits3([5 5]), 'b--');
    %%%block 4
    plot(cax4(cax4>=0), cmf4(cax4>=0,1), 'g.', 'MarkerSize', 8);
    plot(cax4(cax4<=0), cmf4(cax4<=0,2), 'g.', 'MarkerSize', 8);
    g4 = plot(cfax, rts4, 'g-', 'LineWidth', 0.75);
    plot([0 100], fits4([4 4]), 'g--');
    plot([-100 0], fits4([5 5]), 'g--');
    %%%block5
    plot(cax5(cax5>=0), cmf5(cax5>=0,1), 'm.', 'MarkerSize', 12);
    plot(cax5(cax5<=0), cmf5(cax5<=0,2), 'm.', 'MarkerSize', 12);
    g5 = plot(cfax, rts5, 'm-', 'LineWidth', 0.75);
    plot([0 100], fits5([4 4]), 'm--');
    plot([-100 0], fits5([5 5]), 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Response time (ms)')
    legend([g1, g2, g3, g4, g5], [block1, block2, block3, block4, block5])
    
    subplot(3,1,3); cla reset; hold on;
    %%%block 1
    plot(cfax(cfax<0), rts1(cfax<0)-fits1(5), 'k-', 'LineWidth', 0.75);hold on;
    v1 = plot(cfax(cfax>0), rts1(cfax>0)-fits1(4), 'k-', 'LineWidth', 0.75);
    %%%block 2
    plot(cfax(cfax<0), rts2(cfax<0)-fits2(5), 'r-', 'LineWidth', 0.75);hold on;
    v2 = plot(cfax(cfax>0), rts2(cfax>0)-fits2(4), 'r-', 'LineWidth', 0.75);
    %%%block 3
    plot(cfax(cfax<0), rts3(cfax<0)-fits3(5), 'b-', 'LineWidth', 0.75);hold on;
    v3 = plot(cfax(cfax>0), rts3(cfax>0)-fits3(4), 'b-', 'LineWidth', 0.75);
    %%%block 4
    plot(cfax(cfax<0), rts4(cfax<0)-fits4(5), 'g-', 'LineWidth', 0.75);hold on;
    v4 = plot(cfax(cfax>0), rts4(cfax>0)-fits4(4), 'g-', 'LineWidth', 0.75);
    %%%block 5
    plot(cfax(cfax<0), rts5(cfax<0)-fits5(5), 'm-', 'LineWidth', 0.75);hold on;
    v5 = plot(cfax(cfax>0), rts5(cfax>0)-fits5(4), 'm-', 'LineWidth', 0.75);
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Decision time (ms): RT-nonDT')
    legend([v1 v2 v3 v4 v5],[block1 block2 block3 block4 block5])
    
%CONSTANT DRIFT
elseif index == 2
    subplot(3,1,1); cla reset; hold on;
    %%%block 1
    plot(cax1, pmf1, 'k.', 'MarkerSize', 12);
    p1 = plot(cfax, ps1.*100, 'k-', 'LineWidth', 0.75);
    plot([-100 0], [lapse1*100 lapse1*100], 'k--');
    plot([0 100], [100-lapse1*100 100-lapse1*100], 'k--');
    %%%block 2
    plot(cax2, pmf2, 'r.', 'MarkerSize', 12);
    p2 = plot(cfax, ps2.*100, 'r-', 'LineWidth', 0.75);
    plot([-100 0], [lapse2*100 lapse2*100], 'r--');
    plot([0 100], [100-lapse2*100 100-lapse2*100], 'r--');
    %%%block 3
    plot(cax3, pmf3, 'b.', 'MarkerSize', 12); hold on;
    p3 = plot(cfax, ps3.*100, 'b-', 'LineWidth', 0.75); hold on;
    plot([-100 0], [lapse3*100 lapse3*100], 'b--'); hold on;
    plot([0 100], [100-lapse3*100 100-lapse3*100], 'b--');
    %%%block 4
    plot(cax4, pmf4, 'g.', 'MarkerSize', 12);
    p4 = plot(cfax, ps4.*100, 'g-', 'LineWidth', 0.75);
    plot([-100 0], [lapse4*100 lapse4*100], 'g--');
    plot([0 100], [100-lapse4*100 100-lapse4*100], 'g--');
    %%%block5
    plot(cax5, pmf5, 'm.', 'MarkerSize', 12);
    p5 = plot(cfax, ps5.*100, 'm-', 'LineWidth', 0.75);
    plot([-100 0], [lapse5*100 lapse5*100], 'm--');
    plot([0 100],[100-lapse5*100 100-lapse5*100], 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('high-tone choice (%)')
    legend([p1, p2, p3, p4, p5], [block1, block2, block3, block4, block5])
    title(t);
    
    %Horizontal shifts of these lines imply changes in the mean rate-of-rise
    %swivels about a fixed point at infinite RT imply changes in the bound height
    subplot(3,1,2); cla reset; hold on;
    %%%block 1
    plot(cax1(cax1>=0), cmf1(cax1>=0,1), 'k.', 'MarkerSize', 12);
    plot(cax1(cax1<=0), cmf1(cax1<=0,2), 'k.', 'MarkerSize', 12);
    g1 = plot(cfax, rts1, 'k-', 'LineWidth', 0.75);
    plot([0 100], fits_mu([4 4]), 'k--');
    plot([-100 0], fits_mu([5 5]), 'k--');
    %%%block 2
    plot(cax2(cax2>=0), cmf2(cax2>=0,1), 'r.', 'MarkerSize', 12);
    plot(cax2(cax2<=0), cmf2(cax2<=0,2), 'r.', 'MarkerSize', 12);
    g2 = plot(cfax, rts2, 'r-', 'LineWidth', 0.75);
    plot([0 100], fits_mu([8 8]), 'r--');
    plot([-100 0], fits_mu([9 9]), 'r--');
    %%%block 3
    plot(cax3(cax3>=0), cmf3(cax3>=0,1), 'b.', 'MarkerSize', 12);
    plot(cax3(cax3<=0), cmf3(cax3<=0,2), 'b.', 'MarkerSize', 12);
    g3 = plot(cfax, rts3, 'b-', 'LineWidth', 0.75);
    plot([0 100], fits_mu([12 12]), 'b--');
    plot([-100 0], fits_mu([13 13]), 'b--');
    %%%block 4
    plot(cax4(cax4>=0), cmf4(cax4>=0,1), 'g.', 'MarkerSize', 12);
    plot(cax4(cax4<=0), cmf4(cax4<=0,2), 'g.', 'MarkerSize', 12);
    g4 = plot(cfax, rts4, 'g-', 'LineWidth', 0.75);
    plot([0 100], fits_mu([16 16]), 'g--');
    plot([-100 0], fits_mu([17 17]), 'g--');
    %%%block5
    plot(cax5(cax5>=0), cmf5(cax5>=0,1), 'm.', 'MarkerSize', 12);
    plot(cax5(cax5<=0), cmf5(cax5<=0,2), 'm.', 'MarkerSize', 12);
    g5 = plot(cfax, rts5, 'm-', 'LineWidth', 0.75);
    plot([0 100], fits_mu([20 20]), 'm--');
    plot([-100 0], fits_mu([21 21]), 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Response time (ms)')
    legend([g1, g2, g3, g4, g5], [block1, block2, block3, block4, block5])
    
    subplot(3,1,3); cla reset; hold on;
    %%%block 1
    plot(cfax(cfax<0), rts1(cfax<0)-fits_mu(5), 'k-', 'LineWidth', 0.75);hold on;
    v1 = plot(cfax(cfax>0), rts1(cfax>0)-fits_mu(4), 'k-', 'LineWidth', 0.75);
    %%%block 2
    plot(cfax(cfax<0), rts2(cfax<0)-fits_mu(9), 'r-', 'LineWidth', 0.75);hold on;
    v2 = plot(cfax(cfax>0), rts2(cfax>0)-fits_mu(8), 'r-', 'LineWidth', 0.75);
    %%%block 3
    plot(cfax(cfax<0), rts3(cfax<0)-fits_mu(13), 'b-', 'LineWidth', 0.75);hold on;
    v3 = plot(cfax(cfax>0), rts3(cfax>0)-fits_mu(12), 'b-', 'LineWidth', 0.75);
    %%%block 4
    plot(cfax(cfax<0), rts4(cfax<0)-fits_mu(17), 'g-', 'LineWidth', 0.75);hold on;
    v4 = plot(cfax(cfax>0), rts4(cfax>0)-fits_mu(16), 'g-', 'LineWidth', 0.75);
    %%%block 5
    plot(cfax(cfax<0), rts5(cfax<0)-fits_mu(21), 'm-', 'LineWidth', 0.75);hold on;
    v5 = plot(cfax(cfax>0), rts5(cfax>0)-fits_mu(20), 'm-', 'LineWidth', 0.75);
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Decision time (ms): RT-nonDT')
    legend([v1 v2 v3 v4 v5],[block1 block2 block3 block4 block5])
    
%BOTH BOUNDS CONSTANT
elseif index == 3
    subplot(3,1,1); cla reset; hold on;
    %%%block 1
    plot(cax1, pmf1, 'k.', 'MarkerSize', 12);
    p1 = plot(cfax, ps1.*100, 'k-', 'LineWidth', 0.75);
    plot([-100 0], [lapse1*100 lapse1*100], 'k--');
    plot([0 100], [100-lapse1*100 100-lapse1*100], 'k--');
    %%%block 2
    plot(cax2, pmf2, 'r.', 'MarkerSize', 12);
    p2 = plot(cfax, ps2.*100, 'r-', 'LineWidth', 0.75);
    plot([-100 0], [lapse2*100 lapse2*100], 'r--');
    plot([0 100], [100-lapse2*100 100-lapse2*100], 'r--');
    %%%block 3
    plot(cax3, pmf3, 'b.', 'MarkerSize', 12); hold on;
    p3 = plot(cfax, ps3.*100, 'b-', 'LineWidth', 0.75); hold on;
    plot([-100 0], [lapse3*100 lapse3*100], 'b--'); hold on;
    plot([0 100], [100-lapse3*100 100-lapse3*100], 'b--');
    %%%block 4
    plot(cax4, pmf4, 'g.', 'MarkerSize', 12);
    p4 = plot(cfax, ps4.*100, 'g-', 'LineWidth', 0.75);
    plot([-100 0], [lapse4*100 lapse4*100], 'g--');
    plot([0 100], [100-lapse4*100 100-lapse4*100], 'g--');
    %%%block5
    plot(cax5, pmf5, 'm.', 'MarkerSize', 12);
    p5 = plot(cfax, ps5.*100, 'm-', 'LineWidth', 0.75);
    plot([-100 0], [lapse5*100 lapse5*100], 'm--');
    plot([0 100],[100-lapse5*100 100-lapse5*100], 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('high-tone choice (%)')
    legend([p1, p2, p3, p4, p5], [block1, block2, block3, block4, block5])
    title(t);
    
    %Horizontal shifts of these lines imply changes in the mean rate-of-rise
    %swivels about a fixed point at infinite RT imply changes in the bound height
    subplot(3,1,2); cla reset; hold on;
    %%%block 1
    plot(cax1(cax1>=0), cmf1(cax1>=0,1), 'k.', 'MarkerSize', 12);
    plot(cax1(cax1<=0), cmf1(cax1<=0,2), 'k.', 'MarkerSize', 12);
    g1 = plot(cfax, rts1', 'k-', 'LineWidth', 0.75);
    plot([0 100], fits_AB([4 4]), 'k--');
    plot([-100 0], fits_AB([5 5]), 'k--');
    %%%block 2
    plot(cax2(cax2>=0), cmf2(cax2>=0,1), 'r.', 'MarkerSize', 12);
    plot(cax2(cax2<=0), cmf2(cax2<=0,2), 'r.', 'MarkerSize', 12);
    g2 = plot(cfax, rts2', 'r-', 'LineWidth', 0.75);
    plot([0 100], fits_AB([7 7]), 'r--');
    plot([-100 0], fits_AB([8 8]), 'r--');
    %%%block 3
    plot(cax3(cax3>=0), cmf3(cax3>=0,1), 'b.', 'MarkerSize', 12);
    plot(cax3(cax3<=0), cmf3(cax3<=0,2), 'b.', 'MarkerSize', 12);
    g3 = plot(cfax, rts3', 'b-', 'LineWidth', 0.75);
    plot([0 100], fits_AB([10 10]), 'b--');
    plot([-100 0], fits_AB([11 11]), 'b--');
    %%%block 4
    plot(cax4(cax4>=0), cmf4(cax4>=0,1), 'g.', 'MarkerSize', 12);
    plot(cax4(cax4<=0), cmf4(cax4<=0,2), 'g.', 'MarkerSize', 12);
    g4 = plot(cfax, rts4', 'g-', 'LineWidth', 0.75);
    plot([0 100], fits_AB([13 13]), 'g--');
    plot([-100 0], fits_AB([14 14]), 'g--');
    %%%block5
    plot(cax5(cax5>=0), cmf5(cax5>=0,1), 'm.', 'MarkerSize', 12);
    plot(cax5(cax5<=0), cmf5(cax5<=0,2), 'm.', 'MarkerSize', 12);
    g5 = plot(cfax, rts5', 'm-', 'LineWidth', 0.75);
    plot([0 100], fits_AB([16 16]), 'm--');
    plot([-100 0], fits_AB([17 17]), 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Response time (ms)')
    legend([g1, g2, g3, g4, g5], [block1, block2, block3, block4, block5])
    
    subplot(3,1,3); cla reset; hold on;
    %%%block 1
    plot(cfax(cfax<0), (rts1(cfax<0))'-fits_AB(5), 'k-', 'LineWidth', 0.75);hold on;
    v1 = plot(cfax(cfax>0), rts1(cfax>0)-fits_AB(4), 'k-', 'LineWidth', 0.75);
    %%%block 2
    plot(cfax(cfax<0), (rts2(cfax<0))'-fits_AB(8), 'r-', 'LineWidth', 0.75);hold on;
    v2 = plot(cfax(cfax>0), rts2(cfax>0)-fits_AB(7), 'r-', 'LineWidth', 0.75);
    %%%block 3
    plot(cfax(cfax<0), (rts3(cfax<0))'-fits_AB(11), 'b-', 'LineWidth', 0.75);hold on;
    v3 = plot(cfax(cfax>0), rts3(cfax>0)-fits_AB(10), 'b-', 'LineWidth', 0.75);
    %%%block 4
    plot(cfax(cfax<0), (rts4(cfax<0))'-fits_AB(14), 'g-', 'LineWidth', 0.75);hold on;
    v4 = plot(cfax(cfax>0), rts4(cfax>0)-fits_AB(13), 'g-', 'LineWidth', 0.75);
    %%%block 5
    plot(cfax(cfax<0), (rts5(cfax<0))'-fits_AB(17), 'm-', 'LineWidth', 0.75);hold on;
    v5 = plot(cfax(cfax>0), rts5(cfax>0)-fits_AB(16), 'm-', 'LineWidth', 0.75);
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Decision time (ms): RT-nonDT')
    legend([v1 v2 v3 v4 v5],[block1 block2 block3 block4 block5])
    
%CONSTANT BOUND A
elseif index == 4
    subplot(3,1,1); cla reset; hold on;
    %%%block 1
    plot(cax1, pmf1, 'k.', 'MarkerSize', 12);
    p1 = plot(cfax, ps1.*100, 'k-', 'LineWidth', 0.75);
    plot([-100 0], [lapse1*100 lapse1*100], 'k--');
    plot([0 100], [100-lapse1*100 100-lapse1*100], 'k--');
    %%%block 2
    plot(cax2, pmf2, 'r.', 'MarkerSize', 12);
    p2 = plot(cfax, ps2.*100, 'r-', 'LineWidth', 0.75);
    plot([-100 0], [lapse2*100 lapse2*100], 'r--');
    plot([0 100], [100-lapse2*100 100-lapse2*100], 'r--');
    %%%block 3
    plot(cax3, pmf3, 'b.', 'MarkerSize', 12); hold on;
    p3 = plot(cfax, ps3.*100, 'b-', 'LineWidth', 0.75); hold on;
    plot([-100 0], [lapse3*100 lapse3*100], 'b--'); hold on;
    plot([0 100], [100-lapse3*100 100-lapse3*100], 'b--');
    %%%block 4
    plot(cax4, pmf4, 'g.', 'MarkerSize', 12);
    p4 = plot(cfax, ps4.*100, 'g-', 'LineWidth', 0.75);
    plot([-100 0], [lapse4*100 lapse4*100], 'g--');
    plot([0 100], [100-lapse4*100 100-lapse4*100], 'g--');
    %%%block5
    plot(cax5, pmf5, 'm.', 'MarkerSize', 12);
    p5 = plot(cfax, ps5.*100, 'm-', 'LineWidth', 0.75);
    plot([-100 0], [lapse5*100 lapse5*100], 'm--');
    plot([0 100],[100-lapse5*100 100-lapse5*100], 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('high-tone choice (%)')
    legend([p1, p2, p3, p4, p5], [block1, block2, block3, block4, block5])
    title(t);
    
    %Horizontal shifts of these lines imply changes in the mean rate-of-rise
    %swivels about a fixed point at infinite RT imply changes in the bound height
    subplot(3,1,2); cla reset; hold on;
    %%%block 1
    plot(cax1(cax1>=0), cmf1(cax1>=0,1), 'k.', 'MarkerSize', 12);
    plot(cax1(cax1<=0), cmf1(cax1<=0,2), 'k.', 'MarkerSize', 12);
    g1 = plot(cfax, rts1', 'k-', 'LineWidth', 0.75);
    plot([0 100], fits_A([4 4]), 'k--');
    plot([-100 0], fits_A([5 5]), 'k--');
    %%%block 2
    plot(cax2(cax2>=0), cmf2(cax2>=0,1), 'r.', 'MarkerSize', 12);
    plot(cax2(cax2<=0), cmf2(cax2<=0,2), 'r.', 'MarkerSize', 12);
    g2 = plot(cfax, rts2', 'r-', 'LineWidth', 0.75);
    plot([0 100], fits_A([8 8]), 'r--');
    plot([-100 0], fits_A([9 9]), 'r--');
    %%%block 3
    plot(cax3(cax3>=0), cmf3(cax3>=0,1), 'b.', 'MarkerSize', 12);
    plot(cax3(cax3<=0), cmf3(cax3<=0,2), 'b.', 'MarkerSize', 12);
    g3 = plot(cfax, rts3', 'b-', 'LineWidth', 0.75);
    plot([0 100], fits_A([12 12]), 'b--');
    plot([-100 0], fits_A([13 13]), 'b--');
    %%%block 4
    plot(cax4(cax4>=0), cmf4(cax4>=0,1), 'g.', 'MarkerSize', 12);
    plot(cax4(cax4<=0), cmf4(cax4<=0,2), 'g.', 'MarkerSize', 12);
    g4 = plot(cfax, rts4', 'g-', 'LineWidth', 0.75);
    plot([0 100], fits_A([16 16]), 'g--');
    plot([-100 0], fits_A([17 17]), 'g--');
    %%%block5
    plot(cax5(cax5>=0), cmf5(cax5>=0,1), 'm.', 'MarkerSize', 12);
    plot(cax5(cax5<=0), cmf5(cax5<=0,2), 'm.', 'MarkerSize', 12);
    g5 = plot(cfax, rts5', 'm-', 'LineWidth', 0.75);
    plot([0 100], fits_A([20 20]), 'm--');
    plot([-100 0], fits_A([21 21]), 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Response time (ms)')
    legend([g1, g2, g3, g4, g5], [block1, block2, block3, block4, block5])
    
    subplot(3,1,3); cla reset; hold on;
    %%%block 1
    plot(cfax(cfax<0), (rts1(cfax<0))'-fits_A(5), 'k-', 'LineWidth', 0.75);hold on;
    v1 = plot(cfax(cfax>0), rts1(cfax>0)-fits_A(4), 'k-', 'LineWidth', 0.75);
    %%%block 2
    plot(cfax(cfax<0), (rts2(cfax<0))'-fits_A(9), 'r-', 'LineWidth', 0.75);hold on;
    v2 = plot(cfax(cfax>0), rts2(cfax>0)-fits_A(8), 'r-', 'LineWidth', 0.75);
    %%%block 3
    plot(cfax(cfax<0), (rts3(cfax<0))'-fits_A(13), 'b-', 'LineWidth', 0.75);hold on;
    v3 = plot(cfax(cfax>0), rts3(cfax>0)-fits_A(12), 'b-', 'LineWidth', 0.75);
    %%%block 4
    plot(cfax(cfax<0), (rts4(cfax<0))'-fits_A(17), 'g-', 'LineWidth', 0.75);hold on;
    v4 = plot(cfax(cfax>0), rts4(cfax>0)-fits_A(16), 'g-', 'LineWidth', 0.75);
    %%%block 5
    plot(cfax(cfax<0), (rts5(cfax<0))'-fits_A(21), 'm-', 'LineWidth', 0.75);hold on;
    v5 = plot(cfax(cfax>0), rts5(cfax>0)-fits_A(20), 'm-', 'LineWidth', 0.75);
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Decision time (ms): RT-nonDT')
    legend([v1 v2 v3 v4 v5],[block1 block2 block3 block4 block5])

%CONSTANT BOUND B
elseif index == 5
    subplot(3,1,1); cla reset; hold on;
    %%%block 1
    plot(cax1, pmf1, 'k.', 'MarkerSize', 12);
    p1 = plot(cfax, ps1.*100, 'k-', 'LineWidth', 0.75);
    plot([-100 0], [lapse1*100 lapse1*100], 'k--');
    plot([0 100], [100-lapse1*100 100-lapse1*100], 'k--');
    %%%block 2
    plot(cax2, pmf2, 'r.', 'MarkerSize', 12);
    p2 = plot(cfax, ps2.*100, 'r-', 'LineWidth', 0.75);
    plot([-100 0], [lapse2*100 lapse2*100], 'r--');
    plot([0 100], [100-lapse2*100 100-lapse2*100], 'r--');
    %%%block 3
    plot(cax3, pmf3, 'b.', 'MarkerSize', 12); hold on;
    p3 = plot(cfax, ps3.*100, 'b-', 'LineWidth', 0.75); hold on;
    plot([-100 0], [lapse3*100 lapse3*100], 'b--'); hold on;
    plot([0 100], [100-lapse3*100 100-lapse3*100], 'b--');
    %%%block 4
    plot(cax4, pmf4, 'g.', 'MarkerSize', 12);
    p4 = plot(cfax, ps4.*100, 'g-', 'LineWidth', 0.75);
    plot([-100 0], [lapse4*100 lapse4*100], 'g--');
    plot([0 100], [100-lapse4*100 100-lapse4*100], 'g--');
    %%%block5
    plot(cax5, pmf5, 'm.', 'MarkerSize', 12);
    p5 = plot(cfax, ps5.*100, 'm-', 'LineWidth', 0.75);
    plot([-100 0], [lapse5*100 lapse5*100], 'm--');
    plot([0 100],[100-lapse5*100 100-lapse5*100], 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('high-tone choice (%)')
    legend([p1, p2, p3, p4, p5], [block1, block2, block3, block4, block5])
    title(t);
    
    %Horizontal shifts of these lines imply changes in the mean rate-of-rise
    %swivels about a fixed point at infinite RT imply changes in the bound height
    subplot(3,1,2); cla reset; hold on;
    %%%block 1
    plot(cax1(cax1>=0), cmf1(cax1>=0,1), 'k.', 'MarkerSize', 12);
    plot(cax1(cax1<=0), cmf1(cax1<=0,2), 'k.', 'MarkerSize', 12);
    g1 = plot(cfax, rts1', 'k-', 'LineWidth', 0.75);
    plot([0 100], fits_B([4 4]), 'k--');
    plot([-100 0], fits_B([5 5]), 'k--');
    %%%block 2
    plot(cax2(cax2>=0), cmf2(cax2>=0,1), 'r.', 'MarkerSize', 12);
    plot(cax2(cax2<=0), cmf2(cax2<=0,2), 'r.', 'MarkerSize', 12);
    g2 = plot(cfax, rts2', 'r-', 'LineWidth', 0.75);
    plot([0 100], fits_B([8 8]), 'r--');
    plot([-100 0], fits_B([9 9]), 'r--');
    %%%block 3
    plot(cax3(cax3>=0), cmf3(cax3>=0,1), 'b.', 'MarkerSize', 12);
    plot(cax3(cax3<=0), cmf3(cax3<=0,2), 'b.', 'MarkerSize', 12);
    g3 = plot(cfax, rts3', 'b-', 'LineWidth', 0.75);
    plot([0 100], fits_B([12 12]), 'b--');
    plot([-100 0], fits_B([13 13]), 'b--');
    %%%block 4
    plot(cax4(cax4>=0), cmf4(cax4>=0,1), 'g.', 'MarkerSize', 12);
    plot(cax4(cax4<=0), cmf4(cax4<=0,2), 'g.', 'MarkerSize', 12);
    g4 = plot(cfax, rts4', 'g-', 'LineWidth', 0.75);
    plot([0 100], fits_B([16 16]), 'g--');
    plot([-100 0], fits_B([17 17]), 'g--');
    %%%block5
    plot(cax5(cax5>=0), cmf5(cax5>=0,1), 'm.', 'MarkerSize', 12);
    plot(cax5(cax5<=0), cmf5(cax5<=0,2), 'm.', 'MarkerSize', 12);
    g5 = plot(cfax, rts5', 'm-', 'LineWidth', 0.75);
    plot([0 100], fits_B([20 20]), 'm--');
    plot([-100 0], fits_B([21 21]), 'm--');
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Response time (ms)')
    legend([g1, g2, g3, g4, g5], [block1, block2, block3, block4, block5])
    
    subplot(3,1,3); cla reset; hold on;
    %%%block 1
    plot(cfax(cfax<0), (rts1(cfax<0))'-fits_B(5), 'k-', 'LineWidth', 0.75);hold on;
    v1 = plot(cfax(cfax>0), rts1(cfax>0)-fits_B(4), 'k-', 'LineWidth', 0.75);
    %%%block 2
    plot(cfax(cfax<0), (rts2(cfax<0))'-fits_B(9), 'r-', 'LineWidth', 0.75);hold on;
    v2 = plot(cfax(cfax>0), rts2(cfax>0)-fits_B(8), 'r-', 'LineWidth', 0.75);
    %%%block 3
    plot(cfax(cfax<0), (rts3(cfax<0))'-fits_B(13), 'b-', 'LineWidth', 0.75);hold on;
    v3 = plot(cfax(cfax>0), rts3(cfax>0)-fits_B(12), 'b-', 'LineWidth', 0.75);
    %%%block 4
    plot(cfax(cfax<0), (rts4(cfax<0))'-fits_B(17), 'g-', 'LineWidth', 0.75);hold on;
    v4 = plot(cfax(cfax>0), rts4(cfax>0)-fits_B(16), 'g-', 'LineWidth', 0.75);
    %%%block 5
    plot(cfax(cfax<0), (rts5(cfax<0))'-fits_B(21), 'm-', 'LineWidth', 0.75);hold on;
    v5 = plot(cfax(cfax>0), rts5(cfax>0)-fits_B(20), 'm-', 'LineWidth', 0.75);
    
    xlabel('Coherence (%): +100 means all high tones')
    ylabel('Decision time (ms): RT-nonDT')
    legend([v1 v2 v3 v4 v5],[block1 block2 block3 block4 block5])

end

end