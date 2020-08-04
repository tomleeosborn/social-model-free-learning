function wrapper_model_wrong(w, file)
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

csvwrite_with_headers(file, agents, header_sims);
csvwrite_with_headers('simulations_3_2_wrong_model_params.csv', params, header_params);

end 