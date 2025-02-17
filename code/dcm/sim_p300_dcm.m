function sim_p300_dcm(dcm_file)





%% Options

% Condition names
opt.conditions = {'Std', 'Dev'};
                               
% Simulation options
sim.noise = 'nn';                       % 'estimated' or 'nn' (no added noise)
sim.mode  = 'abs';                      % 'abs' or 'perc' for absolute value 
                                        % or percentage value increase                      
sim.vals  = linspace(-0.5,0.5,9);         % value to be added or percentage change
sim.est   = 1;                          % simulate from estimated parameters only

% Parameters to change in simulations 
sim.cmc_param = {'B_g_ii','B_g_ee'};
   
% Simulation plot options
sim.chan            = {'Pz','Cz'};    % Channel to plot the simulations
sim.visibility      = 'off';
sim.linewidth       = 1;
sim.legend_fontsize = 2;



%% Defaults
if ischar(dcm_file)
    load(dcm_file);
end



%% Simulations
if opt.run_sim
    
    % Convert legend entries to strings
    sim.legend_sim = arrayfun(@num2str, sim.vals , 'UniformOutput', false);
    
    % Set val of 0 to Ep in the legend (corresponds to the posterior)
    try sim.legend_sim{sim.vals==0} = 'Ep'; end % try and catch, since user might not have specified a value of 0
    
    % Create simulation plot titles
    sim.truth_title = opt.conditions;
    
    %-------------------------------------------
    % 4-population convolution-based model (CMC)
    %-------------------------------------------
    % Add data files and ground truth
    sim.dcm   = DCM.name;
    sim.psave = fullfile(opt.pplots, 'simulations');
    [~,~] = mkdir(sim.psave);
    sim.sim_title = opt.conditions ;
    sim.legend_fontsize = 14;
    
    % Simulate from all the parameters
    for p = 1:numel(sim.cmc_param)
        [sDCM, param_name] = sim_individual(DCM, sim.cmc_param{p}, sim);
        
        for pp = 1:numel(param_name)
            for c = 1:numel(sim.chan)
                sim.legend_sim_title =  sim.cmc_param{p};
                fh = plot_sim_dcms(sDCM, sim.chan{c}, sim);
                save_name = sprintf('%s_%s', sim.chan{c}, sim.cmc_param{p});
                saveas(fh, fullfile( sim.psave , [save_name '.png']));
            end
        end
    end
end


%% Clean up
t_done = toc;
fprintf('\n===\n\t Subject finished after %s (HH:MM:SS)!\n\n', datestr(datenum(0,0,0,0,0,t_done),'HH:MM:SS'));

diary off



