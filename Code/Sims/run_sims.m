function [results] = run_sims(numSubs, numRounds, sub_params, w_SMB, w_SMF)
   
params = zeros(numSubs, 9);
store_params = zeros(numSubs, 11); %stores params for exporting
results_counter = 0; 
        
%Loop through subjects 
for j=1:numSubs
    
    %match with social agent 
    social_data = sample_social_data();%agent data
    
    %generate params 
    params(j,1) = sub_params(1);%beta softmax
    params(j,2) = sub_params(2);%lr1 from .2 to .7
    params(j,3) = sub_params(3);%eligibility trace
    params(j,4) = sub_params(4); % ps stickiness
    params(j,5) = sub_params(5);%model based weight
    params(j,6) = w_SMB; %social learning model based
    params(j,7) = w_SMF; %sigma_mf
    params(j,8) =  sub_params(6); %social learning stickiness
    params(j,9) = 1; % round(rand(),0) + 1; %turn, 1 = participant, 2 = watching (social)

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