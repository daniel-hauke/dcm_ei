function precov_run_headmodel(pdata)



%pdata = 'C:\projects\dcm_ei\results\p300_napls\parameter_recovery\data';

cd(pdata)
temp = dir(fullfile(pdata,'*.mat'));
data_files = fullfile({temp.folder}',{temp.name}');


for s = 1:numel(data_files)
    
    D = spm_eeg_load(data_files{s});
    try D = rmfield(D,'inv'); end
    save(D); clear D;
    
    % Specify new head model
    job{1}.spm.meeg.source.headmodel.D = {data_files{s}};
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
end