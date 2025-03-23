function sim_csd_grid(sim)





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
for s = 1:numel(sim.source)
    for b = 1:numel(sim.freq_band)
        for a = 1:numel(sim.aggr)
            fh = plot_sim_csd_grid(sDCM, sim.source{s},sim.freq_band{b}, sim.aggr{a}, sim);
            save_name = sprintf('grid_%s_%s_%s_%d-%d',param_name,sim.source{s},sim.aggr{a},round(sim.freq_band{b}(1)),round(sim.freq_band{b}(2)));
            for f = 1:numel(fh)
                saveas(fh{f}, fullfile(sim.psave, [save_name '_cond' num2str(f) '.png']));
            end
        end
    end
end


