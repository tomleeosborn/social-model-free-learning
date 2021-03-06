function [results] = sample_social_data()
%FUNCTION SAMPLES SOCIAL AGENT DATA FROM ACTUAL DATA IN STUDY 1

%Load csv with data

path = '../../data/cleaned/study_1_single_player_data.csv';
df = readtable(path);
df = table2array(df);

numRounds = 125;

%variables for indexing data
user_id =1;
action1 = 2;
state2 = 3;
action2 = 4;
reward = 5;
rew1 = 6;
rew2 = 7;
rew3 = 8;
rew4 = 9; 

social_data = zeros(numRounds, 9); 

%find number of subjects
numSubs = length(unique(df(:,user_id))); 

%bad agents (timed_out)

%randomly choose participant
assigned_id = randsample(numSubs, 1);

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