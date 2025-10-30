function fh = plot_C (C, model_names, visibility)
%--------------------------------------------------------------------------
% Function to plot a confunsion matrix.
%--------------------------------------------------------------------------


%% Defauls
if nargin < 3
    visibility = 'on';
end


%% Plot
min_fontsize = 12;
set(0,'DefaultAxesFontSize',min_fontsize,'defaultLegendInterpreter','none')
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')

fh = figure('Position',  [100, 100, 540, 500], 'Visible', visibility);
imagesc(C)
colormap(flipud(gray))
colorbar
caxis([0 1])
axis('square');
xticks(1:length(model_names))
yticks(1:length(model_names))
xticklabels(model_names)
yticklabels(model_names)
add_values_to_imagesc2(C)
set(findall(gcf,'-property','FontSize'),'FontSize',min_fontsize)
ylabel('True model','FontSize',min_fontsize+4)
xlabel('Inferred model','FontSize',min_fontsize+4)
