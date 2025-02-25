function setup_paths
%--------------------------------------------------------------------------
% Sets up paths
%--------------------------------------------------------------------------


%% Get project path
%close all; clear all;
project_path = fileparts(mfilename('fullpath'));


%% Restore default path
restoredefaultpath;


%% Set figure defaults
set(0,'DefaultFigureColor',[1 1 1])
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultAxesFontWeight','bold')
set(0,'DefaultAxesFontName','Calibri')


%% Set paths
% Add project path
warning off
addpath(genpath(project_path));

% Setup SPM path:
% Remove subfolders of SPM, since it is recommended, and fieldtrip creates
% conflicts with matlab functions otherwise.
path_spm = fileparts(which('spm')); % get path to SPM
rmpath(genpath(path_spm)); % remove spm
addpath(path_spm); % only add main folder
warning on


%% Setup SPM defaults
setup_spm;

%% Replace SPM functions that were changed
% Because it is not possible to exclude single functions from the search
% path, we will move the SPM functions that were changed to a back-up
% folder called
backup_folder = fullfile(project_path,'toolboxes','backup_spm12_functions');
warning('SPM12 functions need to be changed. This can mess up other analyses you are doing with this SPM version.')
warning('The original functions are backed-up here: %s\n', backup_folder)


if ~exist(backup_folder)
    mkdir(backup_folder);
    move_to_backup = 1;
else
    move_to_backup = 0;
end

if move_to_backup
    changed_spm12_functions = dir(fullfile(project_path,'toolboxes','changed_spm12_functions','*.m'));
    warning('The following functions have been removed from the SPM12 folder:')
    for i = 1:numel(changed_spm12_functions)
        original_fun = fullfile(path_spm,'toolbox','dcm_meeg',changed_spm12_functions(i).name);
        movefile(original_fun, fullfile(backup_folder,changed_spm12_functions(i).name))
        if i == numel(changed_spm12_functions)
            warning('%s\n\n',original_fun)
        else
            warning('%s',original_fun)
        end
    end
    
end

if ~move_to_backup
    rmpath(backup_folder);
end


%% Replace tapas functions that were changed
% Because it is not possible to exclude single functions from the search
% path, we will move the tapas functions that were changed to a back-up
% folder
path_tapas = fileparts(which('tapas_ceode_fx_cmc.m'));
backup_folder = fullfile(project_path,'toolboxes','backup_tapas_functions');
warning('TAPAS functions needed to be changed. This can mess up other analyses you are doing with this TAPAS version.')
warning('The original functions are backed-up here: %s\n', backup_folder)


if ~exist(backup_folder)
    mkdir(backup_folder);
    move_to_backup = 1;
else
    move_to_backup = 0;
end

if move_to_backup
    changed_tapas_functions = dir(fullfile(project_path,'toolboxes','changed_tapas_functions','*.m'));
    warning('TAPAS functions need to be changed. This can mess up other analyses you are doing with this TAPAS version.')
    warning('The original functions are backed-up here: %s\n', backup_folder)
    warning('The following functions have been removed from the TAPAS folder:')
    for i = 1:numel(changed_tapas_functions)
        original_fun = fullfile(path_tapas,changed_tapas_functions(i).name);
        movefile(original_fun, fullfile(backup_folder,changed_tapas_functions(i).name))
        if i == numel(changed_tapas_functions)
            warning('%s\n\n',original_fun)
        else
            warning('%s',original_fun)
        end
    end
    
end

if ~move_to_backup
    rmpath(backup_folder);
end


