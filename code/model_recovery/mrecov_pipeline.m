%--------------------------------------------------------------------------
% This code runs the model recovery pipeline. 
% 
% Note that some steps were run on the cluster. 
%--------------------------------------------------------------------------


%% Add local paths
[~, uid] = unix('whoami');
switch uid(1: end-1)
    
    % Daniel
    case {'desktop-15ldi1r\pc'}
        presults = 'C:\projects\dcm_ei\results';
        pdata = 'C:\projects\dcm_ei\data';
        
    otherwise
        warning('Unknown User!')
        warning('Please specify your local paths at the top of the mrecov_pipeline script.')
end


%% Fit full model to 100 randomly selected healthy participants (on cluster)
% Use submit_fit_p50_precov.sh, submit_fit_mmn_precov.sh and
% submit_fit_p300_precov.sh to submit cluster job.
% These bash scripts will run the precov_fit_p50.m,  precov_fit_mmn.m or
% precov_fit_p300.m script for each participant.


%% Plot Model Fit of individual DCMs
%------------------------------------
% P50
%------------------------------------
pplots = fullfile(presults,'p50','parameter_recovery_hc_grandmean','estimated','plots');
pdcms = fullfile(presults,'p50','parameter_recovery_hc_grandmean','dcms');
[~,~] = mkdir(pplots);
condition_names = {'S1','S2'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

%------------------------------------
% MMN
%------------------------------------
pplots = fullfile(presults,'mmn','parameter_recovery_hc_grandmean','estimated','plots');
pdcms = fullfile(presults,'mmn','parameter_recovery_hc_grandmean','dcms');
[~,~] = mkdir(pplots);
condition_names = {'Standard','Deviant'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

%------------------------------------
% P300
%------------------------------------
pplots = fullfile(presults,'p300','parameter_recovery_hc_grandmean','estimated','plots');
pdcms = fullfile(presults,'p300','parameter_recovery_hc_grandmean','dcms');
[~,~] = mkdir(pplots);
condition_names = {'Standard','Target'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))


%% Simulate data with empirical noise
noise = 'estimated';

%------------------------------------
% P50
%------------------------------------
pdcms = fullfile(presults,'p50','parameter_recovery_hc_grandmean','dcms');
pdata = fullfile(presults,'p50','parameter_recovery_hc_grandmean','data');
presults = fullfile(presults,'p50','model_recovery','estimated','sim_dcms');
%precov_run_headmodel(pdata);
mrecov_sim_data_cluster(pdcms, pdata, presults, noise);

%------------------------------------
% MMN
%------------------------------------
pdcms = fullfile(presults,'mmn','parameter_recovery_hc_grandmean','dcms');
pdata = fullfile(presults,'mmn','parameter_recovery_hc_grandmean','data');
presults = fullfile(presults,'mmn','model_recovery','estimated','sim_dcms');
%precov_run_headmodel(pdata);
mrecov_sim_data_cluster(pdcms, pdata, presults, noise);

%------------------------------------
% P300
%------------------------------------
pdcms = fullfile(presults,'p300','parameter_recovery_hc_grandmean','dcms');
pdata = fullfile(presults,'p300','parameter_recovery_hc_grandmean','data');
presults = fullfile(presults,'p300','model_recovery','estimated','sim_dcms');
%precov_run_headmodel(pdata);
mrecov_sim_data_cluster(pdcms, pdata, presults, noise);


%% Reinvert models (on cluster)
% Use submit_p50_mrecov.sh, submit_mmn_mrecov.sh and submit_p300_mrecov.sh  
% to submit cluster job.
% These bash scripts will run the mrecov_reinvert_cluster.m script for 
% each DCM.


%% Plot Compute confusion matrix
%------------------------------------
% P50
%------------------------------------
pdcms = fullfile(presults,'p50','model_recovery','estimated');
pdcms = fullfile(presults,'p50','model_recovery','estimated','plots');
mrecov_confusion_matrix(pdcms,pplots)

%------------------------------------
% MMN
%------------------------------------
pdcms = fullfile(presults,'mmn','model_recovery','estimated');
pdcms = fullfile(presults,'mmn','model_recovery','estimated','plots');
mrecov_confusion_matrix(pdcms,pplots)

%------------------------------------
% P300
%------------------------------------
pdcms = fullfile(presults,'p300','model_recovery','estimated');
pdcms = fullfile(presults,'p300','model_recovery','estimated','plots');
mrecov_confusion_matrix(pdcms,pplots)