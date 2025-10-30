function [Q] = spm_gen_Q(P,X)
% Helper routine for spm_gen routines
% FORMAT [Q] = spm_gen_Q(P,X)
%
% P - parameters
% X - vector of between trial effects
% c - trial in question
%
% Q - trial or condition-specific parameters
%
% This routine computes the parameters of a DCM for a given trial, where
% trial-specific effects are deployed according to a design vector X. The
% parameterisation follows a standard naming protocol where, for example,
% X(1)*P.B{1} + X(2)*P.B{2}... adjusts P.A for all (input) effects encoded
% in P.B.
% P.BN and P.AN operate at NMDA receptors along extrinsic connections
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_gen_Q.m 6725 2016-02-19 19:14:25Z karl $


% condition or trial specific parameters
%==========================================================================
if isfield(P,'B')
    Q = rmfield(P,'B');
else
    Q = P;
end


% trial-specific effects on C (first effect only)
%--------------------------------------------------------------------------
try
    Q.C = Q.C(:,:,1) + X(1)*P.C(:,:,2);
end

% trial-specific effects on A (connections)
%--------------------------------------------------------------------------
for i = 1:length(X)
    
    % extrinsic (driving) connections
    %----------------------------------------------------------------------
    for j = 1:length(Q.A)
        
        Q.A{j} = Q.A{j} + X(i)*P.B{i};
        
        % CMM-NMDA specific modulation on extrinsic NMDA connections
        %------------------------------------------------------------------
        if isfield(P,'AN')
            Q.AN{j} = Q.AN{j} + X(i)*P.BN{i};
        end
        
    end
    
    % modulatory connections
    %----------------------------------------------------------------------
    if isfield(P,'M')
        Q.M  = Q.M + X(i)*P.N{i};
    end

    % intrinsic connections
    %----------------------------------------------------------------------
    if isfield(Q,'G')
        
        % DH added: Equality constrain on G
        if size(Q.G,1) ~= length(diag(P.B{i}))
            Q.G = repmat(Q.G(1,:), size(P.B{i},1),1); 
        end
        
        Q.G(:,1) = Q.G(:,1) + X(i)*diag(P.B{i});
    end
    
    
    % DH added: Intrinsic connections in E/I convolution-based cmc model
    %----------------------------------------------------------------------
    if isfield(Q,'B_g_ee')
        Q.G(:,1) = Q.G(:,1) + X(i)*P.B_g_ee(:,i);
    end
    if isfield(Q,'B_g_ii')
        Q.G(:,2) = Q.G(:,2) + X(i)*P.B_g_ii(:,i);
    end
    if isfield(Q,'B_g_ei')
        Q.G(:,3) = Q.G(:,3) + X(i)*P.B_g_ei(:,i);
    end
    if isfield(Q,'B_g_ie')
        Q.G(:,4) = Q.G(:,4) + X(i)*P.B_g_ie(:,i);
    end
    if isfield(Q,'B_g_se')
        Q.G(:,5) = Q.G(:,5) + X(i)*P.B_g_se(:,i);
    end
    
    
    % DH added: Intrinsic connections in E/I conductance-based cmm model
    %----------------------------------------------------------------------
    if isfield(Q,'B_g_ee_gaba')
        Q.g_ee_gaba = Q.g_ee_gaba + X(i)*P.B_g_ee_gaba(i);
        Q.g_ii_gaba = Q.g_ii_gaba + X(i)*P.B_g_ii_gaba(i);
        Q.g_ie_gaba = Q.g_ie_gaba + X(i)*P.B_g_ie_gaba(i);
        Q.g_ei_ampa = Q.g_ei_ampa + X(i)*P.B_g_ei_ampa(i);
        Q.g_ei_nmda = Q.g_ei_nmda + X(i)*P.B_g_ei_nmda(i);
        Q.g_se_ampa = Q.g_se_ampa + X(i)*P.B_g_se_ampa(i);
        Q.g_se_nmda = Q.g_se_nmda + X(i)*P.B_g_se_nmda(i);
    end

    
    % intrinsic connections
    %----------------------------------------------------------------------
    if isfield(Q,'int')
        for j = 1:numel(Q.int)
            if isfield(Q.int{j},'B')
                Q.int{j}.G = Q.int{j}.G + X(i)*Q.int{j}.B;
            else
                Q.int{j}.G(:,1) = Q.int{j}.G(:,1) + X(i)*P.B{i}(j,j);
            end
        end
    end
    
end
