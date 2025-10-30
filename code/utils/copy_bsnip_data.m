%% Options
close all; clear all;
%restoredefaultpath;

opt.data   = 'P50';                            % 'P50' or 'P300'
opt.groups = {'HC'};


% Get info where to find the groups in the excel file
opt.dia_group_fname = 'Subjects_BSNIP_Master.xlsx';                     % Excel file with group codes, ''P50_Biotype_Subject_Table_Joined.xlsx'; '; this version excludes all HC, % this version is missing 68 ppl,
opt.dia_group_col = [5 6];                                       % Columns in excel file that have group code
opt.dia_group_names = {'HC', 'SCZ'};                                    % Group names (should match columns)
opt.bio_group_fname = 'BSNIP1and2 Biotypes - Hope Oloye.xlsx';          % Excel file with group codes
opt.bio_group_col = [3 4 5]; %[6 3 4 5];                                % Columns in excel file that have group code
opt.bio_group_names = {'B1', 'B2', 'B3'}; %{'HC', 'B1', 'B2', 'B3'};    % Group names (should match columns)


%% Specifcy opt.user-specific paths
[~, uid] = unix('whoami'); % get user id
% Specify local paths
switch uid(1:end-1)
    
    % Daniel's paths
    case 'dell-cvmyz84\daniel'
        opt.pcode   = 'C:\Users\daniel\Dropbox\BSNIP\EEG_Code\';
        opt.pspm    = 'C:\projects\toolboxes\spm12_v7771';
        opt.pgroups = 'C:\Users\daniel\Dropbox\BSNIP\';
        opt.poutliers = 'C:\Users\daniel\Dropbox\BSNIP\EEG_Code';
        
        switch opt.data
            case 'P50'
                opt.pdata      = 'E:\BSNIP\P50\P50_preprocessed_final_posthoc_filtered_1-30Hz';
                opt.presults   = 'D:\BSNIP\P50_preprocessed_final_posthoc_filtered_1-30Hz';
                opt.outlier_fname = 'P50_outliers_IQR.mat';
            case 'P300'
                opt.pdata         = 'E:\BSNIP\P300\P300_preprocessed_final_posthoc_filtered_1-15Hz';
                opt.presults      = 'C:\Users\daniel\Dropbox\Daniel\conferences\2025_SOBP\oral-poster';
                opt.outlier_fname = 'P300_outliers_IQR.mat';
        end
        
    otherwise
        error('Undefined user! Please specify a user in the "Specifcy user-specific paths" Section and provide the relevant paths.');
end

% Set up SPM
addpath(opt.pspm, opt.pcode);
spm('defaults', 'eeg');

% Create folders
[~, ~] = mkdir(opt.presults);
cd(opt.presults);


%% Compute grandmean data
% Load outlier data
outlier_data = load(fullfile(opt.poutliers, opt.outlier_fname));

for g = 1:numel(opt.groups)

    results_folder = [opt.presults '_' opt.groups{g}];
    [~,~] = mkdir(results_folder);
    
    % Load group data
    switch opt.groups{g}
        case {'HC','SCZ'}
            group_data = xlsread(fullfile(opt.pgroups, opt.dia_group_fname));
            col = opt.dia_group_col(strcmp(opt.groups{g},opt.dia_group_names));
        case {'B1','B2','B3'}
            group_data = xlsread(fullfile(opt.pgroups, opt.bio_group_fname));
            col = opt.bio_group_col(strcmp(opt.groups{g},opt.bio_group_names));
    end

    % Get ids
    ids = group_data(group_data(:,col)==1,1);
    ids = setdiff(ids, outlier_data.outliers); % remove outliers
    
    % Get files
    count = 0;
    files = [];
    for s = 1:numel(ids)
        fname = fullfile(opt.pdata, sprintf('%04d%',ids(s)),sprintf('f60-2avMrejdbMspmeeg_%04d_fe_rej_ica_MARA_int.mat',ids(s)));
        
        if exist(fname,'file')==2
            count = count+1;
            files{count,1} = fname;
        end
    end
    
    for s = 1:numel(files)
        % Get important info
        D = spm_eeg_load(files{s});
        D = copy(D, fullfile(results_folder,sprintf('f60-2avMrejdbMspmeeg_%04d_fe_rej_ica_MARA_int',ids(s))));
        save(D)
        clear D
    end
    
end