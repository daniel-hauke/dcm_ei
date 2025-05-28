function fh = plot_model_fit (pdcms, condition_names)





%% Compute R2
% Get files
temp = dir(fullfile(pdcms,'*.mat*'));
files = fullfile({temp.folder}',{temp.name}');

% Initialise variables
cor = NaN(numel(files),2);
R2 = NaN(numel(files),2);

for f = 1:numel(files)
    
    load(files{f});
    U = full(DCM.M.U');
    
    
    % Compute model fit explained
    for c = 1:numel(DCM.xY.y)
        y = (DCM.H{c}+DCM.R{c})*U;
        yhat = DCM.H{c}*U;
        r = (DCM.R{c}*U);
        
        % Compute overall variance explained
        MSE = sum(sum(r.^2));
        SS  = sum(sum(y.^2));
        R2(f,c) = 1-(MSE/SS);
        
        % Compute correlation
        cor(f,c) = corr(y(:),yhat(:),'type','Pearson');
    end
end


%% Plot
% colors
c =  [153 216 201;
      44 162 95]./256;

fh = figure;
subplot(1,2,1)
h = dabarplot({R2(:,1) R2(:,2)},'xtlabels', condition_names,'errorbars',0,...
    'scatter',1,'scattersize',15,'scatteralpha',0.5,'errorbars','SD',...
    'barspacing',0.8,'color',c); 
ylabel('R^2');
%yl = ylim; ylim([yl(1), yl(2)+2]);  % make more space for the legend
set(gca,'FontSize',11);
text(1, 1.05, sprintf('R^2=%d%%',round(mean(R2(:,1)*100))),'HorizontalAlignment', 'center');
text(2, 1.05, sprintf('R^2=%d%%',round(mean(R2(:,2)*100))),'HorizontalAlignment', 'center');


subplot(1,2,2)
h = dabarplot({cor(:,1) cor(:,2)},'xtlabels', condition_names,'errorbars',0,...
    'scatter',1,'scattersize',15,'scatteralpha',0.5,'errorbars','SD',...
    'barspacing',0.8,'color',c); 
ylabel('r');
%yl = ylim; ylim([yl(1), yl(2)+2]);  % make more space for the legend
set(gca,'FontSize',11);
text(1, 1.05, sprintf('r=%.2f',mean(cor(:,1))),'HorizontalAlignment', 'center');
text(2, 1.05, sprintf('r=%.2f',mean(cor(:,2))),'HorizontalAlignment', 'center');


fprintf('Mean R2=%d%% and mean r=%.2f\n', round(mean(mean(R2))*100), mean(cor(:)))

