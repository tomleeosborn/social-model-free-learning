function [results] = run_power_sims(numSubs, numRounds)

store_params = zeros(numSubs, 11); %stores params for exporting
results_counter = 0; 
        
%Loop through subjects 
for j=1:numSubs
    
    %match with social agent 
    social_data = sample_social_data();%agent data
    
    %get params to use for model generations 
    [params] = get_params(); 
    
    turn = 1; % round(rand(),0) + 1; %turn, 1 = participant, 2 = watching (social)
    participant_id = j;
    social_agent_id = unique(social_data(:,9));
   
    %save params 
    store_params(j,:) = cat(2, participant_id, social_agent_id, turn, params(1,:)); 

    %now run simulation 
    disp(['... Simulating Subject: ', num2str(j)]);
    results(results_counter+1:results_counter+numRounds,:) =...
        model(params(1,:),social_data, turn, participant_id, social_agent_id); 
    results_counter = results_counter + numRounds; 
end 

end 