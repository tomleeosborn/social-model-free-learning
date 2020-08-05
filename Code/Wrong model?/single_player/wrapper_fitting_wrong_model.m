function wrapper_fitting_wrong_model(file)
%wrapper: Wrapper function that calculates negative loglikelihoods and
%AIC scores for different models

%load data
path = file; %data
df = readtable(path);
df = table2array(df);

%columns for indexing
 sub = 1;
 act1 = 2; 
 state2=3;
 act2= 4;
 reward = 5;
%  trial_index = 6;  
 turn_index = 7;
 
%find number of subjects
numSubs = length(unique(df(:,sub))); 

%other variables
results1 = zeros(numSubs, 8); 
results2 = zeros(numSubs, 8); 
% fit_SIGMA_MF = zeros(numSubs, 2); 
% fit_NO_SIGMA_MF = zeros(numSubs, 2); 

%Loop through number of subjects
for j=1:numSubs
     c1 = df(df(:,1)==j,act1); %choice 1  
     s2 = df(df(:,1)==j,state2); %actual state 2 
     c2 = df(df(:,1)==j,act2); %action 2 
     re = df(df(:,1)==j,reward); %reward 
%      trial_n = df(df(:,1)==j,trial_index); %turn 
     turn = df(df(:,1)==j,turn_index); %reward 
     sub_id = df(df(:,1)==j,sub); %sub_id
     sub_id = unique(sub_id(:));
     
     
     %optimization functions 
     options = optimoptions('fmincon', 'Display', 'off');
     disp(['... Subject: ', num2str(j)]);
     
     %correct model
     [params1, nll1, ~] = fmincon(@ (params1)...
         nll_correct(params1, c1, s2, c2, re, turn),... %does not have ps  
         [1 .5 .5 .4 .5 .5],[],[],[],[],...
         [.1 .2 0 0 0 0], [1.9 .7 1 1 1 1],[], options);  
    results1(j,:) = cat(2,sub_id,params1, nll1);      
    [aic_1] = aicbic(nll1, 4); 
    aic_correct_model(j,:) = cat(2, sub_id, aic_1); 
     
     %wrong model
     [params2, nll2, ~] = fmincon(@ (params2)...
         nll_wrong(params2, c1, s2, c2, re, turn),... %does not have ps  
          [1 .5 .5 .4 .5 .5],[],[],[],[],...
         [.1 .2 0 0 0 0], [1.9 .7 1 1 1 1],[], options);
    results2(j,:) = cat(2,sub_id,params2,nll2);      
    [aic_2] = aicbic(nll2, 4); 
    aic_wrong_model(j,:) = cat(2, sub_id, aic_2); 
     
end 

%save
header_params = {'sub_id', 'beta','lr','e','w_MB',...
    'sigma_MB','sigma_MF','nll'}; 
header_aic= {'sub_id', 'AIC'}; 

csvwrite_with_headers('simulations_3_2_fit_params_correct_model.csv', ...
    results1, header_params);
csvwrite_with_headers('simulations_3_2_fit_params_wrong_model.csv',...
    results2, header_params);

csvwrite_with_headers('AIC_simulations_3_2_correct_model.csv',...
    aic_correct_model, header_aic);
csvwrite_with_headers('AIC_simulations_3_2_wrong_model.csv',...
    aic_wrong_model, header_aic);

end 