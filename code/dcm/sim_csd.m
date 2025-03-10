function sim_csd(sim)




%% Load DCM
if ischar(sim.dcm)
    load(sim.dcm);
end


%% Simulations
try sim_title = sim.sim_title; end


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
        for c = 1:numel(sim.source)
            sim.legend_sim_title =  param_name{pp};
            sim.sim_title = strcat(sim.source(c),{' '},sim_title);
            fh = plot_sim_csd(sDCM(:,pp), sim.source{c}, sim);
            save_name = sprintf('%s_%s', sim.source{c}, param_name{pp});
            saveas(fh, fullfile( sim.psave , [save_name '.png']));
            
            fh = plot_sim_csd_1f_slope(sDCM(:,pp), sim.source{c}, sim);
            save_name = sprintf('%s_%s_1f_slope', sim.source{c}, param_name{pp});
            saveas(fh, fullfile( sim.psave , [save_name '.png']));
        end
    end
end
