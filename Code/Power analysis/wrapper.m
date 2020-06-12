function wrapper()
%generates data using for all the models, i.e. with social mf and social
%mb, with social mf and no social mb, with no social-mf and no social-mb,
%with social mb and no social mf

%set up variables 
numSub = 100;
numRounds = 125; 

%get data

[data] = run_power_sims(numSub, numRounds);  

%save 
headers_sims = {'sub_id', 'turn','c1', 's2', 'c2', 're','trial_n','social_agent_id'}; 
csvwrite_with_headers('sim_data.csv', data, headers_sims);

end 

