function mcomp_sim_data(pdcms, pdata, presults, noise)
%--------------------------------------------------------------------------
% Function to generate data for parameter recovery analysis based on
% individuals level DCMs.
%
% IN:
% root_dcms     ->  Path of folder with DCM files
% presults      ->  Folder to store the results in
% noise         ->  'estimated' (noise level in data) or 'nn' (no noise)
%
%--------------------------------------------------------------------------


%% Set seed for reproducible results
rng_seed = 123;
rng(rng_seed);


%% Create folder structure
[~,~] = mkdir(presults);


%% Simulate data
n_models = numel(pdcms);

% Generate GCM file
for m = 1:n_models
    
    % Get dcm files
    temp = dir(fullfile(pdcms{m},'*.mat'));
    dcm_files = fullfile({temp.folder}',{temp.name}');
    
    % Store data in GCM file
    for s = 1:numel(dcm_files)
        load(dcm_files{s});
        GCM{s,1} = DCM;
    end
    
    % Simulate
    switch noise
        case 'estimated'
            mode = 'estimated';
            added_noise_mean = [];
        case 'nn'
            mode = 'var';
            added_noise_mean = 0;
    end
    cd(pdata{m});
    
    % Save individual files
    
    for s = 1:numel(dcm_files)
        clear spm_erp_L
        [sGCM] = spm_dcm_simulate({GCM{s}}, mode, added_noise_mean);
        sDCM = sGCM{1};
        sDCM.M.pE = GCM{s}.M.pE;
        sDCM.M.pC = GCM{s}.M.pC;
        sDCM.M.gE = GCM{s}.M.gE;
        sDCM.M.gC = GCM{s}.M.gC;
        sDCM.M.nograph = 1; % no figure in spm_dcm_erp
        save(fullfile(presults, sprintf('sDCM_%03d_m%d.mat',s,m)),'sDCM');
    end
    
end

