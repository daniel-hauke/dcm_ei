% Parameter identifiability pipeline



%% Fit full model to 50 randomly selected healthy participants (on cluster)
% Use submit_fit_p50_precov.sh, submit_fit_mmn_precov.sh and
% submit_fit_p300_precov.sh to submit cluster job.
% These bash scripts will run the precov_fit_p50.m,  precov_fit_mmn.m or
%  precov_fit_p300.m script for each participant.


%% Plot Model Fit of individual DCMs
% P50
pplots = 'C:\projects\dcm_ei\results\p50\parameter_recovery_hc_grandmean\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\P50\parameter_recovery_hc_grandmean\dcms';
condition_names = {'S1','S2'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

% MMN
pplots = 'C:\projects\dcm_ei\results\mmn\parameter_recovery_hc_grandmean\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\mmn\parameter_recovery_hc_grandmean\dcms';
condition_names = {'Standard','Deviant'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

% P300
pplots = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery_hc_grandmean\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery_hc_grandmean\dcms';
condition_names = {'Standard','Target'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))



%% Plot parameter identifiability
which_params = [309 310];
param_names = {'B^{g_{ee}}', 'B^{g_{ii}}'};

% P50
presults = 'C:\projects\dcm_ei\results\P50\parameter_recovery\dcms';
pplots = 'C:\projects\dcm_ei\results\p50\parameter_identifiability';
pident_correlation_matrix(presults, pplots, which_params, param_names)

% MMN
presults = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\dcms';
pplots = 'C:\projects\dcm_ei\results\mmn\parameter_identifiability';
pident_correlation_matrix(presults, pplots, which_params, param_names)

% P300
presults = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\dcms';
pplots = 'C:\projects\dcm_ei\results\p300_napls\parameter_identifiability';
pident_correlation_matrix(presults, pplots, which_params, param_names)






