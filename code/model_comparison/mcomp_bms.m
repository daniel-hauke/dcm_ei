function fh = mcomp_bms(model_dirs)




% Get model files
n_models = numel(model_dirs);
for m = 1:n_models
    mfiles{m} = cellstr(ls(fullfile(model_dirs{m},'*mat')));
    n_subjects(m) = numel(mfiles{m});
end


% Load models and get free energy
F = NaN(max(n_subjects),n_models);
for m = 1:n_models
    for s = 1:n_subjects(m)
        load(fullfile(model_dirs{m},mfiles{m}{s}));
        F(s,m) = DCM.F;
    end
end

% Run model comparison
Nsamp = 1e6;
do_plot = 1;
[alpha,exp_r,xp,pxp,bor] = spm_BMS (F, Nsamp, do_plot)


% Plot
model_names = {'EI', 'CMC'};
fh = plot_bms(pxp, exp_r, model_names);
