






D = spm_eeg_load('F:\BSNIP\rest\data\0001\EO\MrejdMspmeeg_0001_EO_fe_rej_ica_MARA_int.mat');
n_trials = ntrials(D);
t = time(D);
for i = 1:n_trials
    new_cond_labels{i} = sprintf('trial%d',i);
end
D = conditions(D,1:n_trials, new_cond_labels);
save(D);




%    DCM.xY.Dfile        - data file
%    DCM.options.trials  - trial codes
%    DCM.options.Tdcm    - Peri-stimulus time window
%    DCM.options.D       - Down-sampling
%    DCM.options.han     - Hanning
%    DCM.options.h       - Order of (DCT) detrending

DCM.xY.Dfile = 'F:\BSNIP\rest\data\0001\EO\MrejdMspmeeg_0001_EO_fe_rej_ica_MARA_int.mat';
DCM.options.trials = 1:n_trials;
DCM.options.Tdcm  = [min(t) max(t)];
DCM.options.D  = 1;
DCM.options.han = 0;
DCM.options.h = 1;
 DCM.options.Tdcm(1)  = 0;           % start of peri-stimulus time to be modelled
    DCM.options.Tdcm(2)  = Inf;         % end of peri-stimulus time to be modelled
    DCM.options.Fdcm     = [3 48];     % frequency band to be modelled (default = 4-48 Hz)
    
    
DCM = spm_dcm_erp_data(DCM,0);

% Input DCM structure requires:
%       DCM.xY.Dfile
%       DCM.xY.Ic
%       DCM.Lpos
%       DCM.options.spatial - 'ERP', 'LFP' or 'IMG'
DCM.M.dipfit.model = 'cmc';
DCM.M.dipfit.type = 'ECD';
DCM.Sname = {'lPC', 'rPC', 'lFC', 'rFC'};
DCM.Lpos  = [-29 -68 49;    % left parietal cortex
    29 -68 49;    % rightparietal cortex
    -33  45 28;    % left frontal cortex
    33  45 28]';  % right frontal cortex
DCM.options.spatial  = 'ECD';
DCM  = spm_dcm_erp_dipfit(DCM, 1);   


Nm = 8; 
DCM.M.U = spm_dcm_eeg_channelmodes(DCM.M.dipfit,Nm);
 
ccf      = spm_csd2ccf(DCM.xY.y,DCM.xY.Hz);
scale    = max(spm_vec(ccf));
DCM.xY.y = spm_unvec(8*spm_vec(DCM.xY.y)/scale,DCM.xY.y);

% normalised precision
%--------------------------------------------------------------------------
DCM.xY.Q  = spm_dcm_csd_Q(DCM.xY.y);
DCM.xY.X0 = sparse(size(DCM.xY.Q,1),0);



DCM  = spm_dcm_csd_data(DCM);


