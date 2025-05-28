function mrecov_confusion_matrix(pdcms, pplots)



%% Options
num_participants = 50;
num_true_models = 4;
num_fitting_models = 4;


%% Collect F
F = NaN(num_participants, num_fitting_models, num_true_models);
for p = 1:num_participants
    for t = 1:num_true_models
        for f = 1:num_fit_models
            load(fullfile(pdcms, sprintf('rDCM_%03d_tm%d_fm%d.mat'));
            F(p,f,t) = DCM.F;
            clear DCM;
        end
    end
end


%% Compute confusion matrix
C = NaN(num_fitting_models, num_true_models);
for t = 1:num_true_models
    [alpha,exp_r,xp,pxp,bor] = spm_BMS (F(:,:,t));
    C(:,t) = pxp;
end


%% Plot confusion matrix
model_names = {'null', 'B-g_{ee}', 'B-g_{ii}', 'full'};
fh = plot_C(C,model_names);
saveas(gcf, fullfile(pplots,'model_confusion_matrix.fig'))
saveas(gcf, fullfile(pplots,'model_confusion_matrix.png'))


