







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
% P300
data_file_name = fullfile(pdata,'p300','bsnip_p300_grandmean_hc.mat');
results_folder = fullfile(presults,'p300');
fit_p300_dcm(data_file_name,results_folder);

% MMN
data_file_name = fullfile(pdata,'mmn','napls_mmn_grandmean_hc.mat');
results_folder = fullfile(presults,'mmn');
fit_mmn_dcm(data_file_name,results_folder);

% P50
data_file_name = fullfile(pdata,'p50','P50_grandmean_HC.mat');
results_folder = fullfile(presults,'p50');
fit_p50_dcm(data_file_name,results_folder);


% 40 Hz ASSR
data_file_name = fullfile(pdata,'assr','mean_S001_sensordata_spm.mat');
results_folder = fullfile(presults,'assr');
fit_assr_dcm(data_file_name,results_folder);

% Resting-state
data_file_name = fullfile(pdata,'rest','rs_eo_grandmean_hc.mat');
results_folder = fullfile(presults,'rest');
fit_rest_dcm(data_file_name,results_folder);



%% Simulate from model
% Simulation options
sim.param           = {'G','B_g_ii','B_g_ee'};        % Parameter fields to simulate from
sim.noise           = 'nn';                       % 'estimated' or 'nn' (no added noise)
sim.mode            = 'abs';                      % 'abs' or 'perc' for absolute value 
                                                  % or percentage value increase                      
sim.vals            = linspace(-0.5,0.5,9);       % value to be added or percentage change
sim.est             = 1;                          % simulate from estimated parameters only
sim.visibility      = 'off';
sim.linewidth       = 1;
sim.legend_fontsize = 10;
sim.plot_diff       = 1;

% P300
sim.chan = {'Pz','Cz'};                           % Channel to plot the simulations
sim.sim_title = {'Standard', 'Target'};           % Name of the conditions for plot
sim.legend_loc = 'NorthEast';
sim.psave = fullfile(presults,'p300','simulations');    % Results folder
sim.dcm = fullfile(presults,'p300','dcm','dcm_p300_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);

% MMN
clear spm_erp_L  % This script generates some persitant variabls called LastLpos LastL that need to be cleared
sim.chan = {'Fz','Cz'};                           % Channel to plot the simulations
sim.sim_title = {'Standard', 'Deviant'};           % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.psave = fullfile(presults,'mmn','simulations');    % Results folder
sim.dcm = fullfile(presults,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);


% P50
sim.chan = {'Pz','Cz'};                           % Channel to plot the simulations
sim.sim_title = {'S1', 'S2'};           % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.psave = fullfile(presults,'p50','simulations');    % Results folder
sim.dcm = fullfile(presults,'p50','dcm','dcm_p50_cmc_ei_v1.mat'); % DCM file
sim_erp(sim);


% Options CSD
sim.param = {'G'}; % Plot G instead of condition-specific parameter
sim.legend_fontsize = 12;

% Rest
clear spm_erp_L  % This script generates some persitant variabls called LastLpos LastL that need to be cleared
sim.source =  {'lPC', 'rPC', 'lFC', 'rFC'};  % Sources to plot the simulations
sim.legend_loc = 'East';
sim.psave = fullfile(presults,'rest','simulations');    % Results folder
sim.dcm = fullfile(presults,'rest','dcm','dcm_rest_cmc_ei_v1.mat'); % DCM file
sim.dcm = fullfile(presults,'rest','dcm','dcm_rest_cmc_ei_v1_T_63_128_128_64_S_0.mat'); % DCM file
sim_csd(sim);

% ASSR
clear spm_erp_L  % This script generates some persitant variabls called LastLpos LastL that need to be cleared
sim.source = {'lTHA', 'rTHA', 'lA1', 'rA1', 'lHIP', 'rHIP'};  % Sources to plot the simulations
sim.legend_loc = 'eastoutside';
sim.psave = fullfile(presults,'assr','simulations');    % Results folder
sim.dcm = fullfile(presults,'assr','dcm','dcm_assr_cmc_ei_v1.mat'); % DCM file
sim.dcm = fullfile(presults,'assr','dcm','dcm_assr_cmc_ei_v1_T_32_32_128_32_S_2.mat'); % DCM file
sim_csd(sim);






