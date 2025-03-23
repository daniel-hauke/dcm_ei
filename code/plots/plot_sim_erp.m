function fh = plot_sim_erp(sDCM, chan, opt)
%--------------------------------------------------------------------------
% Function description goes here
%--------------------------------------------------------------------------


%% Defaults
if ~isfield(opt, 'visibility'); opt.visibility = 'on'; end
if isfield(opt, 'truth'); plot_truth = 1; else; plot_truth = 0; end
if ~isfield(opt, 'linewidth'); opt.linewidth = 1; end
if ~isfield(opt, 'subplot_titles'); opt.subplot_titles = []; end
if ~isfield(opt, 'plot_diff'); opt.plot_diff = 0; end
if ~isfield(opt, 'legend_loc'); opt.legend_loc = 'best'; end


%% Get Difference between conditions
if opt.plot_diff
     n_conds = numel(sDCM{1}.xY.y)+1;
     for i = 1:numel(sDCM)
         sDCM{i}.xY.y{n_conds} = sDCM{i}.xY.y{2}-sDCM{i}.xY.y{1};
     end
     opt.sim_title = [opt.sim_title [opt.sim_title{2} '-' opt.sim_title{1}]];
else
    n_conds = numel(sDCM{1}.xY.y); 
end


%% Get comparison data either from DCM or from opt.truth
% Get meta data
D = spm_eeg_load(sDCM{1}.xY.Dfile);
t_DCM = sDCM{1}.xY.pst';

idx_chan = find(strcmp(chanlabels(D), chan));


%% Get simulated responses from DCM
for i = 1:numel(sDCM)
    for c = 1:n_conds
        % Observed respones for first condition
        y_sim(:,i,c) = sDCM{i}.xY.y{c}(:,idx_chan);
    end
end


%% Plot
% Some color options
colors_true = [0 0 0; .5 .5 .5];
warm_cols = flipud(autumn(sum(opt.vals>0)));
cold_cols = winter(sum(opt.vals<0));
colors_sim = [cold_cols; [0 0 0]; warm_cols];

if isfield(opt,'flip_cols')
    if opt.flip_cols
        warm_cols = autumn(sum(opt.vals<0));
        cold_cols = flipud(winter(sum(opt.vals>0)));
        colors_sim = [warm_cols; [0 0 0]; cold_cols];
    end
end

% Some figure settings
scrsz = get(0,'screenSize');
fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.9*scrsz(3),0.5*scrsz(4)],'Visible', opt.visibility);
fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.9*scrsz(3),0.6*scrsz(4)],'Visible', opt.visibility);
set(0,'DefaultAxesFontSize',20,'defaultLegendInterpreter','none')
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')


% Plot simulations
for c = 1:n_conds
    %ax{1,c} = subplot(1,n_conds+1,c);
     ax{1,c} = subplot(1,n_conds,c);
    hold all;
    for i = 1:numel(sDCM)
        p{i} = plot(t_DCM,y_sim(:,i,c),'Color',colors_sim(i,:),'LineWidth',opt.linewidth);
    end
    %if c==1 && isfield(opt, 'legend_sim'); l{2,c}=legend(opt.legend_sim,'Location',opt.legend_loc); l{2,c}.FontSize = opt.legend_fontsize; end
    %if c==1 && isfield(opt, 'legend_sim_title'); title(l{2,c},opt.legend_sim_title); end
    if isfield(opt, 'sim_title'); title(opt.sim_title{c},'FontWeight','normal'); end
    xlabel('Time [ms]');
    ylabel(sprintf('%s [%s]',chan,'a.u.'));
    xlim([min(t_DCM) max(t_DCM)]);
end
% 
% hL = subplot(subplot(1,n_conds+1,n_conds+1));
% poshL = get(hL,'position');     % Getting its position
% 
% lgd = legend(hL,[p{1,:}],opt.legend_sim);
% try lgd.FontSize = opt.legend_fontsize;end 
% set(lgd,'position',poshL);      % Adjusting legend's position
% axis(hL,'off');                 % Turning its axis off

linkaxes([ax{1,:}],'xy');
ylim([min(y_sim(:))-0.05*range(y_sim(:)) max(y_sim(:))+0.05*range(y_sim(:))])
xlim([min(t_DCM) max(t_DCM)]);

%set(gcf, 'Color', 'None')
