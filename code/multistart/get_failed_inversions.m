


overwrite_old_check = 1;

presults = 'F:\dcm_ei\results\rest\multistart';
presults = 'F:\dcm_ei\results\assr\multistart';
%presults = 'F:\dcm_ei\results\p300\multistart';
presults = 'F:\dcm_ei\results\p50\multistart';
presults = 'E:\dcm_ei\results\rest_v2';
presults = 'D:\BSNIP\dcm_ei\results\rest_v3\multistart';

pdcms = fullfile(presults,'dcms');
perrorfiles = fullfile(presults,'errorfiles');

% VBSVs
all_vbsvs = 1:1501;

%% 
if overwrite_old_check
    load(fullfile(presults,'vbsvs_to_rerun.mat'));
    
    % Correct vbsv in new file names
    for vbsv = 1:numel(vbsvs_to_rerun)
        errorfile = fullfile(perrorfiles,['*.' num2str(vbsv)]);
        s = dir(errorfile);
        [~, new] = max([s.datenum]);
        if vbsv ~= vbsvs_to_rerun(vbsv)
            movefile(fullfile(s(new).folder,s(new).name), fullfile(s(new).folder,replace(s(new).name,['.' num2str(vbsv)], ['.' num2str(vbsvs_to_rerun(vbsv))])));
        end
    end
    
  % Remove old files
  
  for vbsv = 1:numel(all_vbsvs)
      % delete old file
      errorfile = fullfile(perrorfiles,['*.' num2str(vbsv)]);
      s = dir(errorfile);
      if length(s)>1
          dates = [s.datenum];
          for i = 1:numel(dates)
              if dates(i) ~= max(dates)
                  delete(fullfile(s(i).folder,s(i).name));
              end
          end
      end
  end
end


%%


% Get successful inversions
temp = dir(fullfile(pdcms, '*.mat'));
success_files = {temp.name}';
success_files = extractBetween(success_files,'vbsv','.mat');
success_files = cellfun(@str2double,success_files,'UniformOutput',0);
success_files = cat(1,success_files{:});


% Get failed invesions
vbsvs_to_rerun = [];
unknown_errors = [];
count_vbsv = 0;
count_unknown_errors = 0;
count_int_errors = 0;
count_setup_errors = 0;

for vbsv = setdiff(all_vbsvs,success_files)
    
     errorfile = fullfile(perrorfiles,['*.' num2str(vbsv)]);
    
    % Check if there was no error and if there was non then this was likely
    % a matlab crash on the cluster
    s = dir(errorfile);
    if isempty(s)
        count_vbsv = count_vbsv+1;
        vbsvs_to_rerun(count_vbsv,1) = vbsv;
    else
        if s.bytes == 0
            count_vbsv = count_vbsv+1;
            vbsvs_to_rerun(count_vbsv,1) = vbsv;
        else
            fid = fopen(fullfile(s.folder,s.name));
            text = fscanf(fid,'%c');
            if contains(text,'Undefined function or variable ''ey''') || contains(text,'Error in tapas_ceode_compute_xtau (line 61)')
                count_int_errors = count_int_errors+1;
            elseif contains(text,'Can''t reload ''/share/apps/matlabR2018b/bin/glnxa64/libmwhgbuiltins.so''')
                count_setup_errors = count_setup_errors+1;
                count_vbsv = count_vbsv+1;
                vbsvs_to_rerun(count_vbsv,1) = vbsv;
            else
                count_unknown_errors = count_unknown_errors+1;
                unknown_errors(count_unknown_errors,1) = vbsv;
                count_vbsv = count_vbsv+1;
                vbsvs_to_rerun(count_vbsv,1) = vbsv;
            end
            fclose(fid);
        end
    end
end



% 
% count_dcm_file_corrupt = 0;
% 
% for vbsv = all_vbsvs
%     
%     fname = dir(fullfile(presults,'dcms',sprintf('*dcm*vbsv%d.mat', vbsv)));
%     if ~isempty(fname)
%         try
%             fprintf('Trying to load dcm file: %s\n', fullfile(fname.folder,fname.name));
%             load(fullfile(fname.folder,fname.name))
%         catch
%             warning('Could not load file: %s\n', fullfile(fname.folder,fname.name));
%             count_vbsv = count_vbsv+1;
%             vbsvs_to_rerun(count_vbsv,1) = vbsv;
%             count_dcm_file_corrupt = count_dcm_file_corrupt+1;
%         end
%     end
% end

%vbsvs_to_rerun = unique(vbsvs_to_rerun);


fprintf('\nCounted %d successful inversion.\n',numel(success_files))
fprintf('Counted %d integration errors.\n',count_int_errors)
fprintf('Counted %d path setup errors.\n',count_setup_errors)
fprintf('Counted %d unknown errors.\n',count_unknown_errors)
%fprintf('Counted %d corrupted dcm files.\n',count_dcm_file_corrupt)
%fprintf('---------\nA total of %d out of %d inversions is accounted for.\n',numel(success_files)+count_unknown_errors+count_int_errors+count_setup_errors-count_dcm_file_corrupt,max(all_vbsvs))
fprintf('---------\nA total of %d out of %d inversions is accounted for.\n',numel(success_files)+count_unknown_errors+count_int_errors+count_setup_errors,max(all_vbsvs))

fprintf('%d models will be rerun.\n',numel(vbsvs_to_rerun))

save(fullfile(presults,'vbsvs_to_rerun.mat'), 'vbsvs_to_rerun');

