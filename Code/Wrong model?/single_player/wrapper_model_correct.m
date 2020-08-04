function wrapper_model_correct()
%generates data using for all the models,

%set up variables 
numSub = 1000;
numRounds = 250; 
numStates = 4; %terminal reward states


%generate rewards 

rews = get_rewards(numRounds, numStates); 

%run them all 
[agents, params] = run_sims_correct_model(numSub, numRounds,rews);  

%save 
header_sims = {'sub_id','c1', 's2', 'c2', 're','trial_n'}; 
header_params = {'sub_id', 'beta','lr','e','ps','w_MB'}; 

csvwrite_with_headers('newdf.agents_correct_model.csv', agents, header_sims);
csvwrite_with_headers('newdf.agents_correct_model_params.csv', params, header_params);

end 