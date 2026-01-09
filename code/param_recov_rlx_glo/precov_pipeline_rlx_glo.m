



%% Fit model to 100 randomly selected healthy participants (on cluster)
% Use submit_fit_p50_precov_rlx_glo.sh, submit_fit_mmn_precov_rlx_glo.sh and
% submit_fit_p300_precov_rlx_glo.sh to submit cluster job.
% These bash scripts will run the precov_fit_p50_rlx_glo.m,  precov_fit_mmn_rlx_glo.m or
%  precov_fit_p300_rlx_glo.m script for each participant.


%% Plot Model Fit of individual DCMs
% P50
pplots = 'C:\projects\dcm_ei\results\p50\param_recov_rlx_glo\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\P50\param_recov_rlx_glo\dcms';
condition_names = {'S1','S2'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

% MMN
pplots = 'C:\projects\dcm_ei\results\mmn\param_recov_rlx_glo\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\mmn\param_recov_rlx_glo\dcms';
condition_names = {'Standard','Deviant'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

% P300
pplots = 'C:\projects\dcm_ei\results\p300_napls\param_recov_rlx_glo\estimated\plots';
[~,~] = mkdir(pplots);
pdcms = 'C:\projects\dcm_ei\results\p300_napls\param_recov_rlx_glo\dcms';
condition_names = {'Standard','Target'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))



%% Simulate data with empirical noise
noise = 'estimated';

% P50
pdcms = 'C:\projects\dcm_ei\results\p50\param_recov_rlx_glo\dcms';
pdata = 'C:\projects\dcm_ei\results\p50\param_recov_rlx_glo\data';
presults = 'C:\projects\dcm_ei\results\p50\param_recov_rlx_glo\estimated\sim_dcms';
precov_run_headmodel(pdata);
precov_sim_data_rlx_glo(pdcms, pdata, presults, noise);

% MMN
pdcms = 'C:\projects\dcm_ei\results\mmn\param_recov_rlx_glo\dcms';
pdata = 'C:\projects\dcm_ei\results\mmn\param_recov_rlx_glo\data';
presults = 'C:\projects\dcm_ei\results\mmn\param_recov_rlx_glo\estimated\sim_dcms';
precov_run_headmodel(pdata);
precov_sim_data_rlx_glo(pdcms, pdata, presults, noise);

% P300
pdcms = 'C:\projects\dcm_ei\results\p300_napls\param_recov_rlx_glo\dcms';
pdata = 'C:\projects\dcm_ei\results\p300_napls\param_recov_rlx_glo\data';
presults = 'C:\projects\dcm_ei\results\p300_napls\param_recov_rlx_glo\estimated\sim_dcms';
precov_run_headmodel(pdata);
precov_sim_data_rlx_glo(pdcms, pdata, presults, noise);


%% Reinvert models (on cluster)
% Use submit_p50_precov_rlx_glo.sh, submit_mmn_precov_rlx_glo.sh and submit_p300_precov_rlx_glo.sh  
% to submit cluster job.
% These bash scripts will run the precov_reinvert_cluster_rlx_glo.m script for 
% each DCM.


%% Plot recovery results
% which_params = find(spm_vec(rDCM.M.pC)~=0);
% param_names = spm_fieldindices(DCM.Ep,find(spm_vec(rDCM.M.pC)~=0));
which_params = [309:314 315:320];
param_names = {'B^{g_{ee}}_{1}', 'B^{g_{ee}}_{2}','B^{g_{ee}}_{3}',...
    'B^{g_{ee}}_{4}','B^{g_{ee}}_{5}','B^{g_{ee}}_{6}',...
    'B^{g_{ii}}_{1}','B^{g_{ii}}_{2}','B^{g_{ii}}_{3}',...
    'B^{g_{ii}}_{4}','B^{g_{ii}}_{5}','B^{g_{ii}}_{6}'};


% MMN
presults = 'C:\projects\dcm_ei\results\mmn\param_recov_rlx_glo\estimated';
pplots = 'C:\projects\dcm_ei\results\mmn\param_recov_rlx_glo\estimated\plots';
col = [44, 162, 95]/256;
icc_mmn = precov_plot_results_rlx_glo(presults, pplots, which_params, param_names, col);

% P50
presults = 'C:\projects\dcm_ei\results\p50\param_recov_rlx_glo\estimated';
pplots = 'C:\projects\dcm_ei\results\p50\param_recov_rlx_glo\estimated\plots';
col = [253, 141, 60]/256;
icc_p50 = precov_plot_results_rlx_glo(presults, pplots, which_params, param_names, col);

% P300
presults = 'C:\projects\dcm_ei\results\p300_napls\param_recov_rlx_glo\estimated';
pplots = 'C:\projects\dcm_ei\results\p300_napls\param_recov_rlx_glo\estimated\plots';
col = [43, 140, 190]/256;
icc_p300 = precov_plot_results_rlx_glo(presults, pplots, which_params, param_names, col)