function fit_rest_dcm(data_file_name, results_folder,opt)





%% Description
opt.desc = {''};
opt.matlab_version = version;


%% Options
opt.version          = 1;  % Set version (will be appended to results directory and dcm file)
opt.run_headmodel    = 1;   % Run a headmodel (required once before running a dcm inversion)
opt.run_dcm          = 1;   % Flag to run dcm inversion
opt.plot_raw         = 0;   % Flag to plot raw data
opt.plot_inversion   = 1;   % Flag to save the model inversion plot
opt.plot_fit         = 1;   % Flag to plot the model fit
opt.run_bpa          = 0;   % Flag to load bayesian parameter averages and use them as starting values
opt.use_ep           = 0;   % Flag to use posterior from grandmean inversion as priors
opt.use_gm           = 0;   % Flag to load and use grandmean data
opt.plot_params      = 1;   % Flag to plot posterior parameter estimates



% Set file names and prefixes
[opt.pdata, opt.data_fname, ext] = fileparts(data_file_name);
opt.dcm_prefix = 'dcm_rest_cmc_ei';  % prefix of dcm file (model and version will be appended)
opt.presults = results_folder;

% Condition names
opt.conditions = {'eyes closed','eyes open'};

% Plot posterior parameter estimates
plt.param = {'B_g_ii','B_g_ee','G'}; 
plt.visibility = 'off';       


%% Setup paths and results folder
fprintf('Results Folder: %s\n', opt.presults)

opt.pdcms = fullfile(opt.presults,'dcm');
opt.pcpdata = fullfile(opt.presults,'data_copy');
opt.pplots = fullfile(opt.presults,'plots');

[~,~] = mkdir(opt.presults);
[~,~] = mkdir(opt.pdcms);
[~,~] = mkdir(opt.pcpdata);
[~,~] = mkdir(opt.pplots);


%% Get subject ID
% Start log
fname_log = fullfile(opt.pdcms,'dcm_rest_cmc_ei');
diary(fname_log);   

% Start lot
fprintf('\n================================ Fit DCM to resting-state ================================\n');

% Write data file
dfile = fullfile(opt.pdata, [opt.data_fname ext]);
dfile_new = fullfile(opt.pcpdata, [opt.data_fname ext]);

% Crete a data copy to work with to prevent file corruption
D = spm_eeg_load(dfile);
copy(D, dfile_new);
clear D;
fprintf('Copying data file to: %s\n', dfile_new)


%% Fit head model
if opt.run_headmodel
    % Clean up previous source localisation
    D = spm_eeg_load(dfile_new);
    try D = rmfield(D,'inv'); end
    save(D); clear D;
    
   % Specify new head model
    job{1}.spm.meeg.source.headmodel.D = {dfile_new};
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
end


%% Plot raw data
if opt.plot_raw
    fh = plot_raw_data(dfile_new, 'off');
    saveas(fh,fullfile(opt.pplots, 'raw_data_plot.png'));
    saveas(fh,fullfile(opt.pplots, 'raw_data_plot.fig'));
end


%% DCM
if opt.run_dcm
    
    % Initialize
    DCM = struct();
    
    DCM.matlab_version = version;
    
    % Set DCM type
    DCM.options.model = 'cmc';          % 'cmc' or 'cmm' for convolution vs condutance based DCM
    
    % Set data file name
    DCM.xY.Dfile = dfile_new;
    DCM.options.Tdcm(1)  = 0;          % start of peri-stimulus time to be modelled
    DCM.options.Tdcm(2)  = 50000;       % end of peri-stimulus time to be modelled
    DCM.options.Fdcm     = [3 48];      % frequency band to be modelled (default = 4-48 Hz)
   % DCM options
    DCM.options.analysis = 'CSD';       % analyze cross-spectral densities
    DCM.options.spatial  = 'ECD';       % spatial model 'ECD' or 'IMG'
    DCM.options.trials   = [1 2];       % index of ERPs within ERP/ERF file
    DCM.options.Rft      = 7;           % wavelet number  
    DCM.options.Nmodes   = 8;           % nr of modes for data selection
    DCM.options.h        = 1;           % nr of DCT components
    DCM.options.D        = 1;           % downsampling (downsample by factor of 2 to get to 125Hz sampling rate)
    DCM.options.han      = 0;           % Hanning window
    DCM.M.Nmax           = 64;           % default: 64, just to have a quick check

    % Sources
    DCM.Sname = {'lPC', 'rPC', 'lFC', 'rFC'};
    DCM.Lpos  = [-29 -68 49;    % left parietal cortex
                  29 -68 49;    % rightparietal cortex
                 -33  45 28;    % left frontal cortex
                  33  45 28]';  % right frontal cortex
    
     % Forward connections
    DCM.A{1} = zeros(numel(DCM.Sname));
    DCM.A{1}(3,1) = 1;
    DCM.A{1}(4,2) = 1;
    
    % Backward connections
    DCM.A{2} = zeros(numel(DCM.Sname));
    DCM.A{2}(1,3) = 1;
    DCM.A{2}(2,4) = 1;
    
    % Lateral connections
    DCM.A{1}(1,2) = 1;
    DCM.A{1}(2,1) = 1;
    DCM.A{1}(3,4) = 1;
    DCM.A{1}(4,3) = 1;
    
    % Connections modulated by condition
    DCM.B{1} = zeros(numel(DCM.Sname));
    DCM.B{1}(3,1) = 1;
    DCM.B{1}(4,2) = 1;
    DCM.B{1}(1,3) = 1;
    DCM.B{1}(2,4) = 1;
    
    % Input
    DCM.C = sparse(numel(DCM.Sname),0);
    
    % Between trial effects
    DCM.xU.name{1} = {'Main effect of condition: eyes closed > eyes open'};
    DCM.xU.X(:,1)  = [1; -1];
     
    % Set DCM name
    dcm_name = sprintf('%s_v%d', opt.dcm_prefix, opt.version);
    DCM.name = fullfile(opt.pdcms, [dcm_name '.mat']);
    
    % Connections modulated by condition
%     DCM.B{1} = DCM.A{1} + DCM.A{2} + eye(size(DCM.A{1}));
    DCM = get_priors_ei_cmc(DCM);
    
    % Fix g_ei, g_ie, g_se parameters
    DCM.M.pC.B_g_ei = 0;
    DCM.M.pC.B_g_ie = 0;
    DCM.M.pC.B_g_se = 0;
    
    % Interpretation of G's: [g_ee g_ii g_ei g_ie g_se]
    DCM.M.pC.G(3) = 0; 
    DCM.M.pC.G(4) = 0; 
    DCM.M.pC.G(5) = 0;
    
    % Fix Tau and S to values selected by multistart
    DCM.M.pE.T = [log(32/2) log(64/2) log(2/16) log(32/28)];
    DCM.M.pE.S = 0;
    
    
    % Use bayesian parameter averages as starting values
    if opt.run_bpa
        load(opt.fbpa);
        DCM.M.P = BPA.Ep;
    end
    
     % Use DCM posterior as priors
    if opt.use_ep
        ep = load(opt.fep);
        DCM.M.pE = ep.DCM.Ep;
    end
    
    % Load grandmean data instead
    if opt.use_gm
        DCM.options.DATA = 0;
        load(opt.fgm);
        DCM.xY = xY;
        DCM.M.U = DCM.xY.U;
    end
    
    % Save options, priors and an analysis description
    opt.priors = DCM;
    if ~isfile(fullfile(opt.presults,'options.mat'))
        save(fullfile(opt.presults,'options.mat'),'opt');
        fID = fopen(fullfile(opt.presults,'analysis_description.txt'),'w');
        fprintf(fID,'\nAnalysis description:\n\n');
        for l = 1:numel(opt.desc); fprintf(fID,'%s\n',opt.desc{l}); end
        fprintf(fID,'\n\nOptions chosen:\n\n');
        fprintf(fID,'%s\n', evalc('disp(opt)'))
        fclose(fID);
    end
    
    % Invert
    if ~opt.use_gm
        DCM = spm_dcm_csd_no_prior_check(DCM);
    else
        DCM = spm_dcm_csd_no_prior_check_gm(DCM);
    end
    
    save(DCM.name, 'DCM', spm_get_defaults('mat.format'));
    
    % Save inversion plot
    if opt.plot_inversion
        saveas(gcf,fullfile(opt.pplots, 'inversion.png'));
        saveas(gcf,fullfile(opt.pplots, 'inversion.fig'));
    end
    
    % Plot model fit
    if opt.plot_fit
        fh = plot_actual_vs_predicted_csd(DCM, [], opt.conditions, 'off');
        saveas(fh,fullfile(opt.pplots, 'model_fit.png'));
        saveas(fh,fullfile(opt.pplots, 'model_fit.fig'));
    end
    
end


%% Plot parameter estimates
if opt.plot_params
    psave = fullfile(opt.presults,'posterior_parameters');
    [~,~] = mkdir(psave);
    
    for p = 1:numel(plt.param)
        fh = plot_dcm_parameters(DCM, plt.param{p}, plt.visibility);
        saveas(fh,fullfile(psave, [plt.param{p} '_posterior_plot.png']));
        saveas(fh,fullfile(psave, [plt.param{p} '_posterior_plot.fig']));
        clear fh
    end
end


t_done = toc;
fprintf('\n===\n\t Subject finished after %s (HH:MM:SS)!\n\n', datestr(datenum(0,0,0,0,0,t_done),'HH:MM:SS'));

diary off



