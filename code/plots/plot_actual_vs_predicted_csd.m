function fh = plot_actual_vs_predicted_csd(DCM, condition_label, visibility)
%--------------------------------------------------------------------------
% Function to plot actual vs predicted CSDs of an inverted DCM that is
% fit to one condition.
%
% IN 
%   DCM                 -> Inverted DCM structure
%   condition_label    -> vector with condition label for plotting
%
% OUT
%   fh                  -> figure handle
%
%--------------------------------------------------------------------------


%% Defaults
if nargin < 2
    condition_label = '';
    visibility = 'on';
elseif  nargin < 3
    visibility = 'on';
end

% Get other relevant information
n_sources = DCM.options.Nmodes;
ns = numel(DCM.M.Hz);              % number of sampled frequencies
ny = length(spm_vec(DCM.xY.y));    % total number of response variables
nr   = ny/ns;                       % number response components
x = DCM.M.Hz;                      % Frequencies to model


%% Figure settings
scrsz = get(0,'screenSize');
outerpos = [0.2*scrsz(3),0.2*scrsz(4),0.7*scrsz(3),0.8*scrsz(4)];
fh = figure('OuterPosition', outerpos, 'Visible', visibility);
set(0,'DefaultAxesFontSize',10)


%% compute model fit
freq = 40;
idx_freq = find(DCM.xY.Hz==freq);


%% Plot observed responses
ax{1,1} = subplot(2,2,1);
y = spm_vec(real(DCM.Hc{1})+real(DCM.Rc{1}));
y = reshape(y,ns,nr);
plot(x,y)
title(['Observed CSD ' condition_label])
xlabel('Frequency (Hz)');
ylabel('Real');
xlim([min(x) max(x)])

ax{2,1} = subplot(2,2,3);
y = spm_vec(imag(DCM.Hc{1})+imag(DCM.Rc{1}));
y = reshape(y,ns,nr);
plot(x,y)
title(['Observed CSD ' condition_label])
xlabel('Frequency (Hz)');
ylabel('Imaginary');
xlim([min(x) max(x)])

    
%% Plot predicted response
ax{1,2} = subplot(2,2,2);
yhat = spm_vec(real(DCM.Hc{1}));
yhat = reshape(yhat,ns,nr);
plot(x,yhat)
title(['Predicted CSD ' condition_label])
xlabel('Frequency (Hz)');
ylabel('Real');
xlim([min(x) max(x)])
    
ax{2,2} = subplot(2,2,4);
yhat = spm_vec(imag(DCM.Hc{1}));
yhat = reshape(yhat,ns,nr);
plot(x,yhat)
title(['Predicted CSD ' condition_label])
xlabel('Frequency (Hz)');
ylabel('Imaginary');
xlim([min(x) max(x)])


%% Link axes
linkaxes([ax{1,1} ax{1,2}],'xy');
linkaxes([ax{2,1} ax{2,2}],'xy');
