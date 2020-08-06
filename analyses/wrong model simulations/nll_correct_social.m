function likelihood = nll_correct_social(params, c1, s2, c2, re,turn)

%set up variables
numStates = 3;
numActions = 2;
s1_choices = [1 2];

%agent params 
beta = params(1); %softmax inverse temp
lr = params(2); %learning rate 1
e = params(3); %ligibility trace
ps = params(4); %stickiness 
w_MB = params(5); %model based weight
w_MF = 1 - w_MB; 
sigma_MB = params(6); %social learning model based weight (emulation)
sigma_MF = params(7); 
sigma_ps = params(8);  %


%initialize Q values 
Q_MB = zeros(numStates, numActions); 
Q_MF = zeros(numStates, numActions); 

T =  [.8 .2; .2 .8];
N = size(c1,1);
 
last_participant_action = 0;
last_social_action = 0;

likelihood = 0; 

%Loop through trials
for i=1:N 
    
    if turn(i)==1 % agent turn
         
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
        Q_MB(1,:) = T' * max(Q_MB(2:3,:),[],2); 

        %mix mb and mf
          Qd = w_MB * Q_MB(1,:) + w_MF * Q_MF(1,:);
        
         weighted_vals = beta * (Qd +...
             ps * (s1_choices==last_participant_action) + ... %add stickiness
             sigma_ps * (s1_choices==last_social_action)); %add social stickiness

        %update likelihood 
        likelihood = likelihood + weighted_vals(c1(i)) - ...
            log(sum(exp(weighted_vals))); 
%         likelihood = likelihood + beta * Q_MF(s2(i), c2(i)) -...
%             log(sum(exp(beta * Q_MF(s2(i),:))));
        Qd2 = w_MB * Q_MB(s2(i),:) + w_MF * Q_MF(s2(i),:);
        likelihood = likelihood + beta * Qd2(c2(i)) - ...
            log(sum(exp(beta * Qd2)));

        %update algorithms
        delta = Q_MF(s2(i), c2(i))- Q_MF(1, c1(i));
        Q_MF(1, c1(i)) = Q_MF(1, c1(i)) + lr * delta;

        delta = re(i) - Q_MF(s2(i), c2(i)); 
        Q_MF(s2(i), c2(i)) =  Q_MF(s2(i), c2(i)) + lr * delta; 
        Q_MF(1, c1(i)) = Q_MF(1, c1(i)) + e * lr * delta; 

        %update model based
        Q_MB(s2(i), c2(i)) =  Q_MB(s2(i), c2(i)) + lr *...
            (re(i) - Q_MB(s2(i), c2(i))); 

        last_participant_action = c1(i);
        
    else 
        %Update algorithms 
        delta = Q_MF(s2(i), c2(i))- Q_MF(1, c1(i));
        Q_MF(1, c1(i)) = Q_MF(1, c1(i)) + lr * delta * sigma_MF;

        delta = re(i) - Q_MF(s2(i), c2(i)); 
        Q_MF(s2(i), c2(i)) =  Q_MF(s2(i), c2(i)) + lr * delta * sigma_MF; 
        Q_MF(1, c1(i)) = Q_MF(1, c1(i)) + e * lr * delta * sigma_MF;

        %update model based
        Q_MB(s2(i), c2(i)) =  Q_MB(s2(i), c2(i)) + lr *...
            (re(i) - Q_MB(s2(i), c2(i))) * sigma_MB;
        
        last_social_action = c1(i); 
    end 

end 
likelihood = -likelihood;
end 