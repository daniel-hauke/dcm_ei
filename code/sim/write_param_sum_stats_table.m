function T = write_param_sum_stats_table(pdcms, presults)
%--------------------------------------------------------------------------
% Function that collects summary statistics (mean and sd) over parameter
% estimates located in dcm folder.
%
% IN:
%   pgmdcm          -> path to grandmean dcm file
%   presults        -> file name under which table will be saved
%  
% OUT:
%   T               -> Table with parameters
%--------------------------------------------------------------------------


%% Get files and parameter names
temp = dir(fullfile(pdcms,'*.mat'));
dcm_files = fullfile({temp.folder}',{temp.name}');

load(dcm_files{1});
n_params_f = numel(full(spm_vec(DCM.Ep)));
param_names_f = spm_fieldindices(DCM.Ep,1:n_params_f);
is_fixed_f = logical(spm_vec(DCM.M.pC)==0);

n_params_g = numel(full(spm_vec(DCM.Eg)));
param_names_g = spm_fieldindices(DCM.Eg,1:n_params_g);
is_fixed_g = logical(full(spm_vec(DCM.M.gC))==0);

param_names = [param_names_f param_names_g]';
is_fixed = [is_fixed_f; is_fixed_g];

model_part = [repmat('fx',n_params_f,1); repmat('gx',n_params_g,1)];

%% Collect parameters
clear p_f p_g
for s = 1:numel(dcm_files)
    clear DCM
    
    if isfile(dcm_files{s})
        load(dcm_files{s});
        p_f(s,:) = full(spm_vec(DCM.Ep));
        p_g(s,:) = full(spm_vec(DCM.Eg));
    else
        warning('Participant %d has no DCM file',s)
    end
end


p = [p_f p_g];
for i_p = 1:size(p,2)   
    m(i_p,1) = mean(p(:,i_p));
    sd(i_p,1) = std(p(:,i_p));
end


%% Write results table
[~,~] = mkdir(fileparts(presults));

T = table(param_names,model_part,is_fixed,m,sd);
writetable(T,presults);


