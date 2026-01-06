function mcomp_reinvert_cluster(s,data)
%--------------------------------------------------------------------------
% Function to reinvert DCM on simulated data on the cluster.
%--------------------------------------------------------------------------

%% Paths
pcode = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/code';
%pcode = 'C:\projects\dcm_ei\code';
switch data
    case 'P50'
        root = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/p50/model_comparison/estimated';
        %root = 'C:\projects\dcm_ei\results\p50\model_comparison\estimated';
    case 'P300'
        root = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/p300/model_comparison/estimated';
    case 'MMN'
        root =  '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/mmn/model_comparison/estimated';
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
num_participants = 100;
num_true_models = 2;
num_fit_models = 2;

% Reconstruct participant and model from the ID
participant_id  = mod(s-1, num_participants) + 1;
true_model_id = mod(floor((s-1) / num_participants), num_true_models) + 1;
fitting_model_id = floor((s-1) / (num_participants * num_true_models)) + 1;

fprintf('-------------------\nID: %02d\nTrue model: %d\nFit model: %d\n-------------------\n', participant_id, true_model_id ,fitting_model_id)

%% Reinvert
% Load simulated data
load(fullfile(root_sim, sprintf('sDCM_%03d_m%d.mat',participant_id,true_model_id)));
xY = sDCM.xY;
clear sDCM;

if ~isfile(fullfile(root_rec, sprintf('rDCM_%03d_tm%d_fm%d.mat',participant_id,true_model_id,fitting_model_id)))
    
    % Load model to be fitted
    load(fullfile(root_sim, sprintf('sDCM_%03d_m%d.mat',participant_id,fitting_model_id)));
    
    % Subsitute new data into the model
    sDCM.xY = xY;
    
    rDCM = spm_dcm_erp(sDCM);
    save(fullfile(root_rec, sprintf('rDCM_%03d_tm%d_fm%d.mat',participant_id,true_model_id,fitting_model_id)),'rDCM');
else
    warning('File already exists. Skipping...')
end
