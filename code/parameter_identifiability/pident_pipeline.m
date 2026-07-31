%--------------------------------------------------------------------------
% This code runs the parameter identifiability pipeline. 
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
        warning('Please specify your local paths at the top of the pident_pipeline script.')
end


%% Fit full model to 100 randomly selected healthy participants (on cluster)
% Use submit_fit_p50_precov.sh, submit_fit_mmn_precov.sh and
% submit_fit_p300_precov.sh to submit cluster job.
% These bash scripts will run the precov_fit_p50.m,  precov_fit_mmn.m or
%  precov_fit_p300.m script for each participant.


%% Plot Model Fit of individual DCMs
%------------------------------------
% P50
%------------------------------------
pplots = fullfile(presults,'p50','parameter_recovery','estimated','plots');
pdcms = fullfile(presults,'p50','parameter_recovery','dcms');
[~,~] = mkdir(pplots);
condition_names = {'S1','S2'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

%------------------------------------
% MMN
%------------------------------------
pplots = fullfile(presults,'mmn','parameter_recovery','estimated','plots');
pdcms = fullfile(presults,'mmn','parameter_recovery','dcms');
[~,~] = mkdir(pplots);
condition_names = {'Standard','Deviant'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))

%------------------------------------
% P300
%------------------------------------
pplots = fullfile(presults,'p300','parameter_recovery','estimated','plots');
pdcms = fullfile(presults,'p300','parameter_recovery','dcms');
[~,~] = mkdir(pplots);
condition_names = {'Standard','Target'};
fh = plot_model_fit(pdcms, condition_names);
saveas(gcf, fullfile(pplots,'model_fit.fig'))
saveas(gcf, fullfile(pplots,'model_fit.png'))


%% Plot parameter identifiability
which_params = [309 310];
param_names = {'B^{g_{ee}}', 'B^{g_{ii}}'};

%------------------------------------
% P50
%------------------------------------
presults = fullfile(presults,'p50','parameter_recovery','dcms');
pplots = fullfile(presults,'p50','parameter_identifiability');
[~,~] = mkdir(pplots);
pident_correlation_matrix(presults, pplots, which_params, param_names)

%------------------------------------
% MMN
%------------------------------------
presults = fullfile(presults,'mmn','parameter_recovery','dcms');
pplots = fullfile(presults,'mmn','parameter_identifiability');
[~,~] = mkdir(pplots);
pident_correlation_matrix(presults, pplots, which_params, param_names)

%------------------------------------
% P300
%------------------------------------
presults = fullfile(presults,'p300','parameter_recovery','dcms');
pplots = fullfile(presults,'p300','parameter_identifiability');
[~,~] = mkdir(pplots);
pident_correlation_matrix(presults, pplots, which_params, param_names)

