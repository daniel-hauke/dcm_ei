




%% Options
% Get info where to find the groups in the excel file
opt.group_fname{1} = 'Subjects_BSNIP_Master.xlsx';          % Excel file with group codes
opt.group_col{1} = [5 6];                                   % Columns in excel file that have group code
opt.group_names{1} = {'HC', 'SCZ'};                         % Group names (should match columns)
opt.group_fname{2} = 'BSNIP1and2 Biotypes - Hope Oloye.xlsx';     % Excel file with group codes
opt.group_col{2} = [3 4 5]; %[6 3 4 5];                                 % Columns in excel file that have group code
opt.group_names{2} = {'B1', 'B2', 'B3'}; %{'HC', 'B1', 'B2', 'B3'};                    % Group names (should match columns)

opt.chan_order_60 = {'Fp1','Fpz','Fp2','AF3','AF4','F7','F5','F3','F1','Fz',...
    'F2','F4','F6','F8','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6',...
    'FT8','T7','C5','C3','C1','Cz','C2','C4','C6','T8','TP7','CP5','CP3',...
    'CP1','CPz','CP2','CP4','CP6','TP8','P7','P5','P3','P1','Pz','P2',...
    'P4','P6','P8','PO7','PO5','PO3','POz','PO4','PO6','PO8','O1','Oz',...
    'O2'};


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
        opt.pdata = 'F:\BSNIP\rest\results\rsEEG_preprocessed_final_files_60_chan_v3';
        opt.presults = 'F:\BSNIP\rest\results\rest_grandmean_v3';
    otherwise
        error('Undefined user! Please specify a user in the "Specifcy user-specific paths" Section and provide the relevant paths.');
end

% Set up SPM
%addpath(opt.pspm, opt.pcode);
spm('defaults', 'eeg');

% Create folders
[~, ~] = mkdir(opt.presults);
% [~, ~] = mkdir(fullfile(opt.pdata,'merged_eo_ec'));
% [~, ~] = mkdir(fullfile(opt.pdata,'dcm_files_eo_ec'));
%[~, ~] = mkdir(opt.pdata_60_chan);

%% Merge eyes-open and eyes-closed conditions and compute individual spectra
% Load group & outlier data
n_groups = 5;
group_name = cell(n_groups,1);
sample_size = NaN(n_groups,2);

group_count = 1;

for i = 1:numel(opt.group_fname)
    group_data = xlsread(fullfile(opt.pgroups, opt.group_fname{i}));
    
    for g = 1:numel(opt.group_names{i})
        
        files = cell(0);
        count_eo = 0;
        count_ec = 0;
        count = 0;
        
        % Get ids
        ids = group_data(group_data(:,opt.group_col{i}(g))==1,1);
        
        % Get files
        for s = 1:numel(ids)
            
            %             fname_ec = fullfile(opt.pdata,'EC',sprintf('MrejdMspmeeg_%04d_EC_fe_rej_ica_MARA_int.mat',ids(s)));
            %             fname_eo = fullfile(opt.pdata,'EO',sprintf('MrejdMspmeeg_%04d_EO_fe_rej_ica_MARA_int.mat',ids(s)));
            fname_ec = fullfile(opt.pdata, sprintf('60-MrejdMspmeeg_%04d_EC_fe_rej_ica_MARA_int.mat',ids(s)));
            fname_eo = fullfile(opt.pdata,sprintf('60-MrejdMspmeeg_%04d_EO_fe_rej_ica_MARA_int.mat',ids(s)));
            
            if isfile(fname_ec)
                count = count+1;
                count_ec = count_ec+1;
                files{count,1} = fname_ec;
            end
            
            if isfile(fname_eo)
                count = count+1;
                count_eo = count_eo+1;
                files{count,1} = fname_eo;
            end
        end
        
        % Merge the files and copy to new folder
        S.D = char(files);
        D = spm_eeg_merge(S);
        dfile = fullfile(opt.presults,[opt.group_names{i}{g} '_all_subjects_merged.mat']);
        move(D,dfile);
        
        group_name{group_count} = opt.group_names{i}{g};
        sample_size(group_count,1) = count_ec;
        sample_size(group_count,2) = count_eo;
        group_count = group_count +1;
    end
end


fprintf('\n\n===Final sample sizes are:\n')
for i = 1:n_groups
    fprintf('%s: eyes closed: n=%d, eyes open: n=%d\n',group_name{i},sample_size(i,1), sample_size(i,2))
end

