function fh = plot_C (C, model_names, visibility)
%--------------------------------------------------------------------------
% Function to plot a confunsion matrix.
%--------------------------------------------------------------------------


%% Defauls
if nargin < 3
    visibility = 'on';
end


%% Plot
axes_label_font_size = 13;
set(0,'DefaultAxesFontSize',11,'defaultLegendInterpreter','none')
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')

fh = figure('Position',  [100, 100, 450, 400], 'Visible', visibility);
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
ylabel('Generating Model','FontSize',axes_label_font_size)
xlabel('Inferred Model','FontSize',axes_label_font_size)
