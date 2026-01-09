function [fh] = plot_bms(pxp, exp_r, model_names)
%--------------------------------------------------------------------------
% Function that creates a summary plot showing both protected exceedance 
% probabilities and expected model frequencies based on the posterior 
% output from spm_bms.m
%
% IN:
%   pxp         -> protected exceedance probabilities
%   exp_r       -> expected model frequencies
%   model_names -> cell array with model names to be used in plot
%  
% OUT:
%   fh          -> Figure handle
%--------------------------------------------------------------------------


%% Main
% Set some graphic defaults
axes_label_font_size = 14;
set(0,'DefaultAxesFontSize',12,'defaultLegendInterpreter','none')
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')

n_mod = length(pxp);

% Display values in command window
fprintf('\nSummary BMS:\n');
for m=1:n_mod
    fprintf('Model: %s, PXP: %.4f, EF: %.4f\n', model_names{m}, pxp(m), exp_r(m)); 
end



% Plot
fh = figure('name', 'Bayesian Model Comparison',...
    'Position',  [100, 100, 900, 400]);
% fh = figure('name', 'Bayesian Model Comparison',...
%     'Position',  [100, 100, 400, 400]);
hold on
subplot(1,2,1)
bar(pxp, 'FaceColor', [.8 .8 .8]);
line([0,n_mod+1], [.95,.95], 'Color','red', 'LineStyle', ':');
xlabel('Models', 'FontSize', axes_label_font_size, 'Color','k');
ylabel('Protected Exceedance Probability', 'FontSize', axes_label_font_size, 'Color','k');
xticks(1:n_mod);
if ~isempty(model_names); xticklabels(model_names); end
ylim([0 1.05])
xlim([0 n_mod+1])
%xtickangle(45)
box on;
hold off

subplot(1,2,2)
hold on
bar(exp_r, 'FaceColor', [.8 .8 .8]);
line([0, n_mod+1],[1, 1]/n_mod,'Color','red','LineStyle',':');
xlabel('Models', 'FontSize', axes_label_font_size, 'Color','k');
ylabel('Expected Frequency', 'FontSize', axes_label_font_size, 'Color','k');
xticks(1:n_mod);
if ~isempty(model_names); xticklabels(model_names); end
ylim([0 1.05])
xlim([0 n_mod+1])
%xtickangle(45)
box on;
hold off


