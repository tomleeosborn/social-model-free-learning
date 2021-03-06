function [results] = model_wrong(params, sub_id, rews, turn)

%set up variables
numStates = 3;
numActions = 2;
s1_choices = [1 2];
s2_choices = [1 2];
s2_states = [2 3];


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

%initialize Q values 
Q_MB = zeros(numStates, numActions * 2); 
Q_MF = zeros(numStates, numActions * 2); 
 

T =  [.8 .2; .2 .8];
N = size(rews,1);

results = zeros(N,7); 

last_participant_action = 0;
last_social_action = 0; 

%Loop through rounds
for i=1:N
    
    if turn == 1
         %model based update
        Q_MB(1,[1 2]) = T' * max(Q_MB(2:3,:),[],2);  

        %mix mb and mf
        Qd = w_MB * Q_MB(1,1:2) + w_MF * Q_MF(1,1:2);

        %choose action
        weighted_vals = beta * (Qd +...
             ps * (s1_choices==last_participant_action) + ... %add stickiness
             sigma_ps * (s1_choices==last_social_action));
        probs = exp(weighted_vals) / sum(exp(weighted_vals)); 
        c1 = s1_choices(randsample(2,1, true, probs)); 

        %transition to state 2, agent believes that there are different ...
        %transitition structures depending on choice 1
        s2 = s2_states(randsample(2,1,true, T(c1,:))); 
         
        %choose action 2 
        if s2 == 2 
            Qd2 = w_MB * Q_MB(s2,[1 3]) + w_MF * Q_MF(s2, [1 3]);
        else 
            Qd2 = w_MB * Q_MB(s2,[2 4]) + w_MF * Q_MF(s2, [2 4]);
        end  
        probs2 = exp(beta*Qd2) / sum(exp(beta*Qd2)); 
        c2 = s2_choices(randsample(2,1, true, probs2));

         %get reward
         
         if c1 == 1
             if s2 == 2
                 if c2 == 1 
                     re = rews(i,1); 
                 else 
                     re = rews(i,2);
                 end 
             else 
                 if c2 == 1 
                     re = rews(i,3); 
                 else 
                     re = rews(i,4);
                 end 
             end 
         else 
             if s2 == 2
                 if c2 == 1 
                     re = rews(i,5); 
                 else 
                     re = rews(i,6);
                 end 
             else 
                 if c2 == 1 
                     re = rews(i,7); 
                 else 
                     re = rews(i,8);
                 end 
             end 
         end 
        
         %update models 
         if c1 == 1 
             delta = Q_MF(s2,c2) - Q_MF(1,c1); %sarsa 
         else 
             delta = Q_MF(s2,c2+2) - Q_MF(1,c1); 
         end 
        Q_MF(1,c1) = Q_MF(1,c1) + lr * delta; 

        if c1 == 1 
            delta = re - Q_MF(s2,c2);  
            Q_MF(s2,c2) = Q_MF(s2,c2) + lr * delta;
            Q_MB(s2,c2) = Q_MB(s2,c2) + lr * delta;
        else 
            delta = re - Q_MF(s2,c2+2);
            Q_MF(s2,c2+2) = Q_MF(s2,c2+2) + lr * delta;
            Q_MB(s2,c2+2) = Q_MB(s2,c2+2) + lr * delta;
        end   
        Q_MF(1,c1) = Q_MF(1,c1) + e * lr * delta; %eligibity trace 

        last_participant_action = c1;
    else 
        c1 = s1_choices(randsample(2,1, true, [.5 .5]));
        s2 = s2_states(randsample(2,1,true, T(c1,:)));
        c2 = s2_choices(randsample(2,1, true, [.5 .5]));
        
           %get reward
         
         if c1 == 1
             if s2 == 2
                 if c2 == 1 
                     re = rews(i,1); 
                 else 
                     re = rews(i,2);
                 end 
             else 
                 if c2 == 1 
                     re = rews(i,3); 
                 else 
                     re = rews(i,4);
                 end 
             end 
         else 
             if s2 == 2
                 if c2 == 1 
                     re = rews(i,5); 
                 else 
                     re = rews(i,6);
                 end 
             else 
                 if c2 == 1 
                     re = rews(i,7); 
                 else 
                     re = rews(i,8);
                 end 
             end 
         end 
         
          %update models 
         if c1 == 1 
             delta = Q_MF(s2,c2) - Q_MF(1,c1); %sarsa 
         else 
             delta = Q_MF(s2,c2+2) - Q_MF(1,c1); 
         end 
        Q_MF(1,c1) = Q_MF(1,c1) + lr * delta * sigma_MF; 

        if c1 == 1 
            delta = re - Q_MF(s2,c2);  
            Q_MF(s2,c2) = Q_MF(s2,c2) + lr * delta * sigma_MF;
            Q_MB(s2,c2) = Q_MB(s2,c2) + lr * delta * sigma_MB;
        else 
            delta = re - Q_MF(s2,c2+2);
            Q_MF(s2,c2+2) = Q_MF(s2,c2+2) + lr * delta * sigma_MF;
            Q_MB(s2,c2+2) = Q_MB(s2,c2+2) + lr * delta * sigma_MB;
        end   
        Q_MF(1,c1) = Q_MF(1,c1) + e * lr * delta * sigma_MF; %eligibity trace 
        
        last_social_action = c1; 
        
    end 
    
    %store results
    results(i,:) = cat(2, sub_id,  c1, s2, c2, re, i, turn);
    %change turn
    if turn==1 
        turn = 2;
    else 
        turn = 1;
    end 
end 
end 

