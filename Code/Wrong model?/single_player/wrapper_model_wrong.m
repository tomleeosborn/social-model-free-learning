function wrapper_model_wrong(w, file1, file2)
%generates data using for all the models, w is model-based weight

%set up variables 
numSub = 1000;
numRounds = 250; 
numStates = 8; %terminal reward states


%generate rewards 

rews = get_rewards(numRounds, numStates); 

%run them all 
[agents, params] = run_sims_wrong_model(numSub, numRounds,rews,w);  

%save 
header_sims = {'sub_id','c1', 's2', 'c2', 're','trial_n'}; 
header_params = {'sub_id', 'beta','lr','e','ps','w_MB'}; 

csvwrite_with_headers(file1, agents, header_sims);
csvwrite_with_headers(file2, params, header_params);

end 