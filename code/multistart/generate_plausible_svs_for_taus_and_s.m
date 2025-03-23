%--------------------------------------------------------------------------
% This function defines a model and its prior to generate starting values
% for the vartional Bayes inversion scheme.
%--------------------------------------------------------------------------



%% Options
opt.data = 'rest';   % paradigm: 'p300', 'mmn', 'assr','rest'
opt.model = 'cmc';




%% Paths
[~, uid] = unix('whoami'); % get user id

% Specify local paths
switch uid(1:end-1)
    
    % Daniel's paths
    case 'laptop-0jhjt7kf\danie'
        switch lower(opt.data)
            case {'p300','mmn','p50'}
                opt.spath = 'C:\projects\dcm_ei\results\multistart\vbsvs_tau_s_6_sources_erp';
            case 'assr'
                opt.spath = 'C:\projects\dcm_ei\results\multistart\vbsvs_tau_s_6_sources_csd';
            case 'rest'
                opt.spath = 'C:\projects\dcm_ei\results\multistart\vbsvs_tau_s_4_sources_csd';
        end
end

[~,~] = mkdir(opt.spath);

%% Define model
switch opt.data
    case {'p300','mmn','p50'}
        n_sources = 6;
        
        % Forward connections
        A{1} = zeros(n_sources);
        A{1}(3,1) = 1;
        A{1}(4,2) = 1;
        A{1}(5,3) = 1;
        A{1}(6,4) = 1;
        
        % Backward connections
        A{2} = zeros(n_sources);
        A{2}(1,3) = 1;
        A{2}(2,4) = 1;
        A{2}(3,5) = 1;
        A{2}(4,6) = 1;
        
        
        % Connections modulated by condition
        B{1} = zeros(n_sources);
        B{1} = B{1} + A{1} + A{2};
        
        % Lateral
        A{1}(1,2) = 1;
        A{1}(2,1) = 1;
        A{1}(3,4) = 1;
        A{1}(4,3) = 1;
        A{1}(5,6) = 1;
        A{1}(6,5) = 1;
        
        % Input
        C = [1; 1; 0; 0; 0; 0];
        
        [pE,pC] = spm_dcm_neural_priors(A,B,C,opt.model);
        
        
        %% Fixed parameters and equality contraints
        % Fix regions-specific delay parameter
        pC.D = zeros(size(pC.D));
        
        % Fix modulatory extrinsic conenctions for now
        pC.M = zeros(size(pC.M));
        
        % Instead we will estimate delays that are constant across regions
        % Interpretation: [intrinsic_delays extrinsic_delays]
        pE.D_all_sources = [0 0];
        pC.D_all_sources = [1/64 1/64];
        
        % Interpretation of G's: [g_ee g_ii g_ei g_ie g_se]
        pE.G = zeros(1,5);
        pC.G(1) = 1/32;
        pC.G(2) = 1/32;
        pC.G(3) = 0;  % Fix those parameters
        pC.G(4) = 0;  % Fix those parameters
        pC.G(5) = 0;  % Fix those parameters
        
        % Tighten input covariance
        pC.R = [1/1024 1/1024];
        
        
        %% EI parameters
        % Means
        pE.B_g_ee = 0;
        pE.B_g_ii = 0;
        pE.B_g_ei = 0;
        pE.B_g_ie = 0;
        pE.B_g_se = 0;
        
        % Variances
        pC.B_g_ee = 1/8;
        pC.B_g_ii = 1/8;
        pC.B_g_ei = 0; % Fix those parameters
        pC.B_g_ie = 0; % Fix those parameters
        pC.B_g_se = 0; % Fix those parameters
        
        
    case {'assr'}
        
        n_sources = 6;
        
        % Forward connections
        A{1} = zeros(n_sources);
        A{1}(3,1) = 1;
        A{1}(4,2) = 1;
        A{1}(5,3) = 1;
        A{1}(6,4) = 1;
        
        % Backward connections
        A{2} = zeros(n_sources);
        A{2}(1,3) = 1;
        A{2}(2,4) = 1;
        A{2}(3,5) = 1;
        A{2}(4,6) = 1;
        
        % Lateral
        A{1}(1,2) = 1;
        A{1}(2,1) = 1;
        A{1}(3,4) = 1;
        A{1}(4,3) = 1;
        A{1}(5,6) = 1;
        A{1}(6,5) = 1;
        
        % Connections modulated by condition
        B = [];
        
        % Input
        C = sparse(n_sources,0);
        
        % Get neural default priors
        [pE,pC] = spm_dcm_neural_priors(A,B,C,opt.model);
        
        % Get forward model priors
        Sname = {'lTHA', 'rTHA', 'lA1', 'rA1', 'lHIP', 'rHIP'};
        dipfit.silent_source = strfind(Sname,'silent');
        dipfit.Lpos  = [-16 -30 -6;    % left MGN
            16 -30 -6;    % right
            -58 -16 14;    % left A1
            58 -16 14;    % right
            -24 -16 -30;   % left Hip
            24 -16 -30]'; % right
        dipfit.model = opt.model;
        dipfit.type  = 'ECD';
        dipfit.Ns = n_sources;
        dipfit.Nc = 229;
        [pE,pC] = spm_L_priors(dipfit,pE,pC);
        
        % More CSD model priors
        [pE,pC] = spm_ssr_priors(pE,pC);
        
        % Fixed parameters and equality contraints
        % Fix regions-specific delay parameter
        pC.D = zeros(size(pC.D));
        
        % Fix modulatory extrinsic conenctions for now
        pC.M = zeros(size(pC.M));
        
        % Instead we will estimate delays that are constant across regions
        % Interpretation: [intrinsic_delays extrinsic_delays]
        pE.D_all_sources = [0 0];
        pC.D_all_sources = [1/64 1/64];
        
        % Fix J parameters to prior (only pyramidal cells contribute to the signal)
        pC.J = sparse(zeros(size(pC.J)));
        
        % Interpretation of G's: [g_ee g_ii g_ei g_ie g_se]
        pE.G = zeros(1,5);
        pC.G = ones(1,5)*1/32;
        pC.G(3) = 0;
        pC.G(4) = 0;
        pC.G(5) = 0;
        
        % Fix all condition-specific parameters, because there is just one condition
        % global g_ee, g_ii, g_ei, g_ie, g_se parameters
        % Means
        pE.B_g_ee = 0;
        pE.B_g_ii = 0;
        pE.B_g_ei = 0;
        pE.B_g_ie = 0;
        pE.B_g_se = 0;
        
        pC.B_g_ii = 0;
        pC.B_g_ee = 0;
        pC.B_g_ei = 0;
        pC.B_g_ie = 0;
        pC.B_g_se = 0;
        
    case {'rest'}
        
        n_sources = 4;
        
        % Forward connections
        A{1} = zeros(n_sources);
        A{1}(3,1) = 1;
        A{1}(4,2) = 1;
        
        % Backward connections
        A{2} = zeros(n_sources);
        A{2}(1,3) = 1;
        A{2}(2,4) = 1;
        
        % Lateral
        A{1}(1,2) = 1;
        A{1}(2,1) = 1;
        A{1}(3,4) = 1;
        A{1}(4,3) = 1;
        
        % Connections modulated by condition
        B{1} = zeros(n_sources);
        B{1}(3,1) = 1;
        B{1}(4,2) = 1;
        B{1}(1,3) = 1;
        B{1}(2,4) = 1;
        
        % Input
        C = sparse(n_sources,0);
        
        % Get neural default priors
        [pE,pC] = spm_dcm_neural_priors(A,B,C,opt.model);
        
        % Get forward model priors
        Sname =  {'lPC', 'rPC', 'lFC', 'rFC'};
        dipfit.silent_source = strfind(Sname,'silent');
        dipfit.Lpos  =  [-29 -68 49;    % left parietal cortex
            29 -68 49;    % rightparietal cortex
            -33  45 28;    % left frontal cortex
            33  45 28]';  % right frontal cortex
        
        dipfit.model = opt.model;
        dipfit.type  = 'ECD';
        dipfit.Ns = n_sources;
        dipfit.Nc = 60;
        [pE,pC] = spm_L_priors(dipfit,pE,pC);
        
        % More CSD model priors
        [pE,pC] = spm_ssr_priors(pE,pC);
        
        % Fixed parameters and equality contraints
        % Fix regions-specific delay parameter
        pC.D = zeros(size(pC.D));
        
        % Fix modulatory extrinsic conenctions for now
        pC.M = zeros(size(pC.M));
        
        % Instead we will estimate delays that are constant across regions
        % Interpretation: [intrinsic_delays extrinsic_delays]
        pE.D_all_sources = [0 0];
        pC.D_all_sources = [1/64 1/64];
        
        % Fix J parameters to prior (only pyramidal cells contribute to the signal)
        pC.J = sparse(zeros(size(pC.J)));
        
        % Interpretation of G's: [g_ee g_ii g_ei g_ie g_se]
        pE.G = zeros(1,5);
        pC.G = ones(1,5)*1/32;
        pC.G(3) = 0;
        pC.G(4) = 0;
        pC.G(5) = 0;
        
        % Fix all condition-specific parameters, because there is just one condition
        % global g_ee, g_ii, g_ei, g_ie, g_se parameters
        % Means
        pE.B_g_ee = 0;
        pE.B_g_ii = 0;
        pE.B_g_ei = 0;
        pE.B_g_ie = 0;
        pE.B_g_se = 0;
        
        pC.B_g_ii = 1/8;
        pC.B_g_ee = 1/8;
        pC.B_g_ei = 0;
        pC.B_g_ie = 0;
        pC.B_g_se = 0;
end


%% Create starting value grid
% [SS SP II DP]
% Define plausible tau ranges
% t1_range = log([2 16 32 64]./2);
% t2_range = log([2 16 32 64 128]./2);
% t3_range = log([2 16 32 64 128]./16);
% t4_range = log([2 16 32 64 128]./28);
t1_range = log([2 16 32 64]./2);
t2_range = log([2 16 32 64 128]./2);
t3_range = log([2 16 32]./16);
t4_range = log([2 16 32 64 128]./28);
s_range = linspace(-2,2,5);

% Save default SVs
i = 1;
P = pE;
save(fullfile(opt.spath,['vbsv_' num2str(i) '.mat']),'P');


for t1 = 1:numel(t1_range)
    for t2 = 1:numel(t2_range)
        for t3 = 1:numel(t3_range)
            for t4 = 1:numel(t4_range)
                for s = 1:numel(s_range)
                    
                    
                    P = pE;
                    P.S = s_range(s);
                    P.T(1) = t1_range(t1);
                    P.T(2) = t2_range(t2);
                    P.T(3) = t3_range(t3);
                    P.T(4) = t4_range(t4);
                    
                    i = i+1; % Update count
                    save(fullfile(opt.spath,['vbsv_' num2str(i) '.mat']),'P');
                end
            end
        end
    end
end





