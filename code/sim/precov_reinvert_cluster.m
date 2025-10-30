function precov_reinvert_cluster(s,data)
%--------------------------------------------------------------------------
% Function to reinvert DCM on simulated data on the cluster.
%--------------------------------------------------------------------------

%% Paths
pcode = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/code';
switch data
    case 'P50'
        root = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/p50/parameter_recovery/estimated';
    case 'P300'
        root = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/p300/parameter_recovery/estimated';
    case 'MMN'
        root =  '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/mmn/parameter_recovery/estimated';
end
root_sim = fullfile(root,'sim_dcms');
root_rec = fullfile(root,'rec_dcms');
[~,~] = mkdir(root_sim);
[~,~] = mkdir(root_rec);

cd(pcode);
setup_paths;
cd(root_rec);

%% Reinvert  
load(fullfile(root_sim, sprintf('sDCM_%03d.mat',s)));
if ~isfile(fullfile(root_rec, sprintf('rDCM_%03d.mat',s)))
    rDCM = spm_dcm_erp(sDCM);
    save(fullfile(root_rec, sprintf('rDCM_%03d.mat',s)),'rDCM');
else
    warning('File already exists. Skipping...')
end
