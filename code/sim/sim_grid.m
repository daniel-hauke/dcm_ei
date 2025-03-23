function [sDCM, param_name] = sim_grid(DCM, param1, param2, opt)



%% Load DCM
if ~isstruct(DCM)
    load(DCM)
end

% Set opt.noise options
switch opt.noise
    case 'nn'
        opt.noise = 'var';
    case 'estimated'
        opt.noise = 'estimated';
end

%%
if ~isfield(opt,'idx')
    param_name = sprintf('%s_%s', param1, param2);
    mod = 'isnumber';
else
    if numel(opt.idx{1})==1
        param_name = sprintf('%s%d_%s%d', param1,opt.idx{1}, param2,opt.idx{2});
        mod = 'isvector';
    else
        param_name = sprintf('%s%d-%d_%s%d-%d', param1,opt.idx{1}(1),opt.idx{1}(2), param2,opt.idx{2}(1),opt.idx{2}(2));
        mod = 'ismatrix';
    end
end

for i = 1:numel(opt.vals{1})
    for j = 1:numel(opt.vals{2})
        
        temp_DCM = DCM;
        
      
        switch mod
            case 'isnumber'
                % Set new parameter value for parameter 1
                old_val1 = getfield(DCM.Ep,param1);
                new_val1 = old_val1+opt.vals{1}(i);
                temp_DCM.Ep = setfield(temp_DCM.Ep,param1,new_val1);
                
                % Set new parameter value for parameter 2
                old_val2 = getfield(temp_DCM.Ep,param2);
                new_val2 = old_val2+opt.vals{2}(j);
                temp_DCM.Ep = setfield(temp_DCM.Ep,param2,new_val2);
        
            case 'isvector'
                % Set new parameter value for parameter 1
                old_val1 = getfield(DCM.Ep,param1);
                new_val1 = old_val1;
                new_val1(opt.idx{1}) = old_val1(opt.idx{1})+opt.vals{1}(i);
                temp_DCM.Ep = setfield(temp_DCM.Ep,param1,new_val1);
                
                % Set new parameter value for parameter 2
                old_val2 = getfield(temp_DCM.Ep,param2);
                new_val2 = old_val2;
                new_val2(opt.idx{2}) = old_val2(opt.idx{2})+opt.vals{2}(j);
                temp_DCM.Ep = setfield(temp_DCM.Ep,param2,new_val2);
                
            case 'ismatrix'
                       % Set new parameter value for parameter 1
                old_val1 = getfield(DCM.Ep,param1);
                new_val1 = old_val1;
                new_val1(opt.idx{1}(1),opt.idx{1}(2)) = old_val1(opt.idx{1}(1),opt.idx{1}(2))+opt.vals{1}(i);
                temp_DCM.Ep = setfield(temp_DCM.Ep,param1,new_val1);
                
                % Set new parameter value for parameter 2
                old_val2 = getfield(temp_DCM.Ep,param2);
                new_val2 = old_val2;
                new_val2(opt.idx{2}(1),opt.idx{2}(2)) = old_val2(opt.idx{2}(1),opt.idx{2}(2))+opt.vals{2}(j);
                temp_DCM.Ep = setfield(temp_DCM.Ep,param2,new_val2);  
        end

        % Simulate
        temp = spm_dcm_simulate_DH({temp_DCM}, opt.noise, 0, 1);
        sDCM{i,j} = temp{1,1};
        
    end
end

