function wrapper()
%wrapper: Wrapper function that calculates negative loglikelihoods and
%AIC scores for different models
%load data
path = "study1_social_data.csv"; %data from experiment 2 of Osborn 2020 (Thesis).
df = readtable(path);
df = table2array(df);

%columns for indexing
 sub = 1;
 turn_index = 7; 
 act1 = 2; 
 state2=3;
 act2= 4;
 reward = 5;

%find number of subjects
numSubs = length(unique(df(:,sub))); 

%other variables 
results_SMF = zeros(numSubs,10); %store results for model with SIGMA MF
results_NO_SMF = zeros(numSubs,9);%store results for model without SIGMA MF
fit_SIGMA_MF = zeros(numSubs, 2); 
fit_NO_SIGMA_MF = zeros(numSubs, 2); 

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
     [paramsA, nll_SIGMA_MF, ~] = fmincon(@ (paramsA)...
         nll_SMF(paramsA, c1, s2, c2, re,turn),...
         [1 .5 .5 2 .5 .5 .5 2],[],[],[],[],...
         [.1 0 0 1 0 0 0 1], [1.9 1 1 5 1 1 1 5],[], options); 
    results_SMF(j,:) = cat(2,sub_id,paramsA, nll_SIGMA_MF); 
    [aic_SMF] = aicbic(nll_SIGMA_MF, 8); 
    fit_SIGMA_MF(j,:) = cat(2, sub_id, aic_SMF); 
    
     %OPTIMIZE WITHOUT SIGMA_MF
     [paramsB, nll_NO_SIGMA_MF, ~] = fmincon(@ (paramsB)...
         nll_NO_SMF(paramsB, c1, s2, c2, re,turn),...
         [1 .5 .5 2 .5 .5 2],[],[],[],[],...
         [.1 0 0 1 0 0 1], [1.9 1 1 5 1 1 5],[], options); 
    results_NO_SMF(j,:) = cat(2,sub_id,paramsB, nll_NO_SIGMA_MF);
    [aic_NO_SMF] = aicbic(nll_NO_SIGMA_MF, 7); 
    fit_NO_SIGMA_MF(j,:) = cat(2, sub_id, aic_NO_SMF); 
end 

%save
headers_simsA = {'sub_id', 'beta','lr','e','ps','w_MB',...
    'sigma_mb','sigma_mf','sigma_ps', 'nll'}; 
headers_simsB = {'sub_id', 'beta','lr','e','ps','w_MB',...
    'sigma_mb','sigma_ps', 'nll'}; 

headers_fit= {'sub_id', 'AIC'}; 

csvwrite_with_headers('fit_params_sigma_mf.csv', results_SMF, headers_simsA);
csvwrite_with_headers('fit_params_NO_sigma_mf.csv', results_NO_SMF, headers_simsB);
csvwrite_with_headers('AIC_SIGMA_MF.csv', fit_SIGMA_MF, headers_fit);
csvwrite_with_headers('AIC_NO_SIGMA_MF.csv', fit_NO_SIGMA_MF, headers_fit);

end 