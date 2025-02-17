function fit_p50_multistart(vbsv,rerun)

%% Paths
[~, uid] = unix('whoami');
switch uid(1: end-1)
    
    % Daniel's PC
    case 'laptop-0jhjt7kf\danie'
        pvbsv = 'C:\projects\dcm_ei_sim\results\P300_grandmean_v5\multistart\vbsv_grisearch_tau_and_s';
        presults = 'C:\projects\dcm_ei_sim\results\P300_grandmean_v5\multistart\dcms';
        pdata = 'F:\BSNIP\P300\P300_preprocessed_final_posthoc_filtered_1-15Hz_grandmean\P300_grandmean_all_groups.mat';
        pcode = 'C:\projects\dcm_ei_sim\code';
        
    case 'rickadams'
        pvbsv = '/Volumes/RAdams16TB/Data/BSNIP/P300_preprocessed_final_posthoc_filtered_1-15Hz_grandmean_multistart_10xpC/vbsv';
        presults = '/Volumes/RAdams16TB/Data/BSNIP/P300_preprocessed_final_posthoc_filtered_1-15Hz_grandmean_multistart_10xpC/dcms';
        pdata = '/Volumes/RAdams16TB/Data/BSNIP/P300_preprocessed_final_posthoc_filtered_1-15Hz_grandmean/P300_grandmean_all_groups.mat';
        pcode = '/Users/rickadams/Code/dcm_ei_sim/code';

    % Cluster
    otherwise
        pvbsv = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/multistart/vbsvs_tau_s_6_sources_erp';
        frerun =  '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/p50/multistart/vbsvs_to_rerun.mat';
        presults = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/results/p50/multistart/dcms';
        pdata = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/data/p50/P50_grandmean_HC.mat';
        pcode = '/SAN/intelsys/Psycho_Pheno2/dcm_ei/code';  
end



%% Options
use_as_sv = 0;
use_as_prior = 1;
%rerun = 1;


%% Load correct vbsv for rerunning
if rerun
    load(frerun);
    vbsv = vbsvs_to_rerun(vbsv);
end


%% Check for previous results
disp(presults);
fprintf('\n--------- Starting Value: %.3d ---------\n',vbsv)

% Create directory to store starting values
[~,~] = mkdir(presults);

dcm_fname = fullfile(presults, ['dcm_p50_cmc_ei_v1_vbsv' num2str(vbsv) '.mat']);

if isfile(dcm_fname)
    fprintf('DCM file already exists. Skipping...\n')
    return 
end


%% Setup SPM
cd(pcode);
setup_paths;
cd(presults);


%% Copy data files
[~, fname, ext] = fileparts(pdata);

pdatacopy = fullfile(fileparts(presults),'data_copy');
[~,~] = mkdir(pdatacopy);

fname_new = [fname '_vbsv' num2str(vbsv) ext];
pdata_new = fullfile(pdatacopy,fname_new);


D = spm_eeg_load(pdata);
copy(D, pdata_new);
clear D
    


%% Run Headmodel
D = spm_eeg_load(pdata_new);
try D = rmfield(D,'inv'); end
save(D); clear D;

% Specify new head model
job{1}.spm.meeg.source.headmodel.D = {pdata_new};
job{1}.spm.meeg.source.headmodel.val = 1;
job{1}.spm.meeg.source.headmodel.comment = '';
job{1}.spm.meeg.source.headmodel.meshing.meshes.template = 1;
job{1}.spm.meeg.source.headmodel.meshing.meshres = 2;
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'spmnas';
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.type = [1 85 -41];
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'spmlpa';
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.type = [-83 -20 -65];
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'spmrpa';
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.type = [83 -20 -65];
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
job{1}.spm.meeg.source.headmodel.forward.eeg = '3-Shell Sphere';
job{1}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';

tic;
spm_jobman('run',{job});
t = toc;
fprintf('===\n\t Headmodel done in %s (HH:MM:SS).\n\n\n', datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));


%% BSNIP P300 DCM Setup
% Initialize
DCM = struct();

% Set DCM type
DCM.options.model = 'cmc';          % 'cmc' or 'cmm' for convolution vs condutance based DCM

% Set data file name
DCM.xY.Dfile = pdata_new;

% DCM options
DCM.options.analysis = 'ERP';       % analyze evoked responses
DCM.options.spatial  = 'ECD';       % spatial model 'ECD' or 'IMG'
DCM.options.trials   = [1 2];       % index of ERPs within ERP/ERF file
DCM.options.Tdcm(1)  = -100;        % start of peri-stimulus time to be modelled
DCM.options.Tdcm(2)  = 350;         % end of peri-stimulus time to be modelled
DCM.options.Nmodes   = 8;           % nr of modes for data selection
DCM.options.h        = 1;           % nr of DCT components
DCM.options.D        = 2;           % downsampling (downsample by factor of 2.5 to get to 100Hz sampling rate)
DCM.options.han      = 1;           % Hanning window
DCM.options.onset    = 50;          % onset mean of input
DCM.options.dur      = 30;          % sd of onset
DCM.M.nograph        = 1;           % Turn of graphics to run on cluster
DCM.M.Nmax           = 64;          % default: 64

% Sources
DCM.Sname = {'lSTG', 'rSTG', 'lIns', 'rIns', 'lMFG', 'rMFG'};
DCM.Lpos  = [-53 -20 13;
              49 -10 10;
             -36  23  3;
              36  23  3;
              -1 -20 67;
              1 -20 67]';

% Forward connections
DCM.A{1} = zeros(numel(DCM.Sname));
DCM.A{1}(3,1) = 1;
DCM.A{1}(4,2) = 1;
DCM.A{1}(5,3) = 1;
DCM.A{1}(6,4) = 1;

%Lateral
DCM.A{1}(1,2) = 1;
DCM.A{1}(2,1) = 1;
DCM.A{1}(3,4) = 1;
DCM.A{1}(4,3) = 1;
DCM.A{1}(5,6) = 1;
DCM.A{1}(6,5) = 1;

% Backward connections
DCM.A{2} = zeros(numel(DCM.Sname));
DCM.A{2}(1,3) = 1;
DCM.A{2}(2,4) = 1;
DCM.A{2}(3,5) = 1;
DCM.A{2}(4,6) = 1;

% Connections modulated by condition
DCM.B{1} = zeros(numel(DCM.Sname));
DCM.B{1}(3,1) = 1;
DCM.B{1}(4,2) = 1;
DCM.B{1}(5,3) = 1;
DCM.B{1}(6,4) = 1;

DCM.B{1}(1,3) = 1;
DCM.B{1}(2,4) = 1;
DCM.B{1}(3,5) = 1;
DCM.B{1}(4,6) = 1;

% Local Gains
%DCM.B{1} = DCM.B{1} + eye(size(DCM.A{1})); % No local gee parameter estimated

% Input
DCM.C = [1; 1; 0; 0; 0; 0];

% Between trial effects
DCM.xU.name{1} = {'Main effect of condition: Dev > Std'};
DCM.xU.X(:,1)  = [1; -1];

DCM = get_priors_ei_cmc(DCM);

% Fix input
DCM.M.pC.R = [1/1024 1/1024];


%DCM.M.pC.B_g_ee = 0;  % Fix global g_ee parameters
DCM.M.pC.B_g_ei = 0;  % Fix gei
DCM.M.pC.B_g_ie = 0;
DCM.M.pC.B_g_se = 0; 

% Interpretation of G's: [g_ee g_ii g_ei g_ie g_se]
DCM.M.pC.G(3) = 0; % Fix gei
DCM.M.pC.G(4) = 0; 
DCM.M.pC.G(5) = 0;


%% Load starting values
load(fullfile(pvbsv,['vbsv_' num2str(vbsv) '.mat']));

if use_as_sv
    fprintf('\nUsing custom starting values:\n\n')
    disp(P);
    DCM.M.P = P;
end

if use_as_prior
    fprintf('\nUsing custom starting values as prior expectations:\n\n')
    disp(P);
    DCM.M.pE = P;
end

%% Fit model
% 4-population convolution-based model (CMC)
DCM.name = dcm_fname;
%DCM.M.intstep = 1E-4;
DCM = spm_dcm_erp(DCM);
save(DCM.name, 'DCM', spm_get_defaults('mat.format'));
fprintf('\nInversion completed.\n\n');

% Delete data copy
[path, fname, ~] = fileparts(pdata_new);
delete(fullfile(path,[fname '.*'])); 


