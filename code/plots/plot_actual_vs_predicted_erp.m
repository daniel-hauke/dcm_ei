function fh = plot_actual_vs_predicted_erp(DCM, condition_labels, visibility)
%--------------------------------------------------------------------------
% Function to plot actual vs predicted responses of an inverted DCM that is
% fit to two conditions.
%
% IN 
%   DCM                 -> Inverted DCM structure
%   condition_labels    -> vector with condition labels for plotting
%
% OUT
%   fh                  -> figure handle
%
%--------------------------------------------------------------------------


%% Defaults
% Get number of conditions
n_cond = numel(DCM.options.trials);

if nargin < 2
    condition_labels = strcat('Condition', {' '}, cellstr(string([1:n_cond])));
    visibility = 'on';
elseif  nargin < 3
    visibility = 'on';
end


%% Get important variables
U = DCM.M.U';
t = DCM.xY.pst;


%% Figure settings
scrsz = get(0,'screenSize');
outerpos = [0.2*scrsz(3),0.2*scrsz(4),0.7*scrsz(3),0.8*scrsz(4)];

fh = figure('OuterPosition', outerpos, 'Visible', visibility);
set(0,'DefaultAxesFontSize',10)


%% Plot observed response
for c = 1:n_cond
    ax{c} = subplot(2,n_cond,c);
    plot(t,(DCM.H{c} + DCM.R{c})*U)
    title(condition_labels{c})
    xlim([min(t) max(t)]);
end


%% Plot prediced response
for c = 1:n_cond
    ax{n_cond+c} = subplot(2,n_cond,n_cond+c);
    plot(t,DCM.H{c}*U);
    title(condition_labels{c})
    xlim([min(t) max(t)]);
end


%% Link axes
linkaxes([ax{:}],'xy');
