function [results] = model_wrong(params, sub_id, rews)

%set up variables
numStates = 5;
numActions = 2;
s1_choices = [1 2];
s2_choices = [1 2];
spaceship1_s2_states = [2 3];
spaceship2_s2_states = [4 5];

%agent params 
beta = params(1); %softmax inverse temp
lr = params(2); %learning rate 1
e = params(3); %eligibility trace
ps = params(4); %stickiness 
w_MB = params(5); %model based weight
w_MF = 1 - w_MB; 

% re1_list = rews(:,1); 
% re2_list = rews(:,2); 
% re3_list = rews(:,3); 
% re4_list = rews(:,4); 

%initialize Q values 
Q_MB = zeros(numStates, numActions); 
Q_MF = zeros(numStates, numActions); 
 

T =  [.8 .2; .2 .8; .2 .8; .8 .2];
N = size(rews,1);

results = zeros(N,7); 
last_participant_action = 0;

%Loop through rounds
for i=1:N
         %model based update
        Q_MB(1,:) = T' * max(Q_MB(2:5,:),[],2);  

        %mix mb and mf
        Qd = w_MB * Q_MB(1,:) + w_MF * Q_MF(1,:);

        %choose action
        weighted_vals = beta * (Qd +...
             ps * (s1_choices==last_participant_action)); 
        probs = exp(weighted_vals) / sum(exp(weighted_vals)); 
        c1 = s1_choices(randsample(2,1, true, probs)); 

        %transition to state 2, agent believes that there are different ...
        %transitition structures depending on choice 1
        if c1 == 1
            s2 = spaceship1_s2_states(randsample(2,1,true, T(c1,:)));
        else 
            s2 = spaceship2_s2_states(randsample(2,1,true, T(c1,:))); 
        end 
         
        %however the actual s2 is different 
        if mod(s2,2)==0
            actual_s2 = 2;
        else 
            actual_s2 = 3;
        end 

        %choose action 2 
        Qd2 = w_MB * Q_MB(s2,:) + w_MF * Q_MF(s2,:); 
        probs2 = exp(beta*Qd2) / sum(exp(beta*Qd2)); 
        c2 = s2_choices(randsample(2,1, true, probs2));

         %get reward 
         if s2 == 2
            if c2 == 1 
                re = rews(i, 1); 
            else 
                re = rews(i, 2); 
            end 
         elseif s2== 3
             if c2 == 1 
                re = rews(i, 3); 
            else 
                re = rews(i, 4); 
             end
         elseif s2 == 4
             if c2 == 1 
                re = rews(i, 5); 
            else 
                re = rews(i, 6); 
             end 
         else 
             if c2 == 1 
                re = rews(i, 7); 
            else 
                re = rews(i, 8); 
            end  
         end 
                 
        
        %update models 
        delta = Q_MF(s2,c2) - Q_MF(1,c1); %sarsa 
        Q_MF(1,c1) = Q_MF(1,c1) + lr * delta; 

        delta = re - Q_MF(s2,c2);  
        Q_MF(s2,c2) = Q_MF(s2,c2) + lr * delta; %update QMF 
        Q_MF(1,c1) = Q_MF(1,c1) + e * lr * delta; %eligibity trace 

        Q_MB(2:3,:) = Q_MF(2:3,:);  %update model based

        last_participant_action = c1;
    
    %store results
    results(i,:) = cat(2, sub_id,  c1, s2, actual_s2, c2, re, i);
end 
end 

