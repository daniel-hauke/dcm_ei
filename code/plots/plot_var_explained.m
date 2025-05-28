function fh = plot_var_explained(pdcms)



temp = dir(fullfile(pdcms,'*.mat*'));
files = fullfile({temp.folder}',{temp.name}');

%% Initialise variables
cor = NaN(numel(files),3);
R2 = NaN(numel(files),3);

for f = 1:numel(files)
    
    load(files{f});
    U = full(DCM.M.U');
    
    
    % Create difference waveform
     DCM.xY.y{3} = DCM.xY.y{2}-DCM.xY.y{1};
    
     % Compute model fit explained
     for c =  1:numel(DCM.xY.y)
         y = (DCM.H{c}+DCM.R{c})*U;
         yhat = DCM.H{c}*U;
         r = (DCM.R{c}*U);
         
         % Compute overall variance explained
         MSE = sum(sum(r{c}.^2));
         SS  = sum(sum(y{c}.^2));
         R2(f,c) = 1-(MSE(c)/SS(c));
         
         cor(f,c) = corr(y(:),yhat(:),'type','Pearson');
     end


    
    
    
end
