function mcomp_confusion_matrix(pdcms,pplots,model_names)



%% Options
num_participants = 100;
num_true_models = 2;
num_fitting_models = 2;


%% Collect F
F = NaN(num_participants, num_fitting_models, num_true_models);
for p = 1:num_participants
    for t = 1:num_true_models
        for f = 1:num_fitting_models
            load(fullfile(pdcms,'rec_dcms', sprintf('rDCM_%03d_tm%d_fm%d.mat',p,t,f)));
            F(p,f,t) = rDCM.F;
            clear DCM;
        end
    end
end


%% Compute confusion matrix
C_pxp = NaN(num_fitting_models, num_true_models);
C_xp = NaN(num_fitting_models, num_true_models);
for t = 1:num_true_models
    [alpha,exp_r,xp,pxp,bor] = spm_BMS(F(:,:,t));
    C_pxp(t,:) = pxp;
    C_xp(t,:) = xp;
end


%% Plot confusion matrix
fh = plot_C(C_pxp,model_names);
[~, ~] = mkdir(pplots);
saveas(gcf, fullfile(pplots,'mcomp_confusion_matrix_pxp.fig'))
saveas(gcf, fullfile(pplots,'mcomp_confusion_matrix_pxp.png'))
saveas(gcf, fullfile(pplots,'mcomp_confusion_matrix_pxp.svg'))

% fh = plot_C(C_xp,model_names);
% [~, ~] = mkdir(pplots);
% saveas(gcf, fullfile(pplots,'model_confusion_matrix_xp.fig'))
% saveas(gcf, fullfile(pplots,'model_confusion_matrix_xp.png'))
% saveas(gcf, fullfile(pplots,'model_confusion_matrix_xp.svg'))

