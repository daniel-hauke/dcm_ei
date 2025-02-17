function [fh, Ep, Cp, names] = plot_dcm_parameters(DCM, param, visibility)
%--------------------------------------------------------------------------
% Function to create plot of estimated DCM parameters.
% 
% IN:
%  DCM          -> DCM structure or DCM filename
%  param        -> String indicating field to plot, e.g. 'B' or 'C'
%  visibility   -> plot visibility ('on' or 'off')
% 
% OUT:
%  fh           -> plot handle
%  Ep           -> vectorised posterior parameter estimates to be plotted
%  Cp           -> vectorised posterior parameter variances to be plotted
%  names        -> parameter names
% 
%--------------------------------------------------------------------------


%% Defaults
if nargin<3
    visibility = 'on';
end
set(0,'defaultTextInterpreter','none');
set(0,'defaultAxesTickLabelInterpreter','none');  


%% Main
if ~isstruct(DCM)
    % Load DCM data
    load(dcm_file);
end
    
% Extract relevant parameters
Ep_vec = spm_vec(DCM.Ep);
Cp_vec = diag(full(DCM.Cp));

% Create a copy with 0's for Ep (used for indexing)
Ep_idx = spm_unvec(zeros(size(Ep_vec)), DCM.Ep);

% Determine value for fixed parameters
switch param
    case {'A', 'C'}
        fixed_val = -32;
    otherwise
        fixed_val = 0;
end

% Get corresponding field in index dummy
field = getfield(DCM.Ep, param);
field_idx = getfield(Ep_idx, param);


% Used if field is a cell (e.g. A and B parameters)
if iscell(field) 
    % Cycle through cells
    for c = 1:numel(field)
        
        % Get all parameter indices
        field_idx{c} = field{c}~=fixed_val;
        
        % Create plot names
        [row,col] = find(field_idx{c} == 1);
        temp{c} = cellstr(strcat(param, num2str(c), ' (', num2str(row), ',', num2str(col), ')'))';
    end
    names = [temp{:}];
else
     % Get all parameter indices
        field_idx = field~=fixed_val;
        
        % Create plot names
        if size(field,1) == 1 || size(field,2) == 1
            % Array is vector
            [row] = find(field_idx == 1);
            names = strcat(param, '(',cellstr(string(row)), ')');
        else
            % Array is a matrix
            [row,col] = find(field_idx == 1);
            names = strcat(param, '(', cellstr(string(row)), ',', cellstr(string(col)), ')');
        end
end
    
    
% Set index field and convert back to vector
Ep_idx = setfield(Ep_idx, param, field_idx);
Ep_vec_idx = logical(spm_vec(Ep_idx));
Ep = Ep_vec(Ep_vec_idx);
Cp = Cp_vec(Ep_vec_idx);


% Plot confidence intervals
scrsz = get(0,'screenSize');
fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.9*scrsz(3),0.9*scrsz(4)], 'Visible', visibility);
spm_plot_ci(Ep, Cp);
xticks(1:numel(names))
xticklabels(names);
xtickangle(45)
title(param);
end