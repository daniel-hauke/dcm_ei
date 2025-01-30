

%% Options
presults = {'F:\BSNIP\P300\results\P300_grandmean_hc_multistart_gee_gii_lateral_v21'};
fnames = {'bsnip_dcm_p300_grandmean_hc_cmc_ei_v1_vbsv%d.mat'};

presults = {'F:\NAPLS2\results\MMN\MMN_grandmean_hc_multistart_gee_gii_lateral_v5'};
fnames = {'napls_dcm_mmn_grandmean_hc_cmc_ei_v1_vbsv%d.mat'};

presults = {'F:\dcm_ei\results\assr\multistart'};
fnames = {'dcm_assr_cmc_ei_v1_vbsv%d.mat'};
condition_labels = {'40Hz ASSR'};

% presults = {'F:\dcm_ei\results\rest\multistart'};
% fnames = {'dcm_assr_cmc_ei_v1_vbsv%d.mat'};
%condition_labels = {'eyes open'};

n_vsbv = 2501;

%% Contraints
range_ss = [1 60];
range_sp = [1 200];
range_ii = [1 200];
range_dp = [1 200];


%% Load F and parameters
upper_bound = [range_ss(2) range_sp(2) range_ii(2) range_dp(2)];
lower_bound = [range_ss(1) range_sp(1) range_ii(1) range_dp(1)];

% Initialise arrays
F = NaN(n_vsbv,numel(presults));
T = NaN(n_vsbv,4,numel(presults));
T_prior = NaN(n_vsbv,4,numel(presults));
files = cell(n_vsbv,numel(presults));
vbsvs = 1:n_vsbv';

for r = 1:numel(presults)
    for v = 1:n_vsbv
        
        dcm_file = fullfile(presults{r},'dcms',sprintf(fnames{r},v));
        
        if isfile(dcm_file)
            load(dcm_file);
            T(v,:,r) = convert_tau_to_ms(DCM.Ep.T);
            T_prior(v,:,r) = convert_tau_to_ms(DCM.M.pE.T);
            
            % Check if posterior falls within specified range
            if all((T(v,:,r) < upper_bound) & ( T(v,:,r) > lower_bound))
                F(v,r) = DCM.F;
                files{v,r}= dcm_file;
            end
        end
    end
end


%% Keep only models that meet criteria in both data sets
if numel(presults)>1
keep = sum(~isnan(F),2)==2;
else
    keep = ~isnan(F);
end

T = T(keep,:,:);
T_prior = T_prior(keep,:,:);
files = files(keep,:);
vbsvs = vbsvs(keep);
F = F(keep,:);


%% Compute best models
[~, m] = maxk(sum(F,2),3);


T_prior(m,:,:)
T(m,:,:)
vbsvs(m)
%files{m,1}


% [~, m1] = maxk(F(:,1),10);
% [~, m2] = maxk(F(:,2),10);
% 
% [vbsvs(m1) vbsvs(m2)]


%% Generate plots for best models only to save time
files_to_plot = files([1 m'],:);
%condition_labels = {'C1', 'C2'};

for j = 1:numel(presults)
    
    pfigures = fullfile(presults{j},'plots');
    if ~isequal(exist(pfigures,'dir'),7); mkdir(pfigures); end
    if ~isequal(exist(fullfile(pfigures, 'all_channels'),'dir'),7); mkdir(fullfile(pfigures, 'all_channels')); end
    
    
    for i = 1:size(files_to_plot,1)
        
        % Get F
        load(fullfile(files_to_plot{i,j}));
        [~, sname] = fileparts(DCM.name);
        
        % Plot responses
        if contains(fnames,'assr') || contains(fnames,'rest')
            f = plot_actual_vs_predicted_csd(DCM,condition_labels,'off');
        else
            f = plot_actual_vs_predicted_erp(DCM,condition_labels,'off');
        end
        title(sname, 'Interpreter', 'none');
        
        saveas(gcf, fullfile(pfigures, 'all_channels', [sname '.png']));
        close gcf
        clear f
    end
end

