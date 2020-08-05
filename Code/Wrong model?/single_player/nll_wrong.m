function likelihood = nll_wrong(params, c1, s2, c2, re, turn)

%set up variables
numStates = 3;
numActions = 2;
s1_choices = [1 2];


%agent params 
beta = params(1); %softmax inverse temp
lr = params(2); %learning rate 1
e = params(3); %ligibility trace
ps = 0; %stickiness 
w_MB = params(4); %model based weight
w_MF = 1 - w_MB; 
sigma_MB = params(5); %social learning model based weight (emulation)
sigma_MF = params(6); 
sigma_ps = 0;  %

%initialize Q values 
Q_MB = zeros(numStates, numActions * 2); 
Q_MF = zeros(numStates, numActions * 2); 

T =  [.8 .2; .2 .8];
N = size(c1,1);
 
last_participant_action = 0;
last_social_action = 0;

likelihood = 0;
%Loop through trials
for i=1:N
    
    if turn(i) == 1
         
        %SKIP WHEN TIMEOUT 
         if (c1(i) <1)
            continue
        end 

        if (c2(i) <1)
            continue
        end 


        if (s2(i) <1)
            continue
        end 
        
        %model based update 
        Q_MB(1,[1 2]) = T' * max(Q_MB(2:3,:),[],2);

        %mix mb and mf
        Qd = w_MB * Q_MB(1,1:2) + w_MF * Q_MF(1,1:2);
        
        weighted_vals = beta * (Qd +...
            ps * (s1_choices==last_participant_action) + ... %add stickiness
            sigma_ps * (s1_choices==last_social_action)); %add social stickiness

        %update likelihood 
        likelihood = likelihood + weighted_vals(c1(i)) - ...
            log(sum(exp(weighted_vals))); 
        
        if s2 == 2 
            Qd2 = w_MB * Q_MB(s2(i),[1 3]) + w_MF * Q_MF(s2(i), [1 3]);
        else 
            Qd2 = w_MB * Q_MB(s2(i),[2 4]) + w_MF * Q_MF(s2(i), [2 4]);
        end 
        
        likelihood = likelihood + beta * Qd2(c2(i)) -...
            log(sum(exp(beta * Qd2)));
      
%         if c1(i) == 1
%             likelihood = likelihood + beta * Q_MF(s2(i), c2(i)) -...
%             log(sum(exp(beta * Q_MF(s2(i),[1 2]))));
%         else 
%             likelihood = likelihood + beta * Q_MF(s2(i), c2(i)+2) -...
%             log(sum(exp(beta * Q_MF(s2(i),[3 4]))));
%         end 

        %update algorithms
        if c1(i) == 1 
           delta = Q_MF(s2(i), c2(i)) - Q_MF(1,c1(i)); %sarsa 
        else 
           delta = Q_MF(s2(i), c2(i)+2) - Q_MF(1,c1(i));  
        end 
        Q_MF(1,c1(i)) = Q_MF(1,c1(i)) + lr * delta;  
        
        if c1(i)==1 
            delta = re(i) - Q_MF(s2(i), c2(i)); 
            Q_MF(s2(i), c2(i)) =  Q_MF(s2(i), c2(i)) + lr * delta; 
            Q_MB(s2(i), c2(i)) =  Q_MB(s2(i), c2(i)) + lr * delta;
        else
            delta = re(i) - Q_MF(s2(i), c2(i)+2); 
            Q_MF(s2(i), c2(i)+2) =  Q_MF(s2(i), c2(i)+2) + lr * delta; 
            Q_MB(s2(i), c2(i)+2) =  Q_MB(s2(i), c2(i)+2) + lr * delta;
        end 
        Q_MF(1,c1(i)) = Q_MF(1,c1(i)) + e * lr * delta;
        
        
         %update model based
        Q_MB(2:3,:) = Q_MF(2:3,:);

        last_participant_action = c1(i);
    else
         %update algorithms
        if c1(i) == 1 
           delta = Q_MF(s2(i), c2(i)) - Q_MF(1,c1(i)); %sarsa 
        else 
           delta = Q_MF(s2(i), c2(i)+2) - Q_MF(1,c1(i));  
        end 
        Q_MF(1,c1(i)) = Q_MF(1,c1(i)) + lr * delta * sigma_MF;  
        
        if c1(i)==1 
            delta = re(i) - Q_MF(s2(i), c2(i)); 
            Q_MF(s2(i), c2(i)) =  Q_MF(s2(i), c2(i)) + lr * delta * sigma_MF;
            Q_MB(s2(i), c2(i)) =  Q_MB(s2(i), c2(i)) + lr * delta * sigma_MB; 
        else
            delta = re(i) - Q_MF(s2(i), c2(i)+2); 
            Q_MF(s2(i), c2(i)+2) =  Q_MF(s2(i), c2(i)+2) + lr * delta * sigma_MF;
            Q_MB(s2(i), c2(i)+2) =  Q_MB(s2(i), c2(i)+2) + lr * delta * sigma_MB; 
        end 
        Q_MF(1,c1(i)) = Q_MF(1,c1(i)) + e * lr * delta;
        
       last_social_action = c1(i); 
    end      

end 

likelihood = -likelihood;
end 