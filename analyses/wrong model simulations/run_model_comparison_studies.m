function [results1, results2, aic_correct_model, aic_wrong_model] = ...
    run_model_comparison_studies(df) 
%helper function

%columns for indexing
 sub = 1;
 act1 = 2; 
 state2=3;
 act2= 4;
 reward = 5;
 turn_index = 6; 
 
%find number of subjects
numSubs = length(unique(df(:,sub))); 

%other variables
results1 = zeros(numSubs, 10); 
results2 = zeros(numSubs, 10); 
aic_correct_model = zeros(numSubs, 2); 
aic_wrong_model = zeros(numSubs, 2); 

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
     
     %correct model
     [params1, nll1, ~] = fmincon(@ (params1)...
         nll_correct_social(params1, c1, s2, c2, re, turn),... %does not have ps  
         [1 .5 .5 2 .4 .5 .5 1],[],[],[],[],...
         [.1 0 0 1 0 0 0 1], [1.9 1 1 5 1 1 1 5],[], options); 
    results1(j,:) = cat(2,sub_id,params1, nll1);      
    [aic_1] = aicbic(nll1, 4); 
    aic_correct_model(j,:) = cat(2, sub_id, aic_1); 
     
     %wrong model
     [params2, nll2, ~] = fmincon(@ (params2)...
         nll_wrong_social(params2, c1, s2, c2, re,turn),... %does not have ps  
         [1 .5 .5 2 .4 .5 .5 1],[],[],[],[],...
         [.1 0 0 1 0 0 0 1], [1.9 1 1 5 1 1 1 5],[], options);  
    results2(j,:) = cat(2,sub_id,params2,nll2);      
    [aic_2] = aicbic(nll2, 4); 
    aic_wrong_model(j,:) = cat(2, sub_id, aic_2); 
     
end 

end 