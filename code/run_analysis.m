







%% Paths
setup_paths;

[~, uid] = unix('whoami');
switch uid(1: end-1)
    
    % Daniel's PC
    case 'laptop-0jhjt7kf\danie'
        presults = 'C:\projects\dcm_ei\results';
        pdata = 'C:\projects\dcm_ei\data';
        pcode = 'C:\projects\dcm_ei\code';    

    otherwise
        warning('Unknown User!')
        warning('Please specify your local paths at the top of the run_analysis.m script.')
end



%% Fit models to data
% P300
data_file_name = fullfile(pdata,'p300','bsnip_p300_grandmean_hc.mat');
results_folder = fullfile(presults,'p300');
fit_p300_dcm(data_file_name,results_folder);

% MMN
data_file_name = fullfile(pdata,'mmn','napls_mmn_grandmean_hc.mat');
results_folder = fullfile(presults,'mmn');
fit_mmn_dcm(data_file_name,results_folder);

% 40 Hz ASSR
data_file_name = fullfile(pdata,'assr','mean_S001_sensordata_spm.mat');
results_folder = fullfile(presults,'assr');
fit_assr_dcm(data_file_name,results_folder);


% Resting-state
data_file_name = fullfile(pdata,'rest','rs_eo_grandmean_hc.mat');
results_folder = fullfile(presults,'rest');
fit_rest_dcm(data_file_name,results_folder);



