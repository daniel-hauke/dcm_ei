function[p_sim, p_rec] = parameter_recovery(DCM, n, noise, presults)
% Function to run a parameter recovery analysis, by generating artifical
% participants through sampling from the multivariate Gaussian posterior
% distribution of a DCM model that was fit to data.
%
% IN:
% DCM       ->  DCM file
% n         ->  Number of artificial participants
% noise     ->  'estimated' (noise level in data) or 'nn' (no noise)
% presults  ->  Folder to store the results in
%
% OUT:
% p_sim     ->  Parameters from which data were simulated
% p_rec     ->  Recovered parameters
%
%
% if nargin<4
%    presults ='C:\projects\dcm_ei\results\p50'; 
% end

%% Set seed for reproducible results
rng_seed = 123;
rng(rng_seed);


%% Load DCM
if ischar(DCM)
    load(DCM);
end

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


%% Reinvert  
p_rec = NaN(size(P));
for s = 1:n  
    load(fullfile(root_sim, sprintf('sDCM_%03d.mat',s))); 
    rDCM = spm_dcm_erp(sDCM);
    save(fullfile(root_rec, sprintf('rDCM_%03d.mat',s)),'rDCM');
    p_rec(s,:) = spm_vec(rDCM.Ep);
end
save(fullfile(root,'recovery_results.mat'),'p_sim','p_rec','rng_seed','DCM');


