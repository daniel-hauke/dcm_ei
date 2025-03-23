function [sDCM, param_name] = sim_individual(DCM, param, opt)


field = getfield(DCM.Ep, param);


% Used if field is a cell (e.g. A and B parameters)
if iscell(field)
    
    % Cycle through cells
    for c = 1:numel(field)
        
        % Get all parameter indices
        if opt.est
            if strcmp(param, 'A')
                idx = find(field{c}~=-32);
            else
                idx = find(field{c}~=0);
            end
        else
            idx = 1:numel(field{c});
        end
        
        % Cycle through all parameters
        for i = 1:numel(idx)
            clear p temp;
            for j = 1:numel(field)
                temp{j} = zeros(size(field{j}));
            end
            temp{c}(idx(i)) = 1;
            p = struct();
            p = setfield(p,param,temp);
            
            % Simulate
            sDCM{i} = sim_dcm(opt.dcm, p, opt);
            
            [row,col] = find(temp{c} == 1);
            param_name{i} = sprintf('%s%d_%d_%d', string(fieldnames(p)), c, row, col);
        end
    end
    
    % Used if field is simply a matrix or a scalar (e.g. B_g_ee)
else
    
    % Get parameter indices
    if opt.est
        idx = find(field~=0);
    else
        idx = 1:numel(field);
    end
    
    % Cycle through all parameters
    for i = 1:numel(idx)
        
        clear p temp;
        temp = zeros(size(field));
        temp(idx(i)) = 1;
        p = struct();
        p = setfield(p,param,temp);
        
        % Simulate
        sDCM(:,i) = sim_dcm(DCM, p, opt);
        [row,col] = find(temp==1);
        param_name{i} = sprintf('%s_%d_%d', string(fieldnames(p)), row, col);
        
    end
end

