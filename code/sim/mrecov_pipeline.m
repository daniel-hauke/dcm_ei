% Model recovery pipeline



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



%% Simulate data with empirical noise
noise = 'estimated';

% P50
pdcms = 'C:\projects\dcm_ei\results\p50\parameter_recovery_hc_grandmean\dcms';
pdata = 'C:\projects\dcm_ei\results\p50\parameter_recovery_hc_grandmean\data';
presults = 'C:\projects\dcm_ei\results\p50\model_recovery\estimated\sim_dcms';
%precov_run_headmodel(pdata);
mrecov_sim_data_cluster(pdcms, pdata, presults, noise);

% MMN
pdcms = 'C:\projects\dcm_ei\results\mmn\parameter_recovery_hc_grandmean\dcms';
pdata = 'C:\projects\dcm_ei\results\mmn\parameter_recovery_hc_grandmean\data';
presults = 'C:\projects\dcm_ei\results\mmn\model_recovery\estimated\sim_dcms';
%precov_run_headmodel(pdata);
mrecov_sim_data_cluster(pdcms, pdata, presults, noise);

% P300
pdcms = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery_hc_grandmean\dcms';
pdata = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery_hc_grandmean\data';
presults = 'C:\projects\dcm_ei\results\p300_napls\model_recovery\estimated\sim_dcms';
%precov_run_headmodel(pdata);
mrecov_sim_data_cluster(pdcms, pdata, presults, noise);


%% Reinvert models (on cluster)
% Use submit_p50_mrecov.sh, submit_mmn_mrecov.sh and submit_p300_mrecov.sh  
% to submit cluster job.
% These bash scripts will run the mrecov_reinvert_cluster.m script for 
% each DCM.


%% Plot Compute confusion matrix
% MMN
pdcms = 'C:\projects\dcm_ei\results\mmn\model_recovery\estimated';
pplots = 'C:\projects\dcm_ei\results\mmn\model_recovery\estimated\plots';
mrecov_confusion_matrix(pdcms,pplots)

% P50
pdcms = 'C:\projects\dcm_ei\results\p50\model_recovery\estimated';
pplots = 'C:\projects\dcm_ei\results\p50\model_recovery\estimated\plots';
mrecov_confusion_matrix(pdcms,pplots)

% P300
pdcms = 'C:\projects\dcm_ei\results\p300_napls\model_recovery\estimated';
pplots = 'C:\projects\dcm_ei\results\p300_napls\model_recovery\estimated\plots';
mrecov_confusion_matrix(pdcms,pplots)