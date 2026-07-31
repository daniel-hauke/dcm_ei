%--------------------------------------------------------------------------
% This script reproduces the analysis of the following paper (please cite):
% 
%   Hauke, Rodriguez-Sanchez, Oloye, Berndt, Pinotsis, Friston, Mathalon,
%   & Adams (2026). A Canonical Microcircuit for Estimating Excitation/
%   Inhibition (E/I) Balance. Translational Psychiatry. 
%   https://doi.org/10.1038/s41398-026-04312-y
% 
% This code uses the SPM12 and the TAPAS toolboxes. Please, also cite these
% resources: 
%
% SPM12:
%   Friston et al. (1994). Statistical parametric maps in functional
%   imaging: A general linear approach. Human Brain Mapping.
%   https://doi.org/10.1002/hbm.460020402
%
% TAPAS:
%   Frässle et al. (2021). TAPAS: An Open-Source Software Package for
%   Translational Neuromodeling and Computational Psychiatry. Frontiers in 
%   Psychiatry. https://doi.org/10.3389/fpsyt.2021.680811
%
% TAPAS euler integrator code:
%   Schöbi et al (2021). A fast and robust integrator of delay differential
%   equations in DCM for electrophysiological data. NeuroImage.
%   https://doi.org/10.1016/j.neuroimage.2021.118567 
%
%--------------------------------------------------------------------------


%% Paths
setup_paths;

% Add local paths
[~, uid] = unix('whoami');
switch uid(1: end-1)
    
    % Daniel
    case {'desktop-15ldi1r\pc'}
        presults = 'C:\projects\dcm_ei\results';
        pdata = 'C:\projects\dcm_ei\data';
        
    otherwise
        warning('Unknown User!')
        warning('Please specify your local paths at the top of the run_analysis.m script.')
end




%% Fit models to grandmean data
opt = struct;

%------------------------------------
% P300
%------------------------------------
data_file_name = fullfile(pdata,'p300','p300_grandmean_hc_f15.mat');
results_folder = fullfile(presults,'p300');
fit_p300_gm_dcm(data_file_name,results_folder,opt);

%------------------------------------
% MMN
%------------------------------------
data_file_name = fullfile(pdata,'mmn','napls_mmn_grandmean_hc.mat');
results_folder = fullfile(presults,'mmn');
fit_mmn_gm_dcm(data_file_name,results_folder,opt);

%------------------------------------
% P50
%------------------------------------
data_file_name = fullfile(pdata,'p50','P50_grandmean_HC.mat');
results_folder = fullfile(presults,'p50');
fit_p50_gm_dcm(data_file_name,results_folder,opt);


%% Collect posterior in table
%------------------------------------
% P300
%------------------------------------
pgmdcm = fullfile(results_folder,'p300','dcm','dcm_p300_cmc_ei_v1.mat');
presults = fullfile(results_folder,'p300','plots','Table_S3_grandmean_parameter_posterior_active_oddball_paradigm.csv');
write_param_posterior_table(pgmdcm, presults);

%------------------------------------
% MMN
%------------------------------------
pgmdcm = fullfile(results_folder,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat');
presults = fullfile(results_folder,'mmn','plots','Table_S2_grandmean_parameter_posterior_passive_oddball_paradigm.csv');
write_param_posterior_table(pgmdcm, presults);

%------------------------------------
% P50
%------------------------------------
pgmdcm = fullfile(results_folder,'p50','dcm','dcm_p50_cmc_ei_v1.mat');
presults = fullfile(results_folder,'p50','plots','Table_S1_grandmean_parameter_posterior_paired-click_paradigm.csv');
write_param_posterior_table(pgmdcm, presults);


%% Simulate from grandmean model
% Figure 3 (B_g_ee and B_g_ii parameters) in the main paper
% Figure S1 (G parameters) in the supplement

% Simulation options
sim.param           = {'G','B_g_ii','B_g_ee'};    % Parameter fields to simulate from
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

%------------------------------------
% P300 - single parameter simulation
%------------------------------------
sim.param = {'B_g_ee'};                             % Parameter fields to simulate from
sim.chan = {'Pz'};                                  % Channel to plot the simulations
sim.sim_title = {'Standard', 'Target'};             % Name of the conditions for plot
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.legend_loc = 'NorthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'p300','simulations');                    % Results folder
sim.dcm = fullfile(presults,'p300','dcm','dcm_p300_cmc_ei_v1.mat');     % DCM file
sim_erp(sim);

sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Pz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.sim_title = {'Standard', 'Target'};             % Name of the conditions for plot
sim.legend_loc = 'NorthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'p300','simulations');                    % Results folder
sim.dcm = fullfile(presults,'p300','dcm','dcm_p300_cmc_ei_v1.mat');     % DCM file
sim_erp(sim);

sim.param = {'G'};                                  % Parameter fields to simulate from
sim.chan = {'Pz'};                                  % Channel to plot the simulations
sim.sim_title = {'Standard', 'Target'};             % Name of the conditions for plot
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.legend_loc = 'NorthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'p300','simulations','G');                % Results folder
sim.dcm = fullfile(presults,'p300','dcm','dcm_p300_cmc_ei_v1.mat');     % DCM file
sim_erp(sim);

%------------------------------------
% MMN - single parameter simulation
%------------------------------------
sim.param = {'B_g_ee'};                             % Parameter fields to simulate from
sim.chan = {'Fz'};                                  % Channel to plot the simulations
sim.sim_title = {'Standard', 'Deviant'};            % Name of the conditions for plot
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.legend_loc = 'SouthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'mmn','simulations');                     % Results folder
sim.dcm = fullfile(presults,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat');       % DCM file
sim_erp(sim);

sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Fz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
%sim.vals = linspace(-2,2,9);                       % value to be added or percentage change
sim.sim_title = {'Standard', 'Deviant'};            % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'mmn','simulations');                     % Results folder
sim.dcm = fullfile(presults,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat');       % DCM file
sim_erp(sim);

sim.param = {'G'};                                  % Parameter fields to simulate from
sim.chan = {'Fz'};                                  % Channel to plot the simulations
sim.sim_title = {'Standard', 'Deviant'};            % Name of the conditions for plot
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.legend_loc = 'SouthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'mmn','simulations','G');                 % Results folder
sim.dcm = fullfile(presults,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat');       % DCM file
sim_erp(sim);

%------------------------------------
% P50 - single parameter simulation
%------------------------------------
sim.param = {'B_g_ee'};                             % Parameter fields to simulate from
sim.chan = {'Cz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.sim_title = {'S1', 'S2'};                       % Name of the conditions for plot
sim.flip_cols = 0;
sim.flip_diff = 1;                                  % for p50, we want to compute S1-S2 not S2-S1
sim.legend_loc = 'SouthEast';
sim.psave = fullfile(presults,'p50','simulations');                     % Results folder
sim.dcm = fullfile(presults,'p50','dcm','dcm_p50_cmc_ei_v1.mat');       % DCM file
sim_erp(sim);

sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Cz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.sim_title = {'S1', 'S2'};                       % Name of the conditions for plot
sim.flip_cols = 0;
sim.flip_diff = 1;                                  % for p50, we want to compute S1-S2 not S2-S1
sim.legend_loc = 'SouthEast';
sim.psave = fullfile(presults,'p50','simulations');                     % Results folder
sim.dcm = fullfile(presults,'p50','dcm','dcm_p50_cmc_ei_v1.mat');       % DCM file
sim_erp(sim);

sim.param = {'G'};                                  % Parameter fields to simulate from
sim.chan = {'Cz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.sim_title = {'S1', 'S2'};                       % Name of the conditions for plot
sim.flip_diff = 1;                                  % for p50, we want to compute S1-S2 not S2-S1
sim.legend_loc = 'SouthEast';
sim.psave = fullfile(presults,'p50','simulations','G');                 % Results folder
sim.dcm = fullfile(presults,'p50','dcm','dcm_p50_cmc_ei_v1.mat');       % DCM file
sim_erp(sim);



%% Singe sublect simulations
% Figure S3 (B_g_ii parameter in individual subjects) in the supplement

%------------------------------------
% MMN - single parameter simulation
%------------------------------------
sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Fz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
%sim.vals = linspace(-2,2,9);                       % value to be added or percentage change
sim.sim_title = {'Standard', 'Deviant'};            % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'mmn','simulations_single_subject_lowest_gii');                   % Results folder
sim.dcm = fullfile(presults,'mmn','parameter_recovery','dcms','03-0001_dcm_mmn_cmc_ei_v1.mat'); % DCM file
cd(fullfile(presults,'mmn','parameter_recovery','data'));
sim_erp(sim);

sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Fz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
%sim.vals = linspace(-2,2,9);                       % value to be added or percentage change
sim.sim_title = {'Standard', 'Deviant'};            % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'mmn','simulations_single_subject_highest_gii');                   % Results folder
sim.dcm = fullfile(presults,'mmn','parameter_recovery','dcms','02-0080_dcm_mmn_cmc_ei_v1.mat');     % DCM file
cd(fullfile(presults,'mmn','parameter_recovery','data'));
sim_erp(sim);

sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Fz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
%sim.vals = linspace(-2,2,9);                       % value to be added or percentage change
sim.sim_title = {'Standard', 'Deviant'};            % Name of the conditions for plot
sim.legend_loc = 'SouthEast';
sim.flip_cols = 0;
sim.flip_diff = 0; 
sim.psave = fullfile(presults,'mmn','simulations_single_subject_mean_gii');                         % Results folder
sim.dcm = fullfile(presults,'mmn','parameter_recovery','dcms','01-0008_dcm_mmn_cmc_ei_v1.mat');     % DCM file
cd(fullfile(presults,'mmn','parameter_recovery','data'));
sim_erp(sim);

%------------------------------------
% P50 - single parameter simulation
%------------------------------------
sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Cz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.sim_title = {'S1', 'S2'};                       % Name of the conditions for plot
sim.flip_cols = 0;
sim.flip_diff = 1;                                  % for p50, we want to compute S1-S2 not S2-S1
sim.legend_loc = 'SouthEast';
sim.psave =  fullfile(presults,'p50','simulations_single_subject_lowest_gii');                      % Results folder
sim.dcm = fullfile(presults,'p50','parameter_recovery','dcms','0772_dcm_p50_cmc_ei_v1.mat');        % DCM file
cd(fullfile(presults,'p50','parameter_recovery','data'));
sim_erp(sim);

sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Cz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.sim_title = {'S1', 'S2'};                       % Name of the conditions for plot
sim.flip_cols = 0;
sim.flip_diff = 1;                                  % for p50, we want to compute S1-S2 not S2-S1
sim.legend_loc = 'SouthEast';
sim.psave =  fullfile(presults,'p50','simulations_single_subject_highest_gii');                      % Results folder
sim.dcm = fullfile(presults,'p50','parameter_recovery','dcms','1536_dcm_p50_cmc_ei_v1.mat');        % DCM file
cd(fullfile(presults,'p50','parameter_recovery','data'));
sim_erp(sim);

sim.param = {'B_g_ii'};                             % Parameter fields to simulate from
sim.chan = {'Cz'};                                  % Channel to plot the simulations
sim.vals = linspace(-0.5,0.5,9);                    % value to be added or percentage change
sim.sim_title = {'S1', 'S2'};                       % Name of the conditions for plot
sim.flip_cols = 0;
sim.flip_diff = 1;                                  % for p50, we want to compute S1-S2 not S2-S1
sim.legend_loc = 'SouthEast';
sim.psave =  fullfile(presults,'p50','simulations_single_subject_mean_gii');                      % Results folder
sim.dcm = fullfile(presults,'p50','parameter_recovery','dcms','0114_dcm_p50_cmc_ei_v1.mat');        % DCM file
cd(fullfile(presults,'p50','parameter_recovery','data'));
sim_erp(sim);



%% 2D Simulations
% Figure 4 in the main paper
% Figure S2 in the supplement

% Simulation options
sim.noise           = 'nn';                       % 'estimated' or 'nn' (no added noise)                  
sim.vals            = linspace(-0.5,0.5,9);       % value to be added or percentage change
sim.visibility      = 'on';
sim.plot_diff       = 1;
sim.tic_fontsize    = 14;    
sim.flip_cols = 0; 

%------------------------------------
% P300 - 2D grid parameter simulation
%------------------------------------
sim.psave = fullfile(presults,'p300','simulations');                    % Results folder 
sim.dcm = fullfile(presults,'p300','dcm','dcm_p300_cmc_ei_v1.mat');     % dcm file to simulate from
sim.sim_title = {'Standard', 'Target'};                                 % condition names
sim.chan = {'Pz'};                                                      % channel to simulate
sim.time_window = {[250 600]};                                          % time window for ERP
sim.aggr = {'max'};                                                     % Aggregation function
sim.cb_title = {'P3', 'P3', 'P3'};                                      % colorbar titles

sim.param = {'B_g_ii','B_g_ee'};                                        % Parameter fields to simulate from
sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};                 % value to be added or percentage change
sim.ylabel = 'B^{g_{ii}}';
sim.xlabel = 'B^{g_{ee}}';
sim.idx = {[1] [1]};
sim_erp_grid(sim);

sim.param = {'G','G'}; 
sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};
sim.ylabel = 'g_{ii}';
sim.xlabel = 'g_{ee}';
sim.idx = {[2],[1]}; 
sim_erp_grid(sim);

sim.param = {'T','B_g_ii'};
sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};     
sim.ylabel = '\tau_{ii}';
sim.xlabel = 'B^{g_{ii}}';
sim.idx = {[3],[1]}; 
sim_erp_grid(sim);

sim.param = {'G','B_g_ii'}; 
sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};  
sim.ylabel = 'g_{ii}';
sim.xlabel = 'B^{g_{ii}}';
sim.idx = {[2],[1]}; 
sim_erp_grid(sim);

sim.param = {'G','B_g_ee'};
sim.vals = {linspace(-.5,0.5,9),linspace(-0.5,0.5,9)};  
sim.ylabel = 'g_{ee}';
sim.xlabel = 'B^{g_{ee}}';
sim.idx = {[1] [1]};
sim_erp_grid(sim);

sim.param = {'T','B_g_ee'};
sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};     
sim.ylabel = '\tau_{sp}';
sim.xlabel = 'B^{g_{ee}}';
sim.idx = {[2],[1]}; 
sim_erp_grid(sim);

%------------------------------------
% MMN - 2D grid parameter simulation
%------------------------------------
sim.psave = fullfile(presults,'mmn','simulations');    
sim.dcm = fullfile(presults,'mmn','dcm','dcm_mmn_cmc_ei_v1.mat');
sim.chan = {'Fz'}; 
sim.sim_title = {'Standard', 'Deviant'};   
sim.time_window = {[150 250]};
sim.aggr = {'min'};
sim.cb_title = {'MMN','MMN','MMN'};

sim.param = {'B_g_ii','B_g_ee'};        
sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};
sim.ylabel = 'B^{g_{ii}}';
sim.xlabel = 'B^{g_{ee}}';
sim.idx = {[1] [1]};
sim_erp_grid(sim);

%------------------------------------
% P50 - 2D grid parameter simulation
%------------------------------------
sim.psave = fullfile(presults,'p50','simulations');    
sim.dcm = fullfile(presults,'p50','dcm','dcm_p50_cmc_ei_v1.mat'); 
sim.chan = {'Cz'}; 
sim.sim_title = {'S1', 'S2'};   
sim.time_window = {[120 250]};
sim.aggr = {'max'};
sim.cb_title = {'P2','P2','P2'};
sim.flip_diff = 1;                      % for p50, we want to compute S1-S2 not S2-S1

sim.param = {'B_g_ii','B_g_ee'};       
sim.vals = {linspace(-0.5,0.5,9),linspace(-0.5,0.5,9)};
sim.ylabel = 'B^{g_{ii}}';
sim.xlabel = 'B^{g_{ee}}';
sim.idx = {[1] [1]};
sim_erp_grid(sim);


%% Parameter recovery analysis
% Figure 2 in the main paper

% See precov_pipeline.m (this analysis was partially run on the cluster)


%% Parameter idendifiability analysis
% Figure 2 in the main paper

% See pident_pipeline.m (this analysis was partially run on the cluster and
% it requires the individual model inversions that are run in the parameter
% recovery pipeline to be run first)


%% Model comparison
% Figure S4 in the supplement

% See mcomp_pipeline.m (this analysis was partially run on the cluster)


%% Model recovery
% Figure S4 in the supplement

% See mrecov_pipeline.m (this analysis was partially run on the cluster)





