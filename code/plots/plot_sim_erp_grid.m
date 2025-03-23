function fh = plot_sim_erp_grid(sDCM, channel, time_window, aggr, opt)
%--------------------------------------------------------------------------
% Function description goes here
%--------------------------------------------------------------------------


%% Defaults
if ~isfield(opt, 'visibility'); opt.visibility = 'on'; end
if isfield(opt, 'truth'); plot_truth = 1; else; plot_truth = 0; end
if ~isfield(opt, 'subplot_titles'); opt.subplot_titles = []; end
if ~isfield(opt, 'plot_diff'); opt.plot_diff = 0; end

try ep_row = find(opt.vals{1}==0); catch ep_row = []; end
try ep_col = find(opt.vals{2}==0); catch ep_col = []; end

aggr = str2func(aggr);

%% Get Difference between conditions
if opt.plot_diff
    n_conds = numel(sDCM{1}.xY.y)+1;
    for i = 1:size(sDCM,1)
        for j = 1:size(sDCM,2)
            sDCM{i,j}.xY.y{n_conds} = sDCM{i,j}.xY.y{2}-sDCM{i,j}.xY.y{1};
        end
    end
    opt.sim_title = [opt.sim_title [opt.sim_title{2} '-' opt.sim_title{1}]];
else
    n_conds = numel(sDCM{1,1}.xY.y);
end


%% Get comparison data either from DCM or from opt.truth
t = sDCM{1,1}.xY.pst;
idx_chan = find(strcmp(sDCM{1,1}.M.dipfit.sens.label, channel));
idx_time = find((time_window(2)>t) & (t>time_window(1)));


%% Get simulated responses from DCM
for i = 1:size(sDCM,1)
    for j = 1:size(sDCM,2)
        for c = 1:n_conds
            % Observed respones for first condition
            y_sim(i,j,c) = aggr(sDCM{i,j}.xY.y{c}(idx_time,idx_chan));
        end
    end
end

% Normalise by posterior estimate
if ~isempty(ep_row)
    for c = 1:n_conds
        y_ep(c) =  y_sim(ep_row,ep_col,c);
        
        for i = 1:size(sDCM,1)
            for j = 1:size(sDCM,2)
                y_sim(i,j,c) =   y_sim(i,j,c)-y_ep(c);
            end
        end
    end
end



%% Plot
% Some color options
warm_cols = flipud(autumn(100));
cold_cols = winter(100);
colors_sim = [cold_cols; [0 0 0]; warm_cols];

if isfield(opt,'flip_cols')
    if opt.flip_cols
        warm_cols = autumn(100);
        cold_cols = flipud(winter(100));
        colors_sim = [warm_cols; [0 0 0]; cold_cols];
    end
end

% Convert legend entries to strings
opt.vals{1} = arrayfun(@num2str, opt.vals{1}, 'UniformOutput', false);
opt.vals{2} = arrayfun(@num2str, opt.vals{2}, 'UniformOutput', false);

% Set val of 0 to Ep in the legend (corresponds to the posterior)
try opt.vals{1}{strcmp(opt.vals{1},'0')} = 'Ep'; end % try and catch, since user might not have specified a value of 0
try opt.vals{2}{strcmp(opt.vals{2},'0')} = 'Ep'; end % try and catch, since user might not have specified a value of 0

% Some figure settings
scrsz = get(0,'screenSize');
%fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.95*scrsz(3),0.5*scrsz(4)],'Visible', opt.visibility);
fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.95*scrsz(3),0.5*scrsz(4)],'Visible', opt.visibility);
set(0,'DefaultAxesFontSize',20,'defaultLegendInterpreter','none')
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')

% Plot simulations
for c = 1:n_conds
    ax{1,c} = subplot(1,n_conds,c);
    
    data = y_sim(:,:,c);
    
    %// Define integer grid of coordinates for the above data
    [X,Y] = meshgrid(1:size(data,2), 1:size(data,1));
    
    %// Define a finer grid of points
    [X2,Y2] = meshgrid(1:0.01:size(data,2), 1:0.01:size(data,1));
    
    %// Interpolate the data and show the output
    outData = interp2(X, Y, data, X2, Y2, 'linear');
    
    imagesc(outData);
    %imagesc(data, 'Interpolation', 'bilinear')
    
    new_xticks = [1 [1:(size(data,1)-1)].*100];
    new_xticks = new_xticks(1:2:end); % only use every other tick
    new_xticklabels = opt.vals{2}(1:2:end);
    new_yticklabels = opt.vals{1}(1:2:end);
    
    %     try xticks([1 [1:(size(data,1)-1)].*100]); xticklabels(opt.vals); end
    %     try yticks([1 [1:(size(data,2)-1)].*100]); yticklabels(opt.vals); end
    try xticks(new_xticks); xticklabels(new_xticklabels); end
    try yticks(new_xticks); yticklabels(new_yticklabels); end
    try a = get(gca,'XTickLabel'); set(gca,'XTickLabel',a,'FontSize',opt.tic_fontsize); end
    try a = get(gca,'YTickLabel'); set(gca,'YTickLabel',a,'FontSize',opt.tic_fontsize); end
    try xlabel(opt.xlabel, 'FontSize', 16); end
    try ylabel(opt.ylabel, 'FontSize', 16); end
    hcb = colorbar;
    try htcb = get(hcb,'Title'); set(htcb ,'String',opt.cb_title{c},'FontWeight','normal'); end
    colormap(colors_sim)
    title(opt.sim_title{c}, 'FontSize', 16, 'Fontweight','normal');
    %caxis([-max(max(abs(y_sim(:,:,c)))), max(max(abs(y_sim(:,:,c))))]);
    caxis([-max(abs(y_sim(:))), max(abs(y_sim(:)))]);
    axis square
    
end


