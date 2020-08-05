function [results, store_params] = run_sims(numSubs, numRounds, w_SMB, w_SMF)

results = zeros(numSubs * numRounds, 8);
params = zeros(numSubs, 9);
store_params = zeros(numSubs, 11); %stores params for exporting
results_counter = 0; 
        
%Loop through subjects 
for j=1:numSubs
    
    %match with social agent 
    social_data = sample_social_data();%agent data
    
    %get random params 
    params(j,1) = rand() * 1.8 + .1;%beta softmax
    params(j,2) = rand()/2 + .3;%lr1 from .2 to .7
    params(j,3) = rand(); %elig trace
    params(j,4) = 0; %stickiness
    params(j,5) = rand(); %w_MB
    params(j,6) = w_SMB; %sigma mB 
    params(j,7) = w_SMF; %sigma mf
    params(j,8) = 0; %sigma ps; social stickiness 
    params(j,9) = round(rand(),0) + 1; %turn, 1 = participant, 2 = watching (social)
    
    participant_id = j;
    social_agent_id = unique(social_data(:,9));
   
    %save params 
    store_params(j,:) = cat(2, participant_id, social_agent_id, params(j,:)); 

    %now run simulation 
    disp(['... Simulating Subject: ', num2str(j)]);
    results(results_counter+1:results_counter+numRounds,:) =...
        model(params(j,:),social_data, participant_id, social_agent_id); 
    results_counter = results_counter + numRounds; 
end 

end 