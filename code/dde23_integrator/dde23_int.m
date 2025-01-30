function [y] = dde23_int(P, M, U)
%--------------------------------------------------------------------------
% [y] = dde23_int(P, M, U)
%
% Integration of a (delayed) dynamical system (conductance-based DCM)
% based on the matlab dde23 integrator.
%
%   x_{n+1} = x_{n} + dt .* f(xhat_{n-taun})
%
%--------------------------------------------------------------------------

% Get dde23 options
%--------------------------------------------------------------------------
% Get dde23 options
if isfield(M,'dde23_options')
    dde23_options = M.dde23_options;
else
    dde23_options = ddeset('RelTol', 1e-3, 'AbsTol', 1e-6);
end


% initialize starting point, time span and delays
%--------------------------------------------------------------------------
x_zero = spm_vec(M.x);
tspan = [0 M.ns-1]*U.dt;

% Get the scaling factors for delays
if isfield(M, 'pF')
    D = M.pF.D;
else
    % Default scaling values
    if contains(M.f, 'fx_nmda') || contains(M.f, 'fx_erp') || contains(M.f, 'fx_cmm')
        D = [2, 16];
    elseif contains(M.f, 'fx_cmc')
        D = [1, 8];
    end
end
delays = [D.*exp(P.D)/1000];


% integrate
%--------------------------------------------------------------------------
ufun = @(t) feval(M.fu,[t],P,M); % Define input function
ddefun = @(t,x,Z) feval(M.f,x,feval(ufun,t),P,M,Z,t); % Define dde function
sol = dde23(ddefun, delays, x_zero, tspan, dde23_options);
y = deval(sol,(0:M.ns-1)*U.dt)';








