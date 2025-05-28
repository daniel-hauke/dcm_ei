function mrecov_reinvert_cluster(s,data)
%--------------------------------------------------------------------------
% Function to reinvert DCM on simulated data on the cluster.
%--------------------------------------------------------------------------

%% Paths
pcode = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/code';
switch data
    case 'P50'
        root = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/p50/model_recovery/estimated';
    case 'P300'
        root = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/p300/model_recovery/estimated';
    case 'MMN'
        root =  '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/mmn/model_recovery/estimated';
end
root_sim = fullfile(root,'sim_dcms');
root_rec = fullfile(root,'rec_dcms');
[~,~] = mkdir(root_sim);
[~,~] = mkdir(root_rec);

cd(pcode);
setup_paths;
cd(root_rec);

%% Reconstruct unique IDs
% Parameters
num_participants = 50;
num_true_models = 4;
num_fit_models = 4;

% Reconstruct participant and model from the ID
participant_id  = mod(s-1, num_participants) + 1;
true_model_id = mod(floor((s-1) / num_participants), num_true_models) + 1;
fitting_model_id = floor((s-1) / (num_participants * num_true_models)) + 1;

fprintf('-------------------\nID: %02d\nTrue model: %d\nFit model: %d\n-------------------\n', participant_id, true_model_id ,fitting_model_id)

%% Reinvert
% Load simulated data
load(fullfile(root_sim, sprintf('sDCM_%03d_m%d.mat',participant_id,true_model_id)));

if ~isfile(fullfile(root_rec, sprintf('rDCM_%03d_tm%d_fm%d.mat',participant_id,true_model_id,fitting_model_id)))
    switch fitting_model_id
        case 1 % null model
            sDCM.M.pE.B_g_ee = 0;
            sDCM.M.pC.B_g_ee = 0;
            sDCM.M.pE.B_g_ii = 0;
            sDCM.M.pC.B_g_ii = 0;
        case 2 % B-g_ee only
            sDCM.M.pE.B_g_ii = 0;
            sDCM.M.pC.B_g_ii = 0;
        case 3 % B-g_gii only
            sDCM.M.pE.B_g_ee = 0;
            sDCM.M.pC.B_g_ee = 0;
        case 4  % full model
    end
    
    rDCM = spm_dcm_erp(sDCM);
    save(fullfile(root_rec, sprintf('rDCM_%03d_tm%d_fm%d.mat',participant_id,true_model_id,fitting_model_id)),'rDCM');
else
    warning('File already exists. Skipping...')
end
