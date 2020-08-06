function wrapper()
%generates data using for all the models, i.e. with social mf and social
%mb, with social mf and no social mb, with no social-mf and no social-mb,
%with social mb and no social mf

%set up variables 
numSub = 250;
numRounds = 125; 


%run them all 
[sigma_mf, sigma_mf_params] = run_sims(numSub, numRounds,0, 1); 
[sigma_mb, sigma_mb_params] = run_sims(numSub, numRounds, 1, 0); 
[sigma_mb_mf, sigma_mb_mf_params] = run_sims(numSub, numRounds, 1,1); 
[no_sigma_mb_mf, no_sigma_mb_mf_params] = run_sims(numSub, numRounds, 0, 0); 
[all_rand, all_rand_params] = run_sims(numSub, numRounds, rand(), rand()); 

%save agent data
headers_sims = {'sub_id', 'turn','c1', 's2', 'c2', 're','trial_n',...
    'social_agent_id'}; 
csvwrite_with_headers('outputs/sims1_sigma_MF.csv', sigma_mf, headers_sims);
csvwrite_with_headers('outputs/sims1_sigma_MB.csv', sigma_mb, headers_sims);
csvwrite_with_headers('outputs/sims1_sigma_MFMB.csv', sigma_mb_mf, headers_sims);
csvwrite_with_headers('outputs/sims1__no_sigma_MFMB.csv', no_sigma_mb_mf, headers_sims);
csvwrite_with_headers('outputs/sims1_random_sigma_MFMB.csv', all_rand, headers_sims)

disp('save agent data'); 

%save agent params
headers_params = {'sub_id','social_agent_id','beta','lr','elig','stickiness',...
    'w_MB', 'sigma_MB', 'sigma_MF', 'sigma_ps','turn'};
csvwrite_with_headers('outputs/sims1_sigma_MF_params.csv', sigma_mf_params, headers_params);
csvwrite_with_headers('outputs/sims1_sigma_MB_params.csv', sigma_mb_params, headers_params);
csvwrite_with_headers('outputs/sims1_sigma_MFMB_params.csv', sigma_mb_mf_params, headers_params);
csvwrite_with_headers('outputs/sims1__no_sigma_MFMB_params.csv', no_sigma_mb_mf_params, headers_params);
csvwrite_with_headers('outputs/sims1_random_sigma_MFMB_params.csv', all_rand_params, headers_params)

disp('save agent params'); 

disp('ALL DONE');

end 