function [y,pst] = spm_gen_erp(P,M,U)
% Generates a prediction of trial-specific source activity
% FORMAT [y,pst] = spm_gen_erp(P,M,U)
%
% P - parameters
% M - neural-mass model structure
% U - trial-effects
%   U.X  - between-trial effects (encodes the number of trials)
%   U.dt - time bins for within-trial effects
%
% y   - {[ns,nx];...} - predictions for nx states {trials}
%                     - for ns samples
% pst - peristimulus time (seconds)
%
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_gen_erp.m 6427 2015-05-05 15:42:35Z karl $

% default inputs - one trial (no between-trial effects)
%--------------------------------------------------------------------------
if nargin < 3, U.X = sparse(1,0); end

% check input u = f(t,P,M) and switch off full delay operator
%--------------------------------------------------------------------------
try, M.fu; catch, M.fu  = 'spm_erp_u'; end
try, M.ns; catch, M.ns  = 128;         end
try, M.N;  catch, M.N   = 0;           end
try, U.dt; catch, U.dt  = 0.004;       end

% peristimulus time
%--------------------------------------------------------------------------
if nargout > 1
    pst = (1:M.ns)*U.dt - M.ons/1000;
end

% within-trial (exogenous) inputs
%==========================================================================
if ~isfield(U,'u')
    
    % peri-stimulus time inputs
    %----------------------------------------------------------------------
    U.u = feval(M.fu,(1:M.ns)*U.dt,P,M);
    
end

if isfield(M,'u')
    
    % remove M.u to preclude endogenous input
    %----------------------------------------------------------------------
    M = rmfield(M,'u');
    
end

% between-trial (experimental) inputs
%==========================================================================
if isfield(U,'X')
    X = U.X;
else
    X = sparse(1,0);
end

if ~size(X,1)
    X = sparse(1,0);
end


% cycle over trials
%==========================================================================
y      = cell(size(X,1),1);
for  c = 1:size(X,1)
    
    % condition-specific parameters
    %----------------------------------------------------------------------
    Q   = spm_gen_Q(P,X(c,:));
    
    
    % Specify condition-specific inputs
    if isfield(M,'input_cond')
        % input_cond should be specified as a matrix with #conditions 
        % columns and #inputs rows.
        % 
        % For example, with two inputs and two conditions:
        % cond_specific_input = [1 0
        %                        1 1];
        % turns on input 1 in both conditions and inputs 2 in condition 2 
        % only.
        
         % Turn input(s) off for this condition
        Q.C(logical((Q.C~=-32).*~M.input_cond(c,:)))=-32;
    end
    
    
    
    % solve for steady-state - for each condition
    %----------------------------------------------------------------------
    M.x  = spm_dcm_neural_x(Q,M);
    
    % integrate DCM - for this condition
    %----------------------------------------------------------------------
    switch M.f
        case {'dde23_fx_nmda', 'dde23_fx_cmm_nmda', 'dde23_fx_cmm_nmda_ei_v1'}
            y{c} = dde23_int(Q,M,U);
        case 'euler_fx_cmc_ei_v1'
            y{c} = tapas_ceode_int_euler(Q,M,U);
        otherwise
            y{c} = spm_int_L(Q,M,U);
    end
    
end

