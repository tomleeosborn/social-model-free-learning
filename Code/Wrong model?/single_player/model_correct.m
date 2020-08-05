function [results] = model_correct(params, sub_id,rews, turn)

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
sigma_MB = params(6);
sigma_MF = params(7);
sigma_ps = params(8); 

re1_list = rews(:,1); 
re2_list = rews(:,2); 
re3_list = rews(:,3); 
re4_list = rews(:,4); 


%initialize Q values 
Q_MB = zeros(numStates, numActions); 
Q_MF = zeros(numStates, numActions); 
 

T =  [.8 .2; .2 .8];
N = size(rews,1);

results = zeros(N,7); 
 
last_participant_action = 0;
last_social_action = 0;

%Loop through rounds
for i=1:N
    
    if turn == 1 
         %model based update 
        Q_MB(1,:) = T' * max(Q_MB(2:3,:),[],2); 

        %mix mb and mf
        Qd = w_MB * Q_MB(1,:) + w_MF * Q_MF(1,:);

        %choose action
        weighted_vals = beta * (Qd +...
             ps * (s1_choices==last_participant_action) + ... %add stickiness
             sigma_ps * (s1_choices==last_social_action)); %add social stickiness
        probs = exp(weighted_vals) / sum(exp(weighted_vals)); 
        c1 = s1_choices(randsample(2,1, true, probs)); 

        %transition 
        s2 = states(randsample(2,1,true,T(c1,:))); 

        %choose action 2
        Qd2 = w_MB * Q_MB(s2,:) + w_MF * Q_MF(s2,:); 
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
   
        %update algorithms
        delta = Q_MF(s2,c2) - Q_MF(1,c1); %sarsa 
        Q_MF(1,c1) = Q_MF(1,c1) + lr * delta; 

        delta = re - Q_MF(s2,c2);  
        Q_MF(s2,c2) = Q_MF(s2,c2) + lr * delta; %update QMF 
        Q_MF(1,c1) = Q_MF(1,c1) + e * lr * delta; %eligibity trace 

        Q_MB(s2, c2) =  Q_MB(s2, c2) + lr *...
        (re - Q_MB(s2, c2)); 
        

        last_participant_action = c1; 
        
    else
        %social agents behaves randomle
        c1 = s1_choices(randsample(2,1, true, [.5 .5]));  
        s2 = states(randsample(2,1,true,T(c1,:))); 
        c2 = s2_choices(randsample(2,1, true, [.5 .5]));  
        
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
   
        %update algorithms
        delta = Q_MF(s2,c2) - Q_MF(1,c1); %sarsa 
        Q_MF(1,c1) = Q_MF(1,c1) + lr * delta * sigma_MF; 

        delta = re - Q_MF(s2,c2);  
        Q_MF(s2,c2) = Q_MF(s2,c2) + lr * delta * sigma_MF; %update QMF 
        Q_MF(1,c1) = Q_MF(1,c1) + e * lr * delta * sigma_MF; %eligibity trace 

        Q_MB(s2, c2) =  Q_MB(s2, c2) + lr *...
        (re - Q_MB(s2, c2)) * sigma_MB;
        
        last_social_action = c1; 
        
    end
    %store results
    results(i,:) = cat(2, sub_id, c1, s2, c2, re, i, turn);
    %change turn
    if turn==1 
        turn = 2;
    else 
        turn = 1;
    end 
end 
end 

