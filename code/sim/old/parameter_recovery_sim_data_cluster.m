function[p_sim, p_rec] = parameter_recovery_sim_data_cluster(root_dcms, n, noise, presults)
% Function to generate data for parameter recovery analysis based on
% individuals level DCMs.
%
% IN:
% root_dcms     ->  Path of folder with DCM files
% n             ->  Number of artificial participants
% noise         ->  'estimated' (noise level in data) or 'nn' (no noise)
% presults      ->  Folder to store the results in
%

%% Set seed for reproducible results
rng_seed = 123;
rng(rng_seed);


%% Create folder structure
root     = fullfile(presults,'parameter_recovery',noise);
root_sim = fullfile(root,'sim_dcms');
root_rec = fullfile(root,'rec_dcms');
[~,~] = mkdir(root);
[~,~] = mkdir(root_sim);
[~,~] = mkdir(root_rec);


%% Generate artifical participants
Ep = spm_vec(DCM.Ep);
Cp = full(DCM.Cp);
p_sim = mvnrnd(Ep,Cp,n); % samples from multivariate posterior distribution


%% Simulate data
% Store data in GCM file
for s = 1:n
    GCM{s,1} = DCM;
    GCM{s,1}.Ep = spm_unvec(p_sim(s,:),DCM.Ep);
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
[sGCM] = spm_dcm_simulate(GCM, mode, added_noise_mean);

% Save individual files
for s = 1:n
    sDCM = sGCM{s};
    save(fullfile(root_sim, sprintf('sDCM_%03d.mat',s)),'sDCM');
end
