function sim_erp_grid(sim)



%% Defaults
clear spm_erp_L

%% Load DCM
if ischar(sim.dcm)
    load(sim.dcm);
end

%% Simulations   
% Add data files and ground truth
[~,~] = mkdir(sim.psave);

% Simulate from all the parameters
[sDCM, param_name] = sim_grid(DCM, sim.param{1}, sim.param{2}, sim);


% Plot grid
for chan = 1:numel(sim.chan)
    for comp = 1:numel(sim.time_window)
        for agg = 1:numel(sim.aggr)
            fh = plot_sim_erp_grid(sDCM, sim.chan{chan}, sim.time_window{comp}, sim.aggr{agg}, sim);
            save_name = sprintf('grid_%s_%s_%s_%d-%d', param_name, sim.chan{chan}, sim.aggr{agg}, sim.time_window{comp}(1), sim.time_window{comp}(2));
            saveas(fh, fullfile(sim.psave, [save_name '.png']));
        end
    end
end