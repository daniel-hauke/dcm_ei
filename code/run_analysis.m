







%% Paths
setup_paths;

[~, uid] = unix('whoami');
switch uid(1: end-1)
    
    % Daniel's PC
    case 'laptop-0jhjt7kf\danie'
        presults = 'C:\projects\dcm_ei\results';
        pdata = 'C:\projects\dcm_ei\data';
        pcode = 'C:\projects\dcm_ei\code';    

    otherwise
        warning('Unknown User!')
        warning('Please specify your local paths at the top of the run_analysis.m script.')
end



%% Fit models to data
opt = struct;

% P300
data_file_name = fullfile(pdata,'p300','bsnip_p300_grandmean_hc.mat');
%data_file_name = fullfile(pdata,'p300','p300_grandmean_hc_f15.mat');
results_folder = fullfile(presults,'p300');
fit_p300_dcm(data_file_name,results_folder,opt);

% MMN
data_file_name = fullfile(pdata,'mmn','napls_mmn_grandmean_hc.mat');
results_folder = fullfile(presults,'mmn');
fit_mmn_dcm(data_file_name,results_folder,opt);

% P50
data_file_name = fullfile(pdata,'p50','P50_grandmean_HC.mat');
results_folder = fullfile(presults,'p50');
fit_p50_dcm(data_file_name,results_folder,opt);

% 40 Hz ASSR
data_file_name = fullfile(pdata,'assr','mean_S001_sensordata_spm.mat');
results_folder = fullfile(presults,'assr');
fit_assr_dcm(data_file_name,results_folder,opt);

data_file_name = fullfile(pdata,'assr','mean_S002_sensordata_spm.mat');
results_folder = fullfile(presults,'assr_replication');
fit_assr_dcm(data_file_name,results_folder,opt);

% Resting-state
data_file_name = fullfile(pdata,'rest','rs_eo_grandmean_hc.mat');
results_folder = fullfile(presults,'rest');
fit_rest_dcm(data_file_name,results_folder,opt);

data_file_name = 'F:\BSNIP\rest\rsEEG_BSNIP_preproc_v2\merged_eo_ec\0050_prep_merged_eo_ec.mat';
results_folder = fullfile(presults,'rest');
opt.fgm = 'F:\BSNIP\rest\results\rest_grandmean\HC_csd.mat';
fit_rest_dcm(data_file_name,results_folder,opt);


data_file_name = 'F:\BSNIP\rest\results\rest_grandmean\HC_all_subjects_merged.mat';
results_folder = fullfile(presults,'rest');
fit_rest_dcm(data_file_name,results_folder,opt);



%% Simulate from model
% Simulation options
sim.param           = {'G','B_g_ii','B_g_ee'};        % Parameter fields to simulate from
sim.param           = {'B_g_ii','B_g_ee'};        % Parameter fields to simulate from
sim.noise           = 'nn';                       % 'estimated' or 'nn' (no added noise)
sim.mode            = 'abs';                      % 'abs' or 'perc' for absolute value 
                                                  % or percentage value increase                      
sim.vals            = linspace(-0.5,0.5,9);       % value to be added or percentage change
sim.est             = 1;                          % simulate from estimated parameters only
sim.visibility      = 'on';
sim.linewidth       = 2;
sim.legend_fontsize = 20;
sim.plot_diff       = 1;


% P300 - single parameter simulation
sim.param = {'B_g_ee'};        % Parameter fields to simulate from
sim.chan = {'Pz'};                           % Channel to plot the simulations
sim.sim_title = {'Standard', 'Target'};           % Name of the conditions for plot
sim.vals = linspace(-0.5,0.5,9);       % value to be added or percentage change
sim.legend_loc = 'NorthEast';
sim.flip_cols = 0;
sim.psave = fullfile(presults,'p300','simulations');    % Results folder
sim.dcm = fullfile(presults,'p300','dcm','dcm_p300_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);

sim.param = {'B_g_ii'};        % Parameter fields to simulate from
sim.chan = {'Pz'};                           % Channel to plot the simulations
sim.vals = linspace(-2.5,2.5,9);       % value to be added or percentage change
sim.sim_title = {'Standard', 'Target'};           % Name of the conditions for plot
sim.legend_loc = 'NorthEast';
sim.flip_cols = 1;
sim.psave = fullfile(presults,'p300','simulations');    % Results folder
sim.dcm = fullfile(presults,'p300','dcm','dcm_p300_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);



% MMN - single parameter simulation
sim.param = {'B_g_ee'};        % Parameter fields to simulate from
sim.chan = {'Fz'};                           % Channel to plot the simulations
sim.sim_title = {'Standard', 'Deviant'};           % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.vals = linspace(-0.5,0.5,9);       % value to be added or percentage change
sim.flip_cols = 0;
sim.psave = fullfile(presults,'mmn','simulations');    % Results folder
sim.dcm = fullfile(presults,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);

sim.param = {'B_g_ii'};        % Parameter fields to simulate from
sim.flip_cols = 1;
sim.chan = {'Fz'};                           % Channel to plot the simulations
sim.vals = linspace(-2.5,2.5,9);       % value to be added or percentage change
sim.sim_title = {'Standard', 'Deviant'};           % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.psave = fullfile(presults,'mmn','simulations');    % Results folder
sim.dcm = fullfile(presults,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);

% P50 - single parameter simulation
sim.param = {'B_g_ee'};        % Parameter fields to simulate from
sim.flip_cols = 0;
sim.chan = {'Cz'};                           % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);       % value to be added or percentage change
sim.sim_title = {'S1', 'S2'};           % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.psave = fullfile(presults,'p50','simulations');    % Results folder
sim.dcm = fullfile(presults,'p50','dcm','dcm_p50_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);

sim.param = {'B_g_ii'};        % Parameter fields to simulate from
sim.flip_cols = 1;
sim.chan = {'Cz'};                           % Channel to plot the simulations
sim.vals = linspace(-2.5,2.5,9);       % value to be added or percentage change
sim.sim_title = {'S1', 'S2'};           % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.psave = fullfile(presults,'p50','simulations');    % Results folder
sim.dcm = fullfile(presults,'p50','dcm','dcm_p50_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);


% Rest
sim.param = {'B_g_ee'}; % Plot G instead of condition-specific parameter
sim.flip_cols = 0;
sim.vals = linspace(-0.5,0.5,9);       % value to be added or percentage change
sim.source =  {'lPC', 'rPC', 'lFC', 'rFC'};  % Sources to plot the simulations
sim.sim_title = {'Eyes Closed','Eyes Open'};  
sim.legend_loc = 'East';
sim.psave = fullfile(presults,'rest','simulations');    % Results folder
sim.dcm = fullfile(presults,'rest','dcm','dcm_rest_cmc_ei_v1.mat'); % DCM file
sim_csd(sim);

sim.param = {'B_g_ii'}; % Plot G instead of condition-specific parameter
sim.flip_cols = 1;
sim.source =  {'lPC', 'rPC', 'lFC', 'rFC'};  % Sources to plot the simulations
sim.sim_title = {'Eyes Closed','Eyes Open'};  
sim.legend_loc = 'East';
sim.vals = linspace(-2.5,2.5,9);       % value to be added or percentage change
sim.psave = fullfile(presults,'rest','simulations');    % Results folder
sim.dcm = fullfile(presults,'rest','dcm','dcm_rest_cmc_ei_v1.mat'); % DCM file
sim_csd(sim);

sim.param = {'G'}; % Plot G instead of condition-specific parameter
sim.flip_cols = 0;
sim.legend_fontsize = 12;
sim.source =  {'lPC', 'rPC', 'lFC', 'rFC'};  % Sources to plot the simulations
sim.sim_title = {'eyes closed','eyes open'};  
sim.legend_loc = 'East';
sim.psave = fullfile(presults,'rest','simulations','G');    % Results folder
sim.dcm = fullfile(presults,'rest','dcm','dcm_rest_cmc_ei_v1.mat'); % DCM file
sim_csd(sim);

sim.param = {'G'}; % Plot G instead of condition-specific parameter
sim.flip_cols = 1;
sim.legend_fontsize = 12;
sim.vals = linspace(-2.5,2.5,9);       % value to be added or percentage change
sim.source =  {'lPC', 'rPC', 'lFC', 'rFC'};  % Sources to plot the simulations
sim.sim_title = {'eyes closed','eyes open'};  
sim.legend_loc = 'East';
sim.psave = fullfile(presults,'rest','simulations','G_cols_flipped');    % Results folder
sim.dcm = fullfile(presults,'rest','dcm','dcm_rest_cmc_ei_v1.mat'); % DCM file
sim_csd(sim);



% ASSR
sim.param = {'G'}; % Plot G instead of condition-specific parameter
sim.legend_fontsize = 14;
sim.source = {'lTHA', 'rTHA', 'lA1', 'rA1', 'lHIP', 'rHIP'};  % Sources to plot the simulations
sim.legend_loc = 'eastoutside';
sim.sim_title = {'40 Hz ASSR'}; 
sim.psave = fullfile(presults,'assr','simulations');    % Results folder
sim.dcm = fullfile(presults,'assr','dcm','dcm_assr_cmc_ei_v1.mat'); % DCM file
%sim.dcm = fullfile(presults,'assr','dcm','dcm_assr_cmc_ei_v1_T_32_32_128_32_S_2.mat'); % DCM file
sim_csd(sim);



%% 2D Simulations
% Simulation options
sim.noise           = 'nn';                       % 'estimated' or 'nn' (no added noise)                  
sim.vals            = linspace(-0.5,0.5,9);       % value to be added or percentage change
sim.visibility      = 'on';
sim.plot_diff       = 1;
sim.tic_fontsize    = 14;    
sim.flip_cols = 0; 

% P300 - 2D grid parameter simulation
sim.psave = fullfile(presults,'p300','simulations');   
sim.dcm = fullfile(presults,'p300','dcm','dcm_p300_cmc_ei_v1.mat'); 
sim.sim_title = {'Standard', 'Target'};           
sim.chan = {'Pz'}; 
sim.time_window = {[250 600]};
sim.aggr = {'max'}; % Aggregation function
sim.cb_title = {'P300', 'P300', 'P300'};

sim.param = {'B_g_ii','B_g_ee'};        % Parameter fields to simulate from
sim.vals = {linspace(-2.5,2.5,9),linspace(-0.5,0.5,9)};       % value to be added or percentage change
sim.ylabel = 'B-g_{ii}';
sim.xlabel = 'B-g_{ee}';
sim.idx = {[1] [1]};
sim_erp_grid(sim);

sim.param = {'G','G'}; 
sim.vals = {linspace(-2.5,2.5,9),linspace(-0.5,0.5,9)};
sim.ylabel = 'g_{ii}';
sim.xlabel = 'g_{ee}';
sim.idx = {[2],[1]}; 
sim_erp_grid(sim);

% sim.param = {'G','G'}; 
% sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};
% sim.ylabel = 'g_{ii}';
% sim.xlabel = 'g_{ee}';
% sim.idx = {[2],[1]}; 
% sim_erp_grid(sim);

sim.param = {'T','B_g_ii'};
sim.vals = {linspace(-0.5,0.5,9),linspace(-2.5,2.5,9)};     
sim.ylabel = '\tau_{ii}';
sim.xlabel = 'B-g_{ii}';
sim.idx = {[3],[1]}; 
sim_erp_grid(sim);

sim.param = {'G','B_g_ii'}; 
sim.vals = {linspace(-2.5,2.5,9),linspace(-2.5,2.5,9)};  
sim.ylabel = 'g_{ii}';
sim.xlabel = 'B-g_{ii}';
sim.idx = {[2],[1]}; 
sim_erp_grid(sim);

sim.param = {'G','B_g_ee'};        % Parameter fields to simulate from
sim.vals = {linspace(-.5,0.5,9),linspace(-0.5,0.5,9)};       % value to be added or percentage change
sim.ylabel = 'g_{ee}';
sim.xlabel = 'B-g_{ee}';
sim.idx = {[1] [1]};
sim_erp_grid(sim);

sim.param = {'T','B_g_ee'};
sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};     
sim.ylabel = '\tau_{ee}';
sim.xlabel = 'B-g_{ee}';
sim.idx = {[2],[1]}; 
sim_erp_grid(sim);



% MMN - 2D grid parameter simulation
sim.psave = fullfile(presults,'mmn','simulations');    
sim.dcm = fullfile(presults,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat');
sim.chan = {'Fz'}; 
sim.sim_title = {'Standard', 'Deviant'};   
sim.time_window = {[150 250]};
sim.aggr = {'min'};
sim.cb_title = {'N2','N2','MMN'};

sim.param = {'B_g_ii','B_g_ee'};        % Parameter fields to simulate from
sim.vals = {linspace(-2.5,2.5,9),linspace(-0.5,0.5,9)};       % value to be added or percentage change
sim.ylabel = 'B-g_{ii}';
sim.xlabel = 'B-g_{ee}';
sim.idx = {[1] [1]};
sim_erp_grid(sim);


% P50 - 2D grid parameter simulation
sim.psave = fullfile(presults,'p50','simulations');    
sim.dcm = fullfile(presults,'p50','dcm','dcm_p50_cmc_ei_v1.mat'); 
sim.chan = {'Cz'}; 
sim.sim_title = {'S1', 'S2'};   
sim.time_window = {[120 250]};
sim.aggr = {'max'};
sim.cb_title = {'P2','P2','P2'};

sim.param = {'B_g_ii','B_g_ee'};        % Parameter fields to simulate from
sim.vals = {linspace(-2.5,2.5,9),linspace(-0.5,0.5,9)};       % value to be added or percentage change
sim.ylabel = 'B-g_{ii}';
sim.xlabel = 'B-g_{ee}';
sim.idx = {[1] [1]};
sim_erp_grid(sim);


% Rest
sim.psave = fullfile(presults,'rest','simulations');    % Results folder
sim.dcm = fullfile(presults,'rest','dcm','dcm_rest_cmc_ei_v1.mat'); % DCM file
sim.source =  {'lPC', 'rPC', 'lFC', 'rFC'}; 
sim.sim_title = {'Eyes Closed','Eyes Open'};   
alpha = [8 14];
sim.freq_band = {alpha};
sim.aggr = {'mean'};
sim.tic_fontsize = 18;
sim.cb_title = {'\alpha','\alpha' ,'\alpha'};

sim.param = {'B_g_ii','B_g_ee'};        % Parameter fields to simulate from
sim.vals = {linspace(-2.5,2.5,9),linspace(-0.5,0.5,9)};       % value to be added or percentage change
sim.idx ={[1] [1]};
sim.xlabel = 'B-g_{ee}';
sim.ylabel = 'B-g_{ii}';
sim_csd_grid(sim);

sim.param = {'G','G'}; 
sim.vals = {linspace(-2.5,2.5,9),linspace(-0.5,0.5,9)};
sim.ylabel = 'g_{ii}';
sim.xlabel = 'g_{ee}';
sim.idx = {[2],[1]}; 
sim_csd_grid(sim);

sim.param = {'B_g_ii','T'}; 
sim.xlabel = 'g_{ii}';
sim.ylabel = '\tau_{ii}';
sim.idx = {[1],[3]}; 
sim_csd_grid(sim);

sim.param = {'B_g_ii','G'}; 
sim.xlabel = 'B-g_{ii}';
sim.ylabel = 'g_{ii}';
sim.idx = {[1],[2]}; 
sim_csd_grid(sim);
