function wrapper()
%wrapper: function that runs model fitting on data from all studies, gets
%negative loglikelihoods and AIC socres for the two models

%load data
study_1 = '../data/cleaned/study1_data.csv';
study_2 = '../data/cleaned/study2_data.csv';
% study_3 = '../../data/cleaned/study3_data.csv';
%run comparisons
[sigma_mf_model_study1, no_sigma_mf_model_study1, aic_scores_study1]...
    = fit_models(study_1); 

[sigma_mf_model_study2, no_sigma_mf_model_study2, aic_scores_study2]...
    = fit_models(study_2);

% [sigma_mf_model_study3, no_sigma_mf_model_study3, aic_scores_study3]...
%     = fit_models(study_3);


%save1
headers_sigma_mf_model = {'sub_id', 'beta','lr','e','ps','w_MB',...
    'sigma_mb','sigma_mf','sigma_ps', 'nll'}; 
headers_no_sigma_mf_model = {'sub_id', 'beta','lr','e','ps','w_MB',...
    'sigma_mb','sigma_ps', 'nll'}; 
headers_aic= {'sub_id', 'sigma_mf_model', 'no_sigma_mf_model'}; 

%study 1
csvwrite_with_headers('outputs/study_1_fit_params_sigma_mf_model.csv',...
    sigma_mf_model_study1, headers_sigma_mf_model);
csvwrite_with_headers('outputs/study_1_fit_params_no_sigma_mf_model.csv',...
    no_sigma_mf_model_study1, headers_no_sigma_mf_model);
csvwrite_with_headers('outputs/study_1_fit_AIC_scores.csv', aic_scores_study1, ...
    headers_aic);
disp("Study 1 done"); 

%study 2
csvwrite_with_headers('outputs/study_2_fit_params_sigma_mf_model.csv',...
    sigma_mf_model_study2, headers_sigma_mf_model);
csvwrite_with_headers('outputs/study_2_fit_params_no_sigma_mf_model.csv',...
    no_sigma_mf_model_study2, headers_no_sigma_mf_model);
csvwrite_with_headers('outputs/study_2_fit_AIC_scores.csv', aic_scores_study2, ...
    headers_aic);
disp("Study 2 done"); 
%study 3
% csvwrite_with_headers('outputs/study_3_fit_params_sigma_mf_model.csv',...
%     sigma_mf_model_study3, headers_sigma_mf_model);
% csvwrite_with_headers('outputs/study_3_fit_params_no_sigma_mf_model.csv',...
%     no_sigma_mf_model_study3, headers_no_sigma_mf_model);
% csvwrite_with_headers('outputs/study_3_fit_AIC_scores.csv', aic_scores_study3, ...
%     headers_aic);
% disp("Study 3 done"); 

disp("ALL DONE!!!"); 
end 