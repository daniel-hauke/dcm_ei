







%DCM.xY.Dfile =  'E:\data\BSNIP\rest\rsEEG_BSNIP_preproc_v2\EC\MrejdMspmeeg_0050_EC_fe_rej_ica_MARA_int.mat';
DCM.xY.Dfile = 'E:\data\BSNIP\rest\rsEEG_BSNIP_preproc_v2\EC\MrejdMspmeeg_0035_EC_fe_rej_ica_MARA_int.mat';


% Clean up previous source localisation
D = spm_eeg_load(DCM.xY.Dfile);
try D = rmfield(D,'inv'); end
save(D); clear D;

% Specify new head model
job{1}.spm.meeg.source.headmodel.D = {DCM.xY.Dfile};
job{1}.spm.meeg.source.headmodel.val = 1;
job{1}.spm.meeg.source.headmodel.comment = '';
job{1}.spm.meeg.source.headmodel.meshing.meshes.template = 1;
job{1}.spm.meeg.source.headmodel.meshing.meshres = 2;
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'spmnas';
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.type = [1 85 -41];
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'spmlpa';
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.type = [-83 -20 -65];
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'spmrpa';
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.type = [83 -20 -65];
job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
job{1}.spm.meeg.source.headmodel.forward.eeg = '3-Shell Sphere';
job{1}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';

tic;
spm_jobman('run',{job});
t = toc;
fprintf('===\n\t Headmodel done in %s (HH:MM:SS).\n\n\n', datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));



DCM.options.trials = 1;
DCM.options.D  = 1;
DCM.options.han = 0;
DCM.options.h = 1;
DCM.options.Tdcm(1)  = 0;           % start of peri-stimulus time to be modelled
DCM.options.Tdcm(2)  = 5000;         % end of peri-stimulus time to be modelled
DCM.options.Fdcm     = [3 48];     % frequency band to be modelled (default = 4-48 Hz)
DCM.options.Rft = 7;
DCM.options.Nmodes = 8;
DCM.options.analysis = 'CSD';
DCM.options.spatial = 'ECD';
DCM.options.model = 'cmc';
DCM = spm_dcm_erp_data(DCM,0);


DCM.M.dipfit.model = 'cmc';
DCM.M.dipfit.type = 'ECD';
DCM.Sname = {'lPC', 'rPC', 'lFC', 'rFC'};
DCM.Lpos  = [-29 -68 49;    % left parietal cortex
    29 -68 49;    % rightparietal cortex
    -33  45 28;    % left frontal cortex
    33  45 28]';  % right frontal cortex
DCM  = spm_dcm_erp_dipfit(DCM, 1);


Nm = 8;
DCM.M.U = spm_dcm_eeg_channelmodes(DCM.M.dipfit,Nm);

DCM  = spm_dcm_csd_data(DCM);

ccf      = spm_csd2ccf(DCM.xY.y,DCM.xY.Hz);
scale    = max(spm_vec(ccf));
DCM.xY.y = spm_unvec(8*spm_vec(DCM.xY.y)/scale,DCM.xY.y);


Nm       = size(DCM.M.U,2);                    % number of spatial modes
DCM.M.l  = Nm;
DCM.M.Hz = DCM.xY.Hz;
DCM.M.dt = DCM.xY.dt;


% normalised precision
%--------------------------------------------------------------------------
DCM.xY.Q  = spm_dcm_csd_Q(DCM.xY.y);
DCM.xY.X0 = sparse(size(DCM.xY.Q,1),0);

