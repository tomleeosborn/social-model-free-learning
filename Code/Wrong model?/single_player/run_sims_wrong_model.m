function [results, store_params] = run_sims_wrong_model(numSubs, numRounds,rews)
   
params = zeros(numSubs, 5);
store_params = zeros(numSubs, 6); %stores params for exporting
results_counter = 0; 
        
%Loop through subjects 
for j=1:numSubs
    
    participant_id = j; 
    
    %generate params 
    beta = rand() * 1.8 + .1;%beta softmax
    lr = rand()/2 + .3;%lr1 from .2 to .7
    elig = rand();%eligibility trace
    w_MB = rand(); 
    ps = 0; %stickiness
    
    params(j,:) = [beta, lr, elig, ps, w_MB];
      
    %save params 
    store_params(j,:) = cat(2, participant_id, params(j,:)); 

    %now run simulation 
    disp(['... Simulating Subject: ', num2str(j)]);
    results(results_counter+1:results_counter+numRounds,:) =...
        model_wrong_updated(params(j,:),participant_id, rews); 
    results_counter = results_counter + numRounds; 
end 

end 