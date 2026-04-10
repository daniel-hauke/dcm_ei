 function [sDCM, param_array] = sim_dcm(DCM, param, opt)
%--------------------------------------------------------------------------
% Function to simulated from an inverted DCM by systematically changing one
% parameter. Will change parameter values passed in param structure to -50%
% up to +50% of the posterior expectation stored in DCM.Ep.
%
% IN
%   DCM             -> DCM structure or DCM filename
%   param           -> Structure that contains a field with the parameter
%                      field from which should be simulated (e.g., param.A
%                      or param.B). The content should be a logical array
%                      in the same format as the corresponding field in the
%                      original DCM for the (e.g., scalar, vector, array or
%                      cell array), parameters from which should be
%                      simulated need to be flagged with 1, all others need
%                      to be set to 0.
%   opt.opt.noise       -> 'estimated' or 'nn' (no opt.noise)
%   opt.opt.mode        -> 'abs' or 'perc' for absolute value or percentage
%                      value increase
%   opt.opt.vals        -> value to be added or percentage change 
%
% OUT
%   sDCM            -> cell array containing simulated DCMs
%
%--------------------------------------------------------------------------


%% Defaults
if nargin < 3
    opt.opt.mode = 'abs';
    opt.opt.vals = linspace(-0.5, 0.5, 5);
    opt.opt.noise = 'nn';
end


%% Defaults (for debugging only)
if nargin < 1
    % DCM = '/Volumes/T7/NAPLS2/MMN/DCM_v08/';
    opt.noise = 'nn';
    opt.mode = 'abs';
    opt.vals =  linspace(-0.5, 0.5, 5);

%     % Test case 1
%     % Simulate by increasing all modulatory forward connections
    % clear param;
    % param.B{1,1} = zeros(6,6);
    % param.B{1}(3,1) = 1;
    % param.B{1}(4,2) = 1;
    % param.B{1}(5,3) = 1;
    % param.B{1}(6,4) = 1;

    % % Test case 2
    % % Simulate by increasing all A-matrix forward connections
    % clear param;
    % param.A{1,1} = zeros(6,6);
    % param.A{1,2} = zeros(6,6);
    % param.A{1,3} = zeros(6,6);
    % param.A{1,1}(3,1) = 1;
    % param.A{1,1}(4,2) = 1;
    % param.A{1,1}(5,3) = 1;
    % param.A{1,1}(6,4) = 1;

    % % Test case 3
    % % Simulate by increasing a single T-value
    % clear param;
    % param.T = zeros(1,3);
    % param.T(1) = 1;

    % % Test case 4
    % % Simulate by changing the CV parameter
%     clear param;
%     param.CV = 1;


    % Test case 5 clear param;
    % clear param;
    % param.E = 1;

end


%% Load DCM
% Load DCM
% cd('/Volumes/T7/NAPLS2/MMN/DCM_v08/')
if ~isstruct(DCM)
    load(DCM)
end
try cd(fileparts(DCM.xY.Dfile)); end;

%% Generate parameter array
fieldname = char(fieldnames(param));
iscellfield = iscell(getfield(param, fieldname));
Ep = getfield(DCM.Ep, fieldname);
idx = getfield(param, fieldname);

% is the field a cell array? If so, simplify to array
if iscellfield
    which_cell = find(cell2mat(cellfun(@(x) any(any(x)), idx, 'UniformOutput', false)));
    Ep = Ep{which_cell};
    idx = idx{which_cell};
end


param_array = cell(numel(opt.vals),1);
switch opt.mode
    case 'abs'
        for i = 1:numel(opt.vals)
            param_array{i} = Ep + idx*opt.vals(i);
        end
    case 'perc'
        for i = 1:numel(opt.vals)
            param_array{i} = Ep + abs(Ep).*idx*opt.vals(i);
        end
end

%% Simulate
% Set opt.noise options
switch opt.noise
    case 'nn'
        opt.noise = 'var';
    case 'estimated'
        opt.noise = 'estimated';
end

% Initialize output array
sDCM = cell(numel(param_array),1);

for i = 1:numel(param_array)
    
    % Set parameter value to new value
    if iscellfield
        newfield = getfield(DCM.Ep, fieldname); % create copy of cell array
        newfield{which_cell} = param_array{i}; % replace only cell array that has changed
        DCM.Ep = setfield(DCM.Ep, fieldname, newfield);
    else
        DCM.Ep = setfield(DCM.Ep, fieldname, param_array{i});
    end
    
    % Simulate
    temp = spm_dcm_simulate_DH({DCM}, opt.noise, 0, 1);
    sDCM{i} = temp{1,1};
    clear temp newfield;
end

