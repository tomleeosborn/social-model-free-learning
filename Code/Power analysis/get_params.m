function [params] = get_params()

%function loads csv with fit_params and outputs params
path = "fit_params_study1.csv";
df = readtable(path);
df = table2array(df);

params = zeros(1,8); 
%indexing columns
sub_id = 1;
beta = 2;
lr = 3;
elig = 4;
ps = 5;
w_mb = 6;
s_mb = 7;
s_mf = 8;
s_ps = 9; 

%find number of subjects
numSubs = length(unique(df(:,sub_id))); 

%randomly choose a participants param to assign 
param_id = randi(numSubs,1); 

%return params
params(1,1) = df(param_id,beta); 
params(1,2) = df(param_id,lr); 
params(1,3) = df(param_id,elig); 
params(1,4) = df(param_id,ps); 
params(1,5) = df(param_id,w_mb); 
params(1,6) = df(param_id,s_mb); 
params(1,7) = df(param_id,s_mf); 
params(1,8) = df(param_id,s_ps);


end 