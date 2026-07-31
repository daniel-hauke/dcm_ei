

%% Fit new E/I model to 100 randomly selected healthy participants (on cluster)
% Use submit_fit_p50_precov.sh, submit_fit_mmn_precov.sh and
% submit_fit_p300_precov.sh to submit cluster job.
% These bash scripts will run the precov_fit_p50.m, precov_fit_mmn.m or
%  precov_fit_p300.m script for each participant.



%% Fit original cmc model to 100 randomly selected healthy participants (on cluster)
% Use submit_fit_p50_mcomp.sh, submit_fit_mmn_mcomp.sh and
% submit_fit_p300_mcomp.sh to submit cluster job.
% These bash scripts will run the mcomp_fit_p50.m, mcomp_fit_mmn.m or
%  mcomp_fit_p300.m script for each participant.


%% Compare models
% P50
model_dirs{1} = 'C:\projects\dcm_ei\results\p50\parameter_recovery\dcms';
model_dirs{2} = 'C:\projects\dcm_ei\results\p50\model_comparison\dcms';
pplots = 'C:\projects\dcm_ei\results\p50\plots';

fh = mcomp_bms(model_dirs);
saveas(fh, fullfile(pplots,'model_comparison.fig'))
saveas(fh, fullfile(pplots,'model_comparison.png'))

% MMN
model_dirs{1} = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\dcms';
model_dirs{2} = 'C:\projects\dcm_ei\results\mmn\model_comparison\dcms';
pplots = 'C:\projects\dcm_ei\results\mmn\plots';

fh = mcomp_bms(model_dirs);
saveas(fh, fullfile(pplots,'model_comparison.fig'))
saveas(fh, fullfile(pplots,'model_comparison.png'))

% P300
model_dirs{1} = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\dcms';
model_dirs{2} = 'C:\projects\dcm_ei\results\p300_napls\model_comparison\dcms';
pplots = 'C:\projects\dcm_ei\results\p300_napls\plots';

fh = mcomp_bms(model_dirs);
saveas(fh, fullfile(pplots,'model_comparison.fig'))
saveas(fh, fullfile(pplots,'model_comparison.png'))


%% Model confusion analysis
% Simulate data with empirical noise
noise = 'estimated';

% P50
pdcms{1} = 'C:\projects\dcm_ei\results\p50\parameter_recovery\dcms';
pdata{1} = 'C:\projects\dcm_ei\results\p50\parameter_recovery\data';
pdcms{2} = 'C:\projects\dcm_ei\results\p50\model_comparison\dcms';
pdata{2} = 'C:\projects\dcm_ei\results\p50\model_comparison\data';
presults = 'C:\projects\dcm_ei\results\p50\model_comparison\estimated\sim_dcms';
%precov_run_headmodel(pdata{1});
%precov_run_headmodel(pdata{2});
mcomp_sim_data(pdcms, pdata, presults, noise);

% MMN
pdcms{1} = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\dcms';
pdata{1} = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\data';
pdcms{2} = 'C:\projects\dcm_ei\results\mmn\model_comparison\dcms';
pdata{2} = 'C:\projects\dcm_ei\results\mmn\model_comparison\data';
presults = 'C:\projects\dcm_ei\results\mmn\model_comparison\estimated\sim_dcms';
precov_run_headmodel(pdata{1});
%precov_run_headmodel(pdata{2});
mcomp_sim_data(pdcms, pdata, presults, noise);

% P300
pdcms{1} = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\dcms';
pdata{1} = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\data';
pdcms{2} = 'C:\projects\dcm_ei\results\p300_napls\model_comparison\dcms';
pdata{2} = 'C:\projects\dcm_ei\results\p300_napls\model_comparison\data';
presults = 'C:\projects\dcm_ei\results\p300_napls\model_comparison\estimated\sim_dcms';
precov_run_headmodel(pdata{1});
precov_run_headmodel(pdata{2});
mcomp_sim_data(pdcms, pdata, presults, noise);


%% Reinvert models (on cluster)
% Use submit_p50_mcomp_mrecov.sh, submit_mmn_mcomp_mrecov.sh and submit_p300_mcomp_mrecov.sh  
% to submit cluster job.
% These bash scripts will run the mrecov_reinvert_cluster.m script for 
% each DCM.


%% Plot Compute confusion matrix
model_names = {'E/I', 'CMC'};

% P50
pdcms = 'C:\projects\dcm_ei\results\p50\model_comparison\estimated';
pplots = 'C:\projects\dcm_ei\results\p50\plots';
mcomp_confusion_matrix(pdcms,pplots,model_names)

% MMN
pdcms = 'C:\projects\dcm_ei\results\mmn\model_comparison\estimated';
pplots = 'C:\projects\dcm_ei\results\mmn\plots';
mcomp_confusion_matrix(pdcms,pplots,model_names)

% P300
pdcms = 'C:\projects\dcm_ei\results\p300_napls\model_comparison\estimated';
pplots = 'C:\projects\dcm_ei\results\p300_napls\plots';
mcomp_confusion_matrix(pdcms,pplots,model_names)