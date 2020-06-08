function [results] = generate_social_agent(numRounds, rewardStates)
%generate_social_agent: Function that generates random data for a social agent 
%
% INPUTS:   numRounds -> number of trials
%          rewardStates -> number of terminal reward states
%       
% OUTPUT: REWARDS (agent choice and rewards)
%set up variables 
s1_choices = [1 2];
s2_choices = [1 2]; 
states = [2 3];
T =  [.7 .3; .3 .7];
rews = get_rewards(numRounds,rewardStates); %rewards
results = zeros(numRounds,9);

for i=1:numRounds

    c1 = s1_choices(randsample(2,1)); 
    s2 = states(randsample(2,1,true,T(c1,:)));  
    c2 = s2_choices(randsample(2,1));

    %get reward 
    if s2 == 2 
           re = rews(i,c2);
    else 
           re = rews(i, c2+2);
    end

    %save results
    results(i,:)  = cat(2, c1, s2, c2, re,...
    i, rews(i,1),rews(i,2), rews(i,3), rews(i,4)); 
end 

    results(i,:)  =  cat(2, c1, s2, c2, re, i,...
    rews(i,1),rews(i,2), rews(i,3), rews(i,4));

end 