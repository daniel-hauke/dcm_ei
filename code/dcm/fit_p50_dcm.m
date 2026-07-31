function DCM = fit_p50_dcm(data_file,result_dir,prior_file)
%--------------------------------------------------------------------------
% This function runs the E/I model using the grandmean priors.
%--------------------------------------------------------------------------


%% Run Headmodel
D = spm_eeg_load(data_file);
try D = rmfield(D,'inv'); end
save(D); clear D;

% Specify new head model
job{1}.spm.meeg.source.headmodel.D = {data_file};
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


%% DCM setup
% Initialize
DCM = struct();

% Set DCM type
DCM.options.model = 'cmc';          % 'cmc' or 'cmm' for convolution vs condutance based DCM

% Set data file name
DCM.xY.Dfile = data_file;

% DCM options
DCM.options.analysis = 'ERP';       % analyze evoked responses
DCM.options.spatial  = 'ECD';       % spatial model 'ECD' or 'IMG'
DCM.options.trials   = [1 2];       % index of ERPs within ERP/ERF file
DCM.options.Tdcm(1)  = -100;        % start of peri-stimulus time to be modelled
DCM.options.Tdcm(2)  = 350;         % end of peri-stimulus time to be modelled
DCM.options.Nmodes   = 8;           % nr of modes for data selection
DCM.options.h        = 1;           % nr of DCT components
DCM.options.D        = 1;           % downsampling (downsample by factor of 2.5 to get to 100Hz sampling rate)
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

% Lateral connections
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
% Forward
DCM.B{1}(3,1) = 1;
DCM.B{1}(4,2) = 1;
DCM.B{1}(5,3) = 1;
DCM.B{1}(6,4) = 1;
% Backward
DCM.B{1}(1,3) = 1;
DCM.B{1}(2,4) = 1;
DCM.B{1}(3,5) = 1;
DCM.B{1}(4,6) = 1;
% Local Gains
%DCM.B{1} = DCM.B{1} + eye(size(DCM.A{1})); % No local gee parameter estimated

% Input
DCM.C = [1; 1; 0; 0; 0; 0];

% Between trial effects
DCM.xU.name{1} = {'Main effect of condition: S1 > S2'};
DCM.xU.X(:,1)  = [1; -1];

DCM = get_priors_ei_cmc(DCM);

% Fix input
DCM.M.pC.R = [1/1024 1/1024];

% Estimating global parameter
DCM.M.pC.B_g_ee = 1/8;  % Estimate global B-g_ee parameter
DCM.M.pC.B_g_ee = 1/8;  % Estimate global B-g_ii parameter

% Fix other global parameters
DCM.M.pC.B_g_ei = 0;
DCM.M.pC.B_g_ie = 0;
DCM.M.pC.B_g_se = 0; 

% To relax the equality constraint on the global E/I parameter expand the
% parameters to vectors of size #number of ROIs:
% 
% Prior expectations:
% DCM.M.pE.B_g_ee = [0 0 0 0 0 0]';  
% DCM.M.pE.B_g_ii = [0 0 0 0 0 0]';
% 
% Prior covariances:
% DCM.M.pC.B_g_ee = [1/8 1/8 1/8 1/8 1/8 1/8]';
% DCM.M.pC.B_g_ii = [1/8 1/8 1/8 1/8 1/8 1/8]';

% Interpretation of G's: [g_ee g_ii g_ei g_ie g_se]
DCM.M.pC.G(1) = 1/32;  % Estimate global condition-independent g_ee parameter
DCM.M.pC.G(1) = 1/32;  % Estimate global condition-independent g_ii parameter

% Fix other global parameters
DCM.M.pC.G(3) = 0;
DCM.M.pC.G(4) = 0; 
DCM.M.pC.G(5) = 0;

% % Fixing the B's
% DCM.M.pC.B{1} = zeros(size(DCM.M.pE.B{1}));


%% Set Tau and S to values selected by multistart
DCM.M.pE.T = [log(16/2) log(16/2) log(2/16) log(16/28)];
DCM.M.pE.S = -2;


%% Loading grandmean priors
fprintf('\nUsing custom starting values:\n\n')
P = load(prior_file);
disp(P.DCM.Ep);
DCM.M.P = P.DCM.Ep;


%% Fit model
mkdir(result_dir);
cd(result_dir);

[~, fname, ~] = fileparts(data_file);
DCM.name = ['dcm_' fname];
DCM = spm_dcm_erp(DCM);
save(DCM.name, 'DCM', spm_get_defaults('mat.format'));
fprintf('\nInversion completed.\n\n');



