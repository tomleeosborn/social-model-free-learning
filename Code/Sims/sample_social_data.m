function [results] = sample_social_data()
%FUNCTION SAMPLES SOCIAL AGENT DATA FROM ACTUAL DATA IN STUDY 1

%Load csv with data

path = "study_1_single_player_data.csv"; 
df = readtable(path);
df = table2array(df);

%bad agents ids to exclude (timed out)
bad.df =  readtable('bad_agents.csv');
bad.df = table2array(bad.df);

numRounds = 250;

%variables for indexing data
user_id =1;
action1 = 3;
action2 = 5;
state2 = 8;
reward = 6;
rew1 = 9;
rew2 = 10;
rew3 = 11;
rew4 = 12; 
social_data = zeros(numRounds, 8); 
%find number of subjects
numSubs = length(unique(df(:,user_id))); 

%bad agents (timed_out)

%randomly choose participant
assigned_id = randsample(numSubs, 1);

%check if bad id

while ismember(assigned_id,bad.df)
    assigned_id = randsample(numSubs, 1);
end 

agent_data = df(df(:,user_id)==assigned_id,:); %load social data


%load data
social_data(:,1) = agent_data(:,action1); %choice1
social_data(:,2) = agent_data(:,state2); %state 2
social_data(:,3) = agent_data(:,action2); %choice 2
social_data(:,4) = agent_data(:,reward); %rewards
social_data(:,5) = agent_data(:,rew1); %terminal reward 1
social_data(:,6) = agent_data(:,rew2); %terminal reward 2
social_data(:,7) = agent_data(:,rew3); %terminal reward 3
social_data(:,8) = agent_data(:,rew4); %terminal reward 4  
social_data(:,9) = assigned_id;

results = social_data;     

end 