function fh = plot_sim_csd_1f_slope(sDCM, source, opt)
%--------------------------------------------------------------------------
% Function description goes here
%--------------------------------------------------------------------------


%% Defaults
if ~isfield(opt, 'visibility'); opt.visibility = 'on'; end
if ~isfield(opt, 'linewidth'); opt.linewidth = 1; end
if ~isfield(opt, 'legend_loc'); opt.legend_loc = 'southwest'; end


opt.legend_loc = 'southwest';

%% Get comparison data either from DCM or from opt.truth
n_conds = numel(sDCM{1}.Hs);
idx_source = find(strcmp(sDCM{1}.Sname, source));


%%
%delta = [0 3.5];
theta = [3.5 7.5];
alpha = [7.5 14.5];
beta  = [14.5 30];
gamma = [30 50];



%% Get simulated responses from DCM
for i = 1:numel(sDCM)
    for c = 1:n_conds
        % Observed respones for first condition
        y_sim(:,i,c) = log(real(sDCM{i}.Hs{c}(:,idx_source,idx_source)));
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
%fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.35*scrsz(3),.6*scrsz(4)],'Visible', opt.visibility);
fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.4*scrsz(3),0.6*scrsz(4)],'Visible', opt.visibility);
set(0,'DefaultAxesFontSize',20,'defaultLegendInterpreter','none')
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')

% Plot simulations
for c = 1:n_conds
    ax{1,c} = subplot(1,n_conds,c);
    hold all;
    for i = 1:numel(sDCM)
        plot(log(sDCM{1}.Hz),y_sim(:,i,c),'Color',colors_sim(i,:),'LineWidth',opt.linewidth)
    end
    %if c==1 && isfield(opt, 'legend_sim'); l{2,c}=legend(opt.legend_sim,'Location',opt.legend_loc); l{2,c}.FontSize = opt.legend_fontsize; end
    %if c==1 && isfield(opt, 'legend_sim_title'); title(l{2,c},opt.legend_sim_title); end
    if isfield(opt, 'sim_title'); title(opt.sim_title{c},'Fontweight','normal'); end
    xlabel('Frequency [log(Hz)]');
    ylabel(sprintf('Amplitude [log(%s)]','a.u.'));
    %xlim([min(sDCM{1}.Hz) max(sDCM{1}.Hz)]);
    
%     % Plot spectra lines
%     if theta(2)>= min(sDCM{1}.Hz)
%         xline(theta(1),'--','HandleVisibility','off', 'LineWidth',1);
%         xline(theta(2),'--','HandleVisibility','off', 'LineWidth',1);
%         text(theta(1)+(theta(2)-theta(1))/2,max(y_sim(:)),'\theta','FontSize',14, 'Fontweight','bold','HorizontalAlignment', 'center')
%     end
%     if alpha(2)>= min(sDCM{1}.Hz)
%         xline(alpha(1),'--','HandleVisibility','off', 'LineWidth',1);
%         xline(alpha(2),'--','HandleVisibility','off', 'LineWidth',1);
%         text(alpha(1)+(alpha(2)-alpha(1))/2,max(y_sim(:)),'\alpha','FontSize',14, 'Fontweight','bold','HorizontalAlignment', 'center')
%     end
%     if beta(2)>= min(sDCM{1}.Hz)
%         xline(beta(1),'--','HandleVisibility','off', 'LineWidth',1);
%         xline(beta(2),'--','HandleVisibility','off', 'LineWidth',1);
%         text(beta(1)+(beta(2)-beta(1))/2,max(y_sim(:)),'\beta','FontSize',14, 'Fontweight','bold','HorizontalAlignment', 'center')
%     end
%     if gamma(2)>= min(sDCM{1}.Hz)
%         xline(gamma(1),'--','HandleVisibility','off', 'LineWidth',1);
%         xline(gamma(2),'--','HandleVisibility','off', 'LineWidth',1);
%         text(gamma(1)+(gamma(2)-gamma(1))/2,max(y_sim(:)),'\gamma','FontSize',14, 'Fontweight','bold','HorizontalAlignment', 'center')
%     end
xline(log(20),'--','HandleVisibility','off', 'LineWidth',1)
text(log(20),max(y_sim(:)),'20 Hz','FontSize',16,'HorizontalAlignment', 'center')
xline(log(40),'--','HandleVisibility','off', 'LineWidth',1)
text(log(40),max(y_sim(:)-0.1*range(y_sim(:))),'40 Hz','FontSize',16,'HorizontalAlignment', 'center')
end

linkaxes([ax{1,:}],'xy');
ylim([min(y_sim(:))-0.05*range(y_sim(:)) max(y_sim(:))+0.05*range(y_sim(:))])
%xlim([min(sDCM{1}.Hz) max(sDCM{1}.Hz)]);
%xlim([log(20) log(40)]);

