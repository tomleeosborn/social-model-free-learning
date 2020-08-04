function wrapper()
%function runs all over the simulations for simulations in Study 3

%--------- PART ONE 
%Generate 1000 agents using the correct model of the task
wrapper_model_correct();
%fit agent data to both correct and wrong model and calculate AICs
wrapper_fitting_correct_model('simulations_3_1_correct_model_agents.csv');

%--------- PART TWO
%Generate 1000 agents using the WRONG model of the task
w = rand(); %model-based weight set to random
output_file_name = 'simulations_3_2_wrong_model_agents.csv';
wrapper_model_wrong(w, output_file_name);
%fit agent data to both correct and wrong model and calculate AICs
wrapper_fitting_wrong_model(output_file_name);


%--------- PART THREE
%Generate 1000 mb agents using the WRONG model of the task to see if their
%behavior would qualtify as model free in correct task
w = 1; %generated model-based agents
output_file_name = 'simulations_3_3_model_based_wrong_model_agents.csv');
wrapper_model_wrong(w, output_file_name);
%fit agent data to both correct and wrong model and calculate AICs
wrapper_fitting_comparison(output_file_name);

end 