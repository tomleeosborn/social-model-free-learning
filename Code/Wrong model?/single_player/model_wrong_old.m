function [results] = model_wrong(params, sub_id, rews)

%set up variables
numStates = 3;
numActions = 2;
s1_choices = [1 2];
s2_choices = [1 2];
states = [2 3];

%agent params 
beta = params(1); %softmax inverse temp
lr = params(2); %learning rate 1
e = params(3); %eligibility trace
ps = params(4); %stickiness 
w_MB = params(5); %model based weight
w_MF = 1 - w_MB; 

re1_list = rews(:,1); 
re2_list = rews(:,2); 
re3_list = rews(:,3); 
re4_list = rews(:,4); 

%initialize Q values 
Qmf1 = zeros(1,numActions); %q_Mf value for state 1
Qmb1 = zeros(1,numActions);
Q_MB = zeros(numStates, numActions * 2); 
Q_MF = zeros(numStates, numActions * 2); 

% likelihood = 0;  

T =  [.8 .2; .2 .8; .8 .2; .2 .8];
N = size(rews,1);

results = zeros(N,6); 
last_participant_action = 0;

%Loop through rounds
for i=1:N
         %model based update 
        Qmb1(1,:) = max(T' .* max(Q_MB(2:3,:),[],2),[],2); %ask fiery about this

        %mix mb and mf
        Qd = w_MB * Qmb1 + w_MF * Qmf1;

        %choose action
        weighted_vals = beta * (Qd +...
             ps * (s1_choices==last_participant_action)); 
        probs = exp(weighted_vals) / sum(exp(weighted_vals)); 
        c1 = s1_choices(randsample(2,1, true, probs)); 

        %update likelihood 
        %likelihood = likelihood + log(probs(s1_choices==c1)); 

        %transition 
        s2 = states(randsample(2,1,true,T(c1,:))); 

        %choose action 2
        if c1 == 1 %they are assinging value to space ship
            Qd2 = w_MB * Q_MB(s2,1:2) + w_MF * Q_MF(s2,1:2); 
        else 
            Qd2 = w_MB * Q_MB(s2,3:4) + w_MF * Q_MF(s2,3:4); 
        end 
        probs2 = exp(beta*Qd2) / sum(exp(beta*Qd2)); 
        c2 = s2_choices(randsample(2,1, true, probs2));

         %get reward 
        if s2==2 
            if c2 == 1 
                re = re1_list(i);
            else 
                re = re2_list(i);
            end 
        else 
            if c2 == 1
                re = re3_list(i);
            else 
                re = re4_list(i);
            end 
        end
   
        %update likelihood
        %likelihood = likelihood + log(probs2(s2_choices==c2)); 

        %update algorithms (here becuase they use a wrong model, they
        %assign weights to different indices
        
        
        if c1 == 1 %if they used the first spaceship
            delta = Q_MF(s2, c2) - Qmf1(1,c1); 
            Qmf1(1,c1) = Qmf1(1,c1) + lr * delta; 
            
            delta = re - Q_MF(s2,c2);  
            Q_MF(s2,c2) = Q_MF(s2,c2) + lr * delta; %update QMF 
            Qmf1(1,c1) = Qmf1(1,c1) + e * lr * delta ; %eligibity trace 
  
        else %if they used the second  spaceship 
            delta = Q_MF(s2, c2+2) - Qmf1(1,c1); 
            Qmf1(1,c1)  = Qmf1(1,c1) + lr * delta; 
            
            delta = re - Q_MF(s2,c2+2);  
            Q_MF(s2,c2+2) = Q_MF(s2,c2+2) + lr * delta; %update QMF 
            Qmf1(1,c1) = Qmf1(1,c1) + e * lr * delta ; %eligibity trace
        end 
 
        Q_MB(2:3,:) = Q_MF(2:3,:);  %update model based

        last_participant_action = c1; 
    
    %store results
    results(i,:) = cat(2, sub_id,  c1, s2, c2, re, i);
end 
end 

