function [results_SMF, results_NO_SMF, aic_scores] = fit_models(path)
%wrapper: Wrapper function that calculates negative loglikelihoods and
%AIC scores for different models
%load data
df = readtable(path);
df = table2array(df);

%columns for indexing
 sub = 1;
 act1 = 2; 
 state2=3;
 act2= 4;
 reward = 5;
 turn_index = 6;
%  trial_index = 7; 
 
%find number of subjects
numSubs = length(unique(df(:,sub))); 

%other variables 
results_SMF = zeros(numSubs,10); %store results for model with SIGMA MF
results_NO_SMF = zeros(numSubs,9);%store results for model without SIGMA MF
aic_scores = zeros(numSubs, 3); 


%Loop through number of subjects
for j=1:numSubs
     c1 = df(df(:,1)==j,act1); %choice 1 
     s2 = df(df(:,1)==j, state2); %state 2 
     c2 = df(df(:,1)==j,act2); %action 2 
     re = df(df(:,1)==j,reward); %reward 
     turn = df(df(:,1)==j,turn_index); %turn 
     sub_id = df(df(:,1)==j,sub); %sub_id
     sub_id = unique(sub_id(:));
     
     %optimization functions 
     options = optimoptions('fmincon', 'Display', 'off');
     disp(['... Subject: ', num2str(j)]);
     
     %OPTIMIZE WITH SIGMA_MF
     [params1, nll_SIGMA_MF, ~] = fmincon(@ (params1)...
         nll_SMF(params1, c1, s2, c2, re,turn),...
         [1 .5 .5 2 .5 .5 .5 2],[],[],[],[],...
         [.1 0 0 1 0 0 0 1], [1.9 1 1 5 1 1 1 5],[], options); 
    results_SMF(j,:) = cat(2,sub_id,params1, nll_SIGMA_MF); 
    [aic_SMF] = aicbic(nll_SIGMA_MF, 8); 
    aic_scores(j,1:2) = cat(2, sub_id, aic_SMF); 
    
     %OPTIMIZE WITHOUT SIGMA_MF
     [params2, nll_NO_SIGMA_MF, ~] = fmincon(@ (params2)...
         nll_NO_SMF(params2, c1, s2, c2, re,turn),...
         [1 .5 .5 2 .5 .5 2],[],[],[],[],...
         [.1 0 0 1 0 0 1], [1.9 1 1 5 1 1 5],[], options); 
    results_NO_SMF(j,:) = cat(2,sub_id,params2, nll_NO_SIGMA_MF);
    [aic_NO_SMF] = aicbic(nll_NO_SIGMA_MF, 7); 
   	aic_scores(j,3) = aic_NO_SMF; % cat(2,aic_NO_SMF); 
end 

end 