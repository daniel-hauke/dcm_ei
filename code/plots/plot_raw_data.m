function fh = plot_raw_data(D, visibility)
%--------------------------------------------------------------------------
% Function to plot actual vs predicted responses of an inverted DCM that is
% fit to two conditions.
%
% IN 
%   D                   -> Datafile
%   condition_labels    -> vector with condition labels for plotting
%
% OUT
%   fh                  -> figure handle
%
%--------------------------------------------------------------------------





%% Defaults
if nargin < 2
    visibility = 'on';
end


%% Load data
if ischar(D)
    D = spm_eeg_load(D);
end


%% Get important variables
condition_labels = conditions(D);
n_cond = numel(condition_labels);
t = time(D)*1000;
unit = units(D);

%% Figure settings
scrsz = get(0,'screenSize');
outerpos = [0.2*scrsz(3),0.2*scrsz(4),0.7*scrsz(3),0.8*scrsz(4)];
fh = figure('OuterPosition', outerpos, 'Visible', visibility);
set(0,'DefaultAxesFontSize',10)


%% Plot observed response
for c = 1:n_cond
    ax{c} = subplot(1,n_cond,c);
    plot(t,D(:,:,c))
    title(condition_labels{c})
    xlabel('time[ms]')
    ylabel(sprintf('amplitude[%s]',unit{1}));
    xlim([min(t) max(t)]);
end


%% Link axes
linkaxes([ax{:}],'y');

