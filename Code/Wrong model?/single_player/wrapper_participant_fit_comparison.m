function wrapper_participant_fit_comparison(file1, file2)
%wrapper: Wrapper function that calculates negative loglikelihoods and
%AIC scores for different models

%variables
header_params = {'sub_id', 'beta','lr','e','ps','w_MB','sigma_MB',...
    'sigma_MF', 'sigma_ps','nll'}; 
header_aic= {'sub_id', 'AIC'}; 

%STUDY 1
study1 = file1; %data
df1 = readtable(study1);
df1 = table2array(df1);

[results1_study1, results2_study1, aic_correct_model_study1,...
    aic_wrong_model_study1] = run_model_comparison_studies(df1); 

%save 
csvwrite_with_headers('simulations_3_study1_fit_params_correct_model.csv',...
    results1_study1, header_params);
csvwrite_with_headers('simulations_3_study1_fit_params_wrong_model.csv',...
    results2_study1, header_params);

csvwrite_with_headers('AIC_simulations_3_study1_correct_model.csv',...
    aic_correct_model_study1, header_aic);
csvwrite_with_headers('AIC_simulations_3_study1_wrong_model.csv', ...
    aic_wrong_model_study1, header_aic);


%STUDY TWO 
study2 = file2; %data
df2 = readtable(study2);
df2 = table2array(df2);

[results1_study2, results2_study2, aic_correct_model_study2,...
    aic_wrong_model_study2] = run_model_comparison_studies(df2); 
%save 
csvwrite_with_headers('simulations_3_study2_fit_params_correct_model.csv',...
    results1_study2, header_params);
csvwrite_with_headers('simulations_3_study2_fit_params_wrong_model.csv',...
    results2_study2, header_params);

csvwrite_with_headers('AIC_simulations_3_study2_correct_model.csv',...
    aic_correct_model_study2, header_aic);
csvwrite_with_headers('AIC_simulations_3_study2_wrong_model.csv', ...
    aic_wrong_model_study2, header_aic);

end 