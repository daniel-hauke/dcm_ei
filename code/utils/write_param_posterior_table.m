function T = write_param_posterior_table(pgmdcm, presults)
%--------------------------------------------------------------------------
% Function that collects posterior expectations and covariances from
% grandmean dcm file.
%
% IN:
%   pgmdcm          -> path to grandmean dcm file
%   presults        -> file name under which table will be saved
%  
% OUT:
%   T               -> Table with parameters
%--------------------------------------------------------------------------



%% Load grandmean dcm
load(pgmdcm);

n_params_f = numel(full(spm_vec(DCM.Ep)));
param_names_f = spm_fieldindices(DCM.Ep,1:n_params_f);
is_fixed_f = logical(spm_vec(DCM.M.pC)==0);

n_params_g = numel(full(spm_vec(DCM.Eg)));
param_names_g = spm_fieldindices(DCM.Eg,1:n_params_g);
is_fixed_g = logical(full(spm_vec(DCM.M.gC))==0);

param_names = [param_names_f param_names_g]';
is_fixed = [is_fixed_f; is_fixed_g];

model_part = [repmat('fx',n_params_f,1); repmat('gx',n_params_g,1)];

ep_gm_f = full(spm_vec(DCM.Ep));
ep_gm_g = full(spm_vec(DCM.Eg));
cp_gm_f = diag(full(DCM.Cp));
cp_gm_g = diag(full(DCM.Cg));
ep_gm = [ep_gm_f; ep_gm_g];
cp_gm = [cp_gm_f; cp_gm_g];


%% Write results table
[~,~] = mkdir(fileparts(presults));

T = table(param_names,model_part, is_fixed, ep_gm,cp_gm);
writetable(T,presults);


