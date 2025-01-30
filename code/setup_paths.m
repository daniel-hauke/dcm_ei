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
clear;

