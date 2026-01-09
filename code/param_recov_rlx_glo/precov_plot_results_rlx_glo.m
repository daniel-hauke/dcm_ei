function [i] = precov_plot_results_rlx_glo(presults, pplots, which_params, param_names,col)
%--------------------------------------------------------------------------
% Function to reinvert DCM on simulated data on the cluster.
%--------------------------------------------------------------------------
% 
% presults = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\estimated';
% pplots = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\estimated\plots';
% which_params = [309 310];
% param_names = {'B-g_{ee}', 'B-g_{ii}'};
% 
% presults = 'C:\projects\dcm_ei\results\p50\parameter_recovery\estimated';
% pplots = 'C:\projects\dcm_ei\results\p50\parameter_recovery\estimated\plots';
% which_params = [309 310];
% param_names = {'B-g_{ee}', 'B-g_{ii}'};
% 
% presults = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\estimated';
% pplots = 'C:\projects\dcm_ei\results\mmn\parameter_recovery\estimated\plots';
% which_params = [309 310];
% param_names = {'B-g_{ee}', 'B-g_{ii}'};


%% Paths
[~,~] = mkdir(pplots);

%% Get files
psim = fullfile(presults,'sim_dcms');
prec = fullfile(presults,'rec_dcms');

temp = dir(fullfile(psim,'*.mat'));
sim_files = fullfile({temp.folder}',{temp.name}');

temp = dir(fullfile(prec,'*.mat'));
rec_files = fullfile({temp.folder}',{temp.name}');


%% Collect parameters
clear p_sim p_rec
for s = 1:numel(rec_files)
    
    if isfile(sim_files{s})&& isfile(rec_files{s})
        load(sim_files{s});
        p_sim(s,:) = full(spm_vec(sDCM.Ep));
        
        load(rec_files{s});
        p_rec(s,:) = full(spm_vec(rDCM.Ep));
        %p_rec(s,:) = full(spm_vec(sDCM.Ep));
        clear sDCM rDCM
    else
        warning('Participant %d has no reinverted DCM file',s)
    end
end
p_sim = p_sim(:,which_params);
p_rec = p_rec(:,which_params);


%% Plot parameters
% Options
min_fontsize = 12;
%min_fontsize = 6;
set(0,'DefaultAxesFontSize',min_fontsize,'defaultLegendInterpreter','none')
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')

% Prepare grid
n_params = numel(which_params);
rows = floor(sqrt(n_params)); % Start with square root approximation
cols = ceil(n_params / rows);
while rows * cols < n_params
    cols = cols + 1;
end

% Plot
%figure('units', 'normalized', 'outerposition', [0 0 .6 .5], 'Visible', 'on');
figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Visible', 'on');
for i_p = 1:numel(which_params)
    
    [r,p] = corr(p_sim(:,i_p), p_rec(:,i_p));
    [i(i_p,1), LB, UB] = ICC([p_sim(:,i_p) p_rec(:,i_p)], '1-1');
    
    if p < 0.001
        p_verb = 'p < 0.001';
    else
        p_verb = ['p = ' num2str(round(p,3))];
    end

    subplot(rows,cols,i_p)
%     scatter(p_sim(:,i_p), p_rec(:,i_p), 40,...
%         'MarkerFaceColor', [.2 .2 .2],...
%         'MarkerEdgeColor', 'k')
      scatter(p_sim(:,i_p), p_rec(:,i_p), 40,...
        'MarkerFaceColor', col,...
        'MarkerEdgeColor', 'k')
    alpha(.5);
    lsline;
%     text(.7,.18,...
%         sprintf('r = %.2f\nf^{2} = %.2f\n%s', r, r^2/(1-r^2), p_verb),...
%         'FontSize', min_fontsize, 'Units', 'normalized');
    text(.05,.9,...
        sprintf('ICC = %.2f\nr = %.2f\n%s',i(i_p), r, p_verb),...
        'FontSize', min_fontsize, 'Units', 'normalized');
    xlabel([param_names{i_p} ' (simulated)'],'FontSize', min_fontsize+4);
    ylabel([param_names{i_p} ' (recovered)'],'FontSize', min_fontsize+4);
    
    maxval = max(max(p_sim(:,i_p)), max(p_rec(:,i_p)));
    minval = min(min(p_sim(:,i_p)), min(p_rec(:,i_p)));
%     maxval = max(p_sim(:,i_p));
%     minval = min(p_sim(:,i_p));
    rangeval = range([minval maxval]);
    eps = 0.1;
    
    xlim([minval-eps*rangeval maxval+eps*rangeval])
    ylim([minval-eps*rangeval maxval+eps*rangeval])  
    
    %title(param_names{i_p},'FontSize', min_fontsize+8)
end
saveas(gcf, fullfile(pplots,'parameter_recovery.fig'))
saveas(gcf, fullfile(pplots,'parameter_recovery.png'))

% %% Remove outliers
% % include = ~(isoutlier(p_rec,'quartiles'));
% include = ~(isoutlier(p_rec,'quartiles') | isoutlier(p_sim,'quartiles'));
% warning('There are %d outliers that will be removed.',sum(~include(:)))
% 
% % Options
% min_fontsize = 12;
% set(0,'DefaultAxesFontSize',min_fontsize,'defaultLegendInterpreter','none')
% set(0,'DefaultAxesFontName','Aptos')
% set(0,'DefaultAxesFontWeight','normal')
% 
% % Prepare grid
% n_params = numel(which_params);
% rows = floor(sqrt(n_params)); % Start with square root approximation
% cols = ceil(n_params / rows);
% while rows * cols < n_params
%     cols = cols + 1;
% end
% 
% % Plot
% %figure('units', 'normalized', 'outerposition', [0 0 .6 .5], 'Visible', 'on');
% figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Visible', 'on');
% for i_p = 1:numel(which_params)
%     
%     [r,p] = corr(p_sim(include(:,i_p),i_p), p_rec(include(:,i_p),i_p));
%     [i, LB, UB] = ICC([p_sim(include(:,i_p),i_p) p_rec(include(:,i_p),i_p)], '1-1');
%     if p < 0.001
%         p_verb = 'p < 0.001';
%     else
%         p_verb = ['p = ' num2str(round(p,3))];
%     end
% 
%     subplot(rows,cols,i_p)
% %     scatter(p_sim(include(:,i_p),i_p), p_rec(include(:,i_p),i_p), 40,...
% %         'MarkerFaceColor', [.2 .2 .2],...
% %         'MarkerEdgeColor', 'k')
%      scatter(p_sim(include(:,i_p),i_p), p_rec(include(:,i_p),i_p), 40,...
%         'MarkerFaceColor', col,...
%         'MarkerEdgeColor', 'k')
%     alpha(.5);
%     lsline;
% %     text(.7,.18,...
% %         sprintf('r = %.2f\nf^{2} = %.2f\n%s', r, r^2/(1-r^2), p_verb),...
% %         'FontSize', min_fontsize, 'Units', 'normalized');
%     text(.05,.9,...
%         sprintf('ICC = %.2f\nr = %.2f\n%s',i,r, p_verb),...
%         'FontSize', min_fontsize, 'Units', 'normalized');
%     xlabel([param_names{i_p} ' (simulated)'],'FontSize', min_fontsize+4);
%     ylabel([param_names{i_p} ' (recovered)'],'FontSize', min_fontsize+4);
%     
%     maxval = max(p_sim(include(:,i_p),i_p));
%     minval = min(p_sim(include(:,i_p),i_p));
%     rangeval = range([minval maxval]);
%     eps = 0.1;
%     
%     xlim([minval-eps*rangeval maxval+eps*rangeval])
%     ylim([minval-eps*rangeval maxval+eps*rangeval])  
%     axis('square');
%     %title(param_names{i_p},'FontSize', min_fontsize+8,'FontWeight','normal')
% end
% 
% saveas(gcf, fullfile(pplots,'parameter_recovery_outliers_removed.fig'))
% saveas(gcf, fullfile(pplots,'parameter_recovery_outliers_removed.png'))
% saveas(gcf, fullfile(pplots,'parameter_recovery_outliers_removed.svg'))
