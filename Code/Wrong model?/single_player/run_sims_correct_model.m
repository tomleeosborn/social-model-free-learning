function [results, store_params] = run_sims_correct_model(numSubs, numRounds,rews)
   
params = zeros(numSubs, 8);
store_params = zeros(numSubs, 9); %stores params for exporting
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
    sigma_MB = rand();
    sigma_MF = rand();
    sigma_ps = 0; 
    
    params(j,:) = [beta, lr, elig, ps, w_MB, sigma_MB, sigma_MF, sigma_ps];
      
    %save params 
    store_params(j,:) = cat(2, participant_id, params(j,:)); 
    
    turn = (round(rand,0)+1);

    %now run simulation 
    disp(['... Simulating Subject: ', num2str(j)]);
    results(results_counter+1:results_counter+numRounds,:) =...
        model_correct(params(j,:),participant_id, rews, turn); 
    results_counter = results_counter + numRounds; 
end 

end 