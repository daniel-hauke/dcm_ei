%% Plot actual vs predicted responses for model paper

% Path
files = {'C:\projects\dcm_ei\results\p50\dcm\dcm_p50_cmc_ei_v1.mat';
    'C:\projects\dcm_ei\results\mmn\dcm\dcm_mmn_cmc_ei_v1.mat';
    'C:\projects\dcm_ei\results\p300_napls\dcm\dcm_p300_cmc_ei_v1.mat'};
pplots = 'C:\projects\dcm_ei\results\paper_figures';

%% Figure settings
min_fontsize = 12;
set(0,'DefaultAxesFontSize',min_fontsize,'defaultLegendInterpreter','none')
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')
set(0,'DefaultFigureColor',[1 1 1]);

fh = figure('units','normalized','outerposition',[0 0 0.45 1]);

% Plot
j = 1;

for i = 1:numel(files)
    load(files{i})

    %% Get important variables
    U = DCM.M.U';
    t = DCM.xY.pst;
    n_cond = size(DCM.H,2);
    
    [~, fname, ext] = fileparts(files{i});
    task = extractBetween(fname,'dcm_','_cmc');
    switch task{1}
        case 'mmn'
            chan_id = find(strcmp(DCM.xY.name,'Cz'));
            cond_labels = {'Standard','Deviant','Deviant-Standard'};
        case 'p300'
            chan_id = find(strcmp(DCM.xY.name,'Pz'));
            cond_labels = {'Standard','Target','Target-Standard'};
        case 'p50'
            chan_id = find(strcmp(DCM.xY.name,'Cz'));
            cond_labels = {'S1','S2','S2-S1'};
    end

    %% Setup
    switch task{1}
        case 'p50'
            col_obs = [254, 204, 92]/256; % orange
            col_pred = [253, 141, 60]/256;
            chan_label = 'EEG [a.u.]';
             chan_label = '';
        case 'mmn'
            col_obs = [153, 216, 201]/256; % green
            col_pred = [44, 162, 95]/256;
            chan_label = 'EEG [a.u.]';
            chan_label = '';
        case 'p300'
            col_obs = [166, 189, 219]/256; % blue
            col_pred = [43, 140, 190]/256;
            chan_label = 'EEG [a.u.]';
            chan_label = '';
    end

    %% Plot
    for c = 1:n_cond+1
        is_diff = (c == 3);

        % Compute observed and predicted responses
        if is_diff
            y_obs = (DCM.H{2} + DCM.R{2})*U - (DCM.H{1} + DCM.R{1})*U;
            y_pred = DCM.H{2}*U - DCM.H{1}*U;
        else
            y_obs = (DCM.H{c} + DCM.R{c})*U;
            y_pred = DCM.H{c}*U;
        end

        % Observed response
        ax(j) = subplot(numel(files)*2,3,j);
        plot(t, y_obs, 'Color', col_obs, 'LineWidth', 0.3);
        if c==1
            ylabel(chan_label);
        end
        xlim([min(t), max(t)]);
        title(cond_labels{c}, 'FontWeight', 'normal');

        % Predicted response
        ax(j+3) = subplot(numel(files)*2,3,j+3);
        plot(t, y_pred, 'Color', col_pred, 'LineWidth', 0.3);
        if c==1
            ylabel(chan_label);
        end
        xlabel('Time [ms]', 'FontSize', min_fontsize+2);
        xlim([min(t), max(t)]);
        % title(cond_labels{c}, 'FontWeight', 'normal');

        j = j + 1;
    end
    j = j + 3;
end

% Link axes
linkaxes(ax(1:6), 'xy');
linkaxes(ax(7:12), 'xy');
linkaxes(ax(13:18), 'xy');

% Remove box from all axes
allAxes = findall(fh, 'Type', 'axes');
set(allAxes, 'box', 'off');

% Make axes gray
% set(allAxes, 'XColor', [0.5 0.5 0.5], 'YColor', [0.5 0.5 0.5]);

%% Adjust position of plots
for idx = [4:6,10:12,16:18]
    pos = get(ax(idx), 'Position');
    pos(2) = pos(2) + 0.015;
    set(ax(idx), 'Position', pos);
end

%% Save
saveas(gcf, fullfile(pplots, 'model_fit.svg'));
saveas(gcf, fullfile(pplots, 'model_fit.png'));