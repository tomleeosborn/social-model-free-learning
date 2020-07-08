function wrapper()
%generates data using for all the models, i.e. with social mf and social
%mb, with social mf and no social mb, with no social-mf and no social-mb,
%with social mb and no social mf

%set up variables 
numSub = 100;
numRounds = 125; 

%params for model 
beta = rand() * 1.8 + .1;%beta softmax
lr = rand()/2 + .3;%lr1 from .2 to .7
elig = rand();%eligibility trace
w_MB = rand(); 
ps = 0; %stickiness
sigma_ps = 0; %social stickiness 
[params] = [beta, lr, elig, ps, w_MB, sigma_ps];

%run them all 
% [sigma_mf] = run_sims(numSub, numRounds,  params, 0, 1); 
% [sigma_mb] = run_sims(numSub, numRounds, params, 1, 0); 
% [sigma_mb_mf] = run_sims(numSub, numRounds, params, 1,1); 
% [no_sigma_mb_mf] = run_sims(numSub, numRounds, params, 0, 0); 
[all_rand] = run_sims(numSub, numRounds, params, rand(), rand()); 

%save 
headers_sims = {'sub_id', 'turn','c1', 's2', 'c2', 're','trial_n','social_agent_id'}; 
% csvwrite_with_headers('sigma_MF.csv', sigma_mf, headers_sims);
% csvwrite_with_headers('sigma_MB.csv', sigma_mb, headers_sims);
% csvwrite_with_headers('sigma_MFMBF.csv', sigma_mb_mf, headers_sims);
% csvwrite_with_headers('no_sigma.csv', no_sigma_mb_mf, headers_sims);
csvwrite_with_headers('df_sims.csv', no_sigma_mb_mf, headers_sims);
csvwrite_with_headers('df_sims.csv', no_sigma_mb_mf, headers_sims)
end 