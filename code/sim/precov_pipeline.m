



%% Fit model to 100 randomly selected healthy participants (on cluster)
% Use submit_fit_p50_precov.sh, submit_fit_mmn_precov.sh and
% submit_fit_p300_precov.sh to submit cluster job.
% These bash scripts will run the precov_fit_p50.m,  precov_fit_mmn.m or
%  precov_fit_p300.m script for each participant.


%% Plot Model Fit of individual DCMs
% P50
pplots = 'C:\projects\dcm_ei\results\p50\parameter_recovery\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\P50\parameter_recovery\dcms';
condition_names = {'S1','S2'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

% MMN
pplots = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\dcms';
condition_names = {'Standard','Deviant'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

% P300
pplots = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\dcms';
condition_names = {'Standard','Target'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))



%% Simulate data with empirical noise
noise = 'estimated';

% P50
pdcms = 'C:\projects\dcm_ei\results\p50\parameter_recovery\dcms';
pdata = 'C:\projects\dcm_ei\results\p50\parameter_recovery\data';
presults = 'C:\projects\dcm_ei\results\p50\parameter_recovery\estimated\sim_dcms';
precov_run_headmodel(pdata);
precov_sim_data_cluster(pdcms, pdata, presults, noise);

% MMN
pdcms = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\dcms';
pdata = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\data';
presults = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\estimated\sim_dcms';
precov_run_headmodel(pdata);
precov_sim_data_cluster(pdcms, pdata, presults, noise);

% P300
pdcms = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\dcms';
pdata = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\data';
presults = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\estimated\sim_dcms';
precov_run_headmodel(pdata);
precov_sim_data_cluster(pdcms, pdata, presults, noise);


%% Reinvert models (on cluster)
% Use submit_p50_precov.sh, submit_mmn_precov.sh and submit_p300_precov.sh  
% to submit cluster job.
% These bash scripts will run the precov_reinvert_cluster.m script for 
% each DCM.


%% Plot recovery results
which_params = [309 310];
param_names = {'B^{g_{ee}}', 'B^{g_{ii}}'};

% MMN
presults = 'C:\projects\dcm_ei\results\mmn\parameter_recovery_hc_grandmean\estimated';
pplots = 'C:\projects\dcm_ei\results\mmn\parameter_recovery_hc_grandmean\estimated\plots';
presults = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\estimated';
pplots = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\plots';
col = [44, 162, 95]/256;
precov_plot_results(presults, pplots, which_params, param_names, col)

% P50
presults = 'C:\projects\dcm_ei\results\p50\parameter_recovery_hc_grandmean\estimated';
pplots = 'C:\projects\dcm_ei\results\p50\parameter_recovery_hc_grandmean\estimated\plots';
presults = 'C:\projects\dcm_ei\results\p50\parameter_recovery\estimated';
pplots = 'C:\projects\dcm_ei\results\p50\parameter_recovery\plots';
col = [253, 141, 60]/256;
precov_plot_results(presults, pplots, which_params, param_names, col)

% P300
presults = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery_hc_grandmean\estimated';
pplots = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery_hc_grandmean\estimated\plots';
col = [43, 140, 190]/256;
precov_plot_results(presults, pplots, which_params, param_names, col)



%% Collect values in table

%% Collect posterior in table
% P50
pdcms = 'C:\projects\dcm_ei\results\p50\parameter_recovery\dcms';
presults = 'C:\projects\dcm_ei\results\p50\plots\Table_S4_parameter_summary_statistics_paired-click_paradigm.csv';
T = write_param_sum_stats_table(pdcms, presults);

% MMN
pdcms = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\dcms';
presults = 'C:\projects\dcm_ei\results\mmn\plots\Table_S5_parameter_summary_statistics_passive_oddball_paradigm.csv';
write_param_sum_stats_table(pdcms, presults);

% P300
pdcms = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\dcms';
presults = 'C:\projects\dcm_ei\results\p300_napls\plots\Table_S6_parameter_summary_statistics_active_oddball_paradigm.csv';
write_param_sum_stats_table(pdcms, presults);


