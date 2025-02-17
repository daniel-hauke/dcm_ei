function sim_erp(sim)




%% Load DCM
if ischar(sim.dcm)
    load(sim.dcm);
end


%% Simulations   
% Convert legend entries to strings
sim.legend_sim = arrayfun(@num2str, sim.vals , 'UniformOutput', false);

% Set val of 0 to Ep in the legend (corresponds to the posterior)
try sim.legend_sim{sim.vals==0} = 'Ep'; end % try and catch, since user might not have specified a value of 0


% Add data files and ground truth
[~,~] = mkdir(sim.psave);

% Simulate from all the parameters
for p = 1:numel(sim.param)
    [sDCM, param_name] = sim_individual(DCM, sim.param{p}, sim);
    
    for pp = 1:numel(param_name)
        for c = 1:numel(sim.chan)
            sim.legend_sim_title = sim.param{p};
            sim.legend_sim_title = param_name{pp};
            fh = plot_sim_erp(sDCM(:,pp), sim.chan{c}, sim);
            save_name = sprintf('%s_%s', sim.chan{c}, param_name{pp});
            saveas(fh, fullfile( sim.psave , [save_name '.png']));
        end
    end
end
