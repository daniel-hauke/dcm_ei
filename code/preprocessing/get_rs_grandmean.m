




%% Options
% Get info where to find the groups in the excel file
opt.group_fname{1} = 'Subjects_BSNIP_Master.xlsx';          % Excel file with group codes
opt.group_col{1} = [5 6];                                   % Columns in excel file that have group code
opt.group_names{1} = {'HC', 'SCZ'};                         % Group names (should match columns)
opt.group_fname{2} = 'BSNIP1and2 Biotypes - Hope Oloye.xlsx';     % Excel file with group codes
opt.group_col{2} = [3 4 5]; %[6 3 4 5];                                 % Columns in excel file that have group code
opt.group_names{2} = {'B1', 'B2', 'B3'}; %{'HC', 'B1', 'B2', 'B3'};                    % Group names (should match columns)



%% Specifcy opt.user-specific paths
[~, uid] = unix('whoami'); % get user id
% Specify local paths
switch uid(1:end-1)
    
    % Daniel's paths
    case 'laptop-0jhjt7kf\danie'
        opt.pcode   = 'C:\Users\danie\Dropbox\BSNIP\EEG_Code\';
        opt.pspm    = 'C:\projects\toolboxes\spm12_v7771';
        opt.pgroups = 'C:\Users\danie\Dropbox\BSNIP\';
        opt.poutliers = 'C:\Users\danie\Dropbox\BSNIP\EEG_Code';
        opt.pdata = 'F:\BSNIP\rest\rsEEG_BSNIP_preproc_v2';
        opt.presults = 'F:\BSNIP\rest\results\rest_grandmean';
    otherwise
        error('Undefined user! Please specify a user in the "Specifcy user-specific paths" Section and provide the relevant paths.');
end

% Set up SPM
%addpath(opt.pspm, opt.pcode);
spm('defaults', 'eeg');

% Create folders
[~, ~] = mkdir(opt.presults);
[~, ~] = mkdir(fullfile(opt.pdata,'merged_eo_ec'));
[~, ~] = mkdir(fullfile(opt.pdata,'dcm_files_eo_ec'));


%% Merge eyes-open and eyes-closed conditions and compute individual spectra
% Load group & outlier data
clear files;
count = 0;

for i = 1:numel(opt.group_fname)
    group_data = xlsread(fullfile(opt.pgroups, opt.group_fname{i}));
    
    
    for g = 1:numel(opt.group_names{i})
        
        clear ids;
        
        % Get ids
        ids = group_data(group_data(:,opt.group_col{i}(g))==1,1);
        
        % Get files
        for s = 1:numel(ids)
            
            fname_ec = fullfile(opt.pdata,'EC',sprintf('MrejdMspmeeg_%04d_EC_fe_rej_ica_MARA_int.mat',ids(s)));
            fname_eo = fullfile(opt.pdata,'EO',sprintf('MrejdMspmeeg_%04d_EO_fe_rej_ica_MARA_int.mat',ids(s)));
            
            
            if isfile(fname_ec) && isfile(fname_eo)
                
                if ~isfile(fullfile(opt.pdata,'dcm_files_eo_ec',sprintf('dcm_%04d_prep_merged_eo_ec.mat',ids(s))))
                    count = count+1;
                    
                    
                    D = spm_eeg_load(fname_ec);
                    D = conditions(D,1:ntrials(D), repmat({'eyes closed'}, ntrials(D),1));
                    save(D); clear D;
                    
                    D = spm_eeg_load(fname_eo);
                    D = conditions(D,1:ntrials(D), repmat({'eyes open'}, ntrials(D),1));
                    save(D); clear D;
                    
                    % Merge the files and copy to new folder
                    S.D = [fname_ec; fname_eo];
                    D = spm_eeg_merge(S);
                    dfile = fullfile(opt.pdata,'merged_eo_ec',sprintf('%04d_prep_merged_eo_ec.mat',ids(s)));
                    move(D,dfile);
                    
                    
                    % run head model
                    DCM = struct;
                    DCM.xY.Dfile = dfile;
                    
                    % Clean up previous source localisation
                    D = spm_eeg_load(DCM.xY.Dfile);
                    try D = rmfield(D,'inv'); end
                    save(D); clear D;
                    
                    % Specify new head model
                    job{1}.spm.meeg.source.headmodel.D = {DCM.xY.Dfile};
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
                    
                    
                    DCM.options.trials = 1:2;
                    DCM.options.D  = 1;
                    DCM.options.han = 0;
                    DCM.options.h = 1;
                    DCM.options.Tdcm(1)  = 0;           % start of peri-stimulus time to be modelled
                    DCM.options.Tdcm(2)  = 5000;         % end of peri-stimulus time to be modelled
                    DCM.options.Fdcm     = [3 48];     % frequency band to be modelled (default = 4-48 Hz)
                    DCM.options.Rft = 7;
                    DCM.options.Nmodes = 8;
                    DCM.options.analysis = 'CSD';
                    DCM.options.spatial = 'ECD';
                    DCM.options.model = 'cmc';
                    DCM = spm_dcm_erp_data(DCM,0);
                    
                    
                    DCM.M.dipfit.model = 'cmc';
                    DCM.M.dipfit.type = 'ECD';
                    DCM.Sname = {'lPC', 'rPC', 'lFC', 'rFC'};
                    DCM.Lpos  = [-29 -68 49;    % left parietal cortex
                        29 -68 49;    % rightparietal cortex
                        -33  45 28;    % left frontal cortex
                        33  45 28]';  % right frontal cortex
                    DCM  = spm_dcm_erp_dipfit(DCM, 1);
                    
                    
                    Nm = 8;
                    DCM.M.U = spm_dcm_eeg_channelmodes(DCM.M.dipfit,Nm);
                    
                    DCM  = spm_dcm_csd_data(DCM);
                    
                    ccf      = spm_csd2ccf(DCM.xY.y,DCM.xY.Hz);
                    scale    = max(spm_vec(ccf));
                    DCM.xY.y = spm_unvec(8*spm_vec(DCM.xY.y)/scale,DCM.xY.y);
                    
                    
                    Nm       = size(DCM.M.U,2);                    % number of spatial modes
                    DCM.M.l  = Nm;
                    DCM.M.Hz = DCM.xY.Hz;
                    DCM.M.dt = DCM.xY.dt;
                    
                    
                    % normalised precision
                    %--------------------------------------------------------------------------
                    DCM.xY.Q  = spm_dcm_csd_Q(DCM.xY.y);
                    DCM.xY.X0 = sparse(size(DCM.xY.Q,1),0);
                    
                    save(fullfile(opt.pdata,'dcm_files_eo_ec',sprintf('dcm_%04d_prep_merged_eo_ec.mat',ids(s))), 'DCM');
                    
                    clear spm_erp_L
                    
                else
                    fprintf('%s: ID %04d has been preprocessed before. Skippining...\n', opt.group_names{i}{g}, ids(s));
                end
            end
        end
    end
end




%% Compute grandmean spectra
dcm_files = dir(fullfile(opt.pdata,'dcm_files_eo_ec','dcm*.mat'));
load(fullfile(dcm_files(1).folder, dcm_files(1).name));
xY = DCM.xY; % store the first xY structure as an example
Nm = DCM.options.Nmodes;
n_groups = 5;
group_name = cell(n_groups,1);
sample_size = NaN(n_groups,1);

idx = 1;
for i = 1:numel(opt.group_fname)
    group_data = xlsread(fullfile(opt.pgroups, opt.group_fname{i}));
    
    
    for g = 1:numel(opt.group_names{i})
        
        clear ids;
        count = 0;
        
        % Get ids
        ids = group_data(group_data(:,opt.group_col{i}(g))==1,1);
        
        y_real = cell(1,2);
        y_real{1} = zeros(numel(DCM.options.Fdcm(1):DCM.options.Fdcm(2)),Nm,Nm);
        y_real{2} = zeros(numel(DCM.options.Fdcm(1):DCM.options.Fdcm(2)),Nm,Nm);
        
        y_im = cell(1,2);
        y_im{1} = zeros(numel(DCM.options.Fdcm(1):DCM.options.Fdcm(2)),Nm,Nm);
        y_im{2} = zeros(numel(DCM.options.Fdcm(1):DCM.options.Fdcm(2)),Nm,Nm);
        
        % Get files
        for s = 1:numel(ids)
            
            %fprintf('%d\n',ids(s))
            dcm_file = fullfile(opt.pdata,'dcm_files_eo_ec',sprintf('dcm_%04d_prep_merged_eo_ec.mat',ids(s)));
            
            if isfile(dcm_file)
                try
                    load(dcm_file);
                    y_real{1} = y_real{1}+real(DCM.xY.y{1});
                    y_real{2} = y_real{2}+real(DCM.xY.y{2});
                    
                    y_im{1} = y_im{1}+imag(DCM.xY.y{1});
                    y_im{2} = y_im{2}+imag(DCM.xY.y{2});
                    count = count+1;
                    
                catch err
                    warning('Could not extract data from %d', ids(s))
                    warning('This was the error: %s',err.message);
                end
            end
        end
        
        % Divide by samples to get average
        y_real{1} = y_real{1}/count;
        y_real{2} = y_real{2}/count;
        y_im{1} = y_im{1}/count;
        y_im{2} = y_im{2}/count;
        
        % Create the complex number and save
        y{1} = complex(y_real{1}, y_im{1});
        y{2} = complex(y_real{2}, y_im{2});
        
        xY.y = y;
        
        save(fullfile(opt.presults,[opt.group_names{i}{g} '_csd.mat']),'xY');
        
        group_name{idx} = opt.group_names{i}{g};
        sample_size(idx) = count;
        idx = idx +1;
        
        clear y
    end
end

fprintf('\n\n===Final sample sizes are:\n')
for i = 1:n_groups
    fprintf('%s: n=%d\n',group_name{i},sample_size(i))
end

