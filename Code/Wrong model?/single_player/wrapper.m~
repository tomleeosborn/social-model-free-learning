function wrapper()
%function runs all over the simulations for simulations in Study 3
% 
% %--------- PART ONE 
% %Generate 1000 agents using the correct model of the task
 wrapper_model_correct();
 disp('SIMULATIONS 3.1 DONE!');
%fit agent data to both correct and wrong model and calculate AICs

 wrapper_fitting_correct_model('simulations_3_1_correct_model_agents.csv');
 disp('PARAMETER FITTING FOR SIMULATIONS 3.1 DONE!');

% %--------- PART TWO
% %Generate 1000 agents using the WRONG model of the task
 w = 0; %if 0, then w will be random for all participants
 output_file_name1 = 'simulations_3_2_wrong_model_agents.csv';
 output_file_name2 = 'simulations_3_2_wrong_model_params.csv';
 wrapper_model_wrong(w, output_file_name1, output_file_name2);
 disp('SIMULATIONS 3.2 DONE!');
% %fit agent data to both correct and wrong model and calculate AICs
 wrapper_fitting_wrong_model(output_file_name1);
 disp('PARAMETER FITTING FOR SIMULATIONS 3.2 DONE!');
% 
% %--------- PART THREE
% %Generate 1000 mb agents using the WRONG model of the task to see if their
% %behavior would qualtify as model free in correct task
 w = 1;  %if 1, then w will be 1 for all participants
 output_file_name1 = 'simulations_3_3_model_based_wrong_model_agents.csv';
 output_file_name2 = 'simulations_3_3_wrong_model_params.csv';
 wrapper_model_wrong(w, output_file_name1, output_file_name2);
 disp('SIMULATIONS 3.3 DONE!');
% %fit agent data to both correct and wrong model and calculate AICs
 wrapper_fitting_comparison(output_file_name1);
 disp('PARAMETER FITTING FOR SIMULATIONS 3.3 DONE!');

%--------- PART FOUR
%Using data from participant studies, see which of the two models is a
%better fit for the participant data 
study_1 = '../../data/cleaned/study1_data.csv';
study_2 = '../../data/cleaned/study2_data.csv';
%study_3 = enter file name here

wrapper_participant_fit_comparison(study_1, study_2); 
disp('PARAMETER FITTING FOR PARTICIPANT DATA FROM STUDIES DONE!');


end 