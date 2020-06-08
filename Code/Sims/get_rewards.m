function [results] =  get_rewards(numRounds, rewardStates)

%function recieves number of rounds and terminal reward states i.e. 4 or 6 and
%generates rewards that shift according to stdShift variable
    
    %set up variable
    stdShift = 2; 
    rewardRange_hi = 5;
    rewardRange_lo = -5;
    rewards = zeros(numRounds, rewardStates);
    results = zeros(numRounds, rewardStates); 
    
    %generate rewards 
    rewards(1,:) = randsample(rewardRange_lo : rewardRange_hi, rewardStates, true);
    results(1,:) = rewards(1,:);
    for thisRound=1:(numRounds-1)
      re = rewards(thisRound, 1:rewardStates) +...
            round(randn(rewardStates,1)' * stdShift); 
      re(re>rewardRange_hi) = 2 * rewardRange_hi - re(re > rewardRange_hi);
      re(re < rewardRange_lo) = 2 * rewardRange_lo - re(re < rewardRange_lo);
      rewards(thisRound + 1, 1:rewardStates) = re; 
      %save
      results(thisRound + 1,:) = rewards(thisRound + 1,:);
    end 
          
end 