function [results] = model(params, data, sub_id, social_id)

%set up variables
numStates = 3;
numActions = 2;
s1_choices = [1 2];
s2_choices = [1 2];
states = [2 3];

%load social data to be used for social turns 
c1_list = data(:,1);
s2_list = data(:,2);
c2_list= data(:,3);
re_list = data(:,4); 
re1_list = data(:,5); 
re2_list = data(:,6); 
re3_list = data(:,7); 
re4_list = data(:,8); 

%agent params 
beta = params(1); %softmax inverse temp
lr = params(2); %learning rate 1
e = params(3); %eligibility trace
ps = params(4); %stickiness 
w_MB = params(5); %model based weight
w_MF = 1 - w_MB; 
sigma_MB = params(6); %social learning model based weight (emulation)
sigma_MF = params(7); 
sigma_ps = params(8); %social learning stickiness (imitation)
turn = params(9); 

%initialize Q values 
Q_MB = zeros(numStates, numActions); 
Q_MF = zeros(numStates, numActions); 
likelihood = 0; 
%last_social_action = 0; 
%last_participant_action = 0; 

T =  [.8 .2; .8 .2];
N = size(c1_list,1);

results = zeros(N,8); 
last_social_action = 0; 
last_participant_action = 0;

%Loop through rounds
for i=1:N
    if turn==1 %participant turns 
         %model based update 
        Q_MB(1,:) = T' * max(Q_MB(2:3,:),[],2); 

        %mix mb and mf
        Qd = w_MB * Q_MB(1,:) + w_MF * Q_MF(1,:);

        %choose action
        weighted_vals = beta * (Qd +...
             ps * (s1_choices==last_participant_action) + ...
             sigma_ps * (s1_choices==last_social_action));
        probs = exp(weighted_vals) / sum(exp(weighted_vals)); 
        c1 = s1_choices(randsample(2,1, true, probs)); 

        %update likelihood 
        likelihood = likelihood + log(probs(s1_choices==c1)); 

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
   
        %update likelihood
        likelihood = likelihood + log(probs2(s2_choices==c2)); 

        %update algorithms
        delta = max(Q_MF(s2,:)) - Q_MF(1,c1);
        Q_MF(1,c1) = Q_MF(1,c1) + lr * delta; 

        delta = re - Q_MF(s2,c2);  
        Q_MF(s2,c2) = Q_MF(s2,c2) + lr * delta; %update QMF 
        Q_MF(1,c1) = Q_MF(1,c1) + e * lr * delta; %eligibity trace 

        Q_MB(s2,c2) = Q_MB(s2,c2) + (re - Q_MB(s2,c2)) * lr;  %update model based

        last_participant_action = c1; 

    else %social (watching) turns

        %load data
        c1 = c1_list(i);
        s2 = s2_list(i);
        c2 = c2_list(i);
        re = re_list(i); 

        %Update algorithms 
        delta = max(Q_MF(s2, :)) - Q_MF(1, c1); %Q learning 
        Q_MF(1, c1) = Q_MF(1, c1) + lr * delta * sigma_MF; 

        delta = re - Q_MF(s2, c2); 
        Q_MF(s2, c2) =  Q_MF(s2, c2) + lr * delta * sigma_MF;  
        Q_MF(1, c1) = Q_MF(1, c1) + e * lr * delta * sigma_MF; %add MF social learning 

        %update model based
        Q_MB(s2, c2) =  Q_MB(s2, c2) + lr * (re - Q_MB(s2, c2)) * sigma_MB;
  
       last_social_action = c1; 

    end 
    
    %store results
    results(i,:) = cat(2, sub_id, turn, c1, s2, c2, re, i, social_id);

    %switch turns
    if turn==1
        turn = 2;
    else 
        turn = 1;
    end 
end 
end 

