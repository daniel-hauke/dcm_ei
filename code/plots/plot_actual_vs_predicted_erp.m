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
U = full(DCM.M.U');
t = DCM.xY.pst;


%% Figure settings
scrsz = get(0,'screenSize');
outerpos = [0.2*scrsz(3),0.2*scrsz(4),0.7*scrsz(3),0.8*scrsz(4)];

fh = figure('OuterPosition', outerpos, 'Visible', visibility);
set(0,'DefaultAxesFontSize',10)


%% compute model fit
for c =  1:n_cond
    y{c} = (DCM.H{c}+DCM.R{c})*U;
    yhat{c} = DCM.H{c}*U;
    r{c} = (DCM.R{c}*U);
    
    % Compute overall variance explained
    MSE(c) = sum(sum(r{c}.^2));
    SS(c)  = sum(sum(y{c}.^2));
    R2(c) = 1-(MSE(c)/SS(c));
        
    cor(c) = corr(y{c}(:),yhat{c}(:),'type','Pearson');
    
end


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
    if c == 1
       % TextLocation(sprintf('r=%.2f, r_{(total)}=%.2f',round(cor(c),2),round(mean(cor),2)),'Location','NorthWest');
        TextLocation(sprintf('R^2=%d%%, R^2_{(total)}=%d%%',round(R2(c)*100),round(mean(R2)*100)),'Location','NorthWest');
    else
        %TextLocation(sprintf('r=%.2f',round(cor(c),2)),'Location','NorthWest');
        TextLocation(sprintf('R^2=%d%%',round(R2(c)*100)),'Location','NorthWest');
    end
end

fprintf('Correlation condition 1: r=%.2f\n',cor(1));
fprintf('Correlation condition 2: r=%.2f\n',cor(2));
fprintf('Correlation total: r=%.2f\n\n',mean(cor));

fprintf('Variance explained condition 1: R^2=%d%%\n',round(R2(1)*100));
fprintf('Variance explained condition 2: R^2=%d%%\n',round(R2(2)*100));
fprintf('Variance explained total: R^2=%d%%\n',round(mean(R2)*100));


%% Link axes
linkaxes([ax{:}],'xy');
