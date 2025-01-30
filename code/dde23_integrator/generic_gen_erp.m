function [y, pst] = generic_gen_erp(P, M, U)
% [y, pst] = generic_gen_erp(P, M, U)
% 
% Generate ERP data with modifiable integrator specification. Will default
% to using spm_int_L for integration if no integration function is
% specified in M.int
%
% Adapted from spm_gen_erp.m (original function lincense below).
%
%
% INPUT
%   P           struct          parameter structure
%   M           struct          model specification
%   U           struct          design specification
%
% OUTPUT
%   y           mat             Integrated activity in sensor space
%
% -------------------------------------------------------------------------
%
% ORIGINAL FUNCTION LICENSE
% 
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
%
% Karl Friston
% $Id: spm_gen_erp.m 5758 2013-11-20 21:04:01Z karl $
%--------------------------------------------------------------------------

% default inputs - one trial (no between-trial effects)
%--------------------------------------------------------------------------
if nargin < 3, U.X = sparse(1,0); end


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
    Q = spm_gen_Q(P, X(c, :));
    
    % solve for steady-state - for each condition
    %----------------------------------------------------------------------
    M.x  = spm_dcm_neural_x(Q,M);
    
    % integrate DCM - for this condition
    %----------------------------------------------------------------------
    % Check if custom integrator function should be used
    warning('You are using the generic ERP generator function.')
    if isfield(M,'int')
        y{c} = feval(M.int, Q, M, U);
        warning('Will use the following integrator: %s.', M.int)
    else
        y{c} = spm_int_L(Q, M, U);
        warning('Since no custom integrator has been specified in DCM.M.int, will use the default: spm_int_L.')
    end
    
end





