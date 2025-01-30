function [f] = dde23_fx_cmm_NMDA_RM(x,u,P,M,xtau,t)
% state equations for canonical neural-mass and mean-field models
% FORMAT [f,J,Q] = spm_fx_cmm(x,u,P,M)
%
% x - states and covariances
%
% x(i,j,k)        - k-th state of j-th population of i-th source
%                   i.e., running over sources, pop. and states
%
%   population: 1 - excitatory spiny stellate cells (input cells)
%               2 - superficial pyramidal cells     (forward output cells)
%               3 - inhibitory interneurons         (intrisic interneurons)
%               4 - deep pyramidal cells            (backward output cells)
%
%        state: 1 V  - voltage
%               2 gE - conductance (excitatory)
%               3 gI - conductance (inhibitory)
%
%--------------------------------------------------------------------------
% refs:
%
% Marreiros et al (2008) Population dynamics under the Laplace assumption
%
% See also:
%
% Friston KJ.
% The labile brain. I. Neuronal transients and nonlinear coupling. Philos
% Trans R Soc Lond B Biol Sci. 2000 Feb 29;355(1394):215-36. 
% 
% McCormick DA, Connors BW, Lighthall JW, Prince DA.
% Comparative electrophysiology of pyramidal and sparsely spiny stellate
% neurons of the neocortex. J Neurophysiol. 1985 Oct;54(4):782-806.
% 
% Brunel N, Wang XJ.
% What determines the frequency of fast network oscillations with irregular
% neural discharges? I. Synaptic dynamics and excitation-inhibition
% balance. J Neurophysiol. 2003 Jul;90(1):415-30.
% 
% Brunel N, Wang XJ.
% Effects of neuromodulation in a cortical network model of object working
% memory dominated by recurrent inhibition. J Comput Neurosci. 2001
% Jul-Aug;11(1):63-85.
%
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_fx_cmm_NMDA.m 5741 2013-11-13 12:10:48Z guillaume $
 
% get dimensions and configure state variables
%--------------------------------------------------------------------------
ns   = size(M.x,1);                      % number of sources
np   = size(M.x,2);                      % number of populations per source
nk   = size(M.x,3);                      % number of states per population
x    = reshape(x,ns,np,nk);              % hidden states 

try x_tau_di = reshape(xtau(:,1),ns,np,nk); end         % DH ADDED
try x_tau_de = reshape(xtau(:,2),ns,np,nk); end         % DH ADDED
if nargin < 5
    x_tau_de = x;   % DH ADDED
    x_tau_di = x;   % DH ADDED
end

% extrinsic connection strengths
%==========================================================================
 
% exponential transform to ensure positivity constraints
%--------------------------------------------------------------------------
A{1}  = exp(P.A{1});                      % forward
A{2}  = exp(P.A{2});                      % backward
AN{1} = exp(P.AN{1});                     % forward
AN{2} = exp(P.AN{2});                     % backward
if isfield(P,'C_symm')                    % subcortical
    C(1:2,1) = exp(P.C(1));               % if inputs (1+2) constrained to be symmetrical
    C(3:6,1) = exp(P.C(3:6));
else
    C        = exp(P.C);                  % if inputs not constrained to be symmetrical
end
 

% detect and reduce the strength of reciprocal (lateral) connections
%--------------------------------------------------------------------------
for i = 1:length(A)
    L    = (A{i} > exp(-8)) & (A{i}' > exp(-8));
    A{i} = A{i}./(1 + 8*L);
end

            
% intrinsic connection strengths
%==========================================================================

% condition specific effects: Inhibition of SPGP's
%--------------------------------------------------------------------------
% G    = full(P.H);
% if any(P.G)
%     G(2,2,:) = squeeze(G(2,2,:)) + P.G;
% end
%   G    = exp(G);        % NB UNUSED



% connectivity switches
%==========================================================================
% 1 - excitatory spiny stellate cells (granular input cells)
% 2 - superficial pyramidal cells     (forward  output cells)
% 3 - inhibitory interneurons         (intrisic interneuons)
% 4 - deep pyramidal cells            (backward output cells)


% extrinsic connections (F B) - from superficial and deep pyramidal cells
%--------------------------------------------------------------------------
SA   = [1   0 ;
        0   1 ;
        0   2 ;         % RM CHANGED, to 0 2
        0   0]/8;
    
% extrinsic NMDA-mediated connections (F B) - from superficial and deep pyramidal cells
%--------------------------------------------------------------------------    
    
SNMDA   = [1   0 ;
           0   1 ;
           0   2 ;      % RM CHANGED, to 0 2
           0   0]/8;

% G(:,1)  ss -> ss (-ve self)  4
% G(:,2)  sp -> ss (-ve rec )  4
% G(:,3)  ii -> ss (-ve rec )  4
% G(:,4)  ii -> ii (-ve self)  4
% G(:,5)  ss -> ii (+ve rec )  4
% G(:,6)  dp -> ii (+ve rec )  2
% G(:,7)  sp -> sp (-ve self)  4
% G(:,8)  ss -> sp (+ve rec )  4
% G(:,9)  ii -> dp (-ve rec )  2
% G(:,10) dp -> dp (-ve self)  1

      
% % intrinsic connections (np x np) - excitatory
% %--------------------------------------------------------------------------
GE   = [ 0    0    0    0
         4    0    0    0
         0    0    0    0
         0    4    0    0];
     
GE_toI  = [ 0    0    0    0        % RM ADDED
            0    0    0    0
            4    4    0    0
            0    0    0    0];
     
GN   = [ 0    0    0    0           % RM ADDED
         4    0    0    0
         0    0    0    0
         0    4    0    0];
     
GN_toI= [0    0    0    0           % RM ADDED
         0    0    0    0
         4    4    0    0
         0    0    0    0];
 
% intrinsic connections (np x np) - inhibitory
%--------------------------------------------------------------------------
GI   = [ 8    0    2    0
         0    8    2    0           % was 0 8 2 0
         0    0    0    0           % was 0 0 0 0 
         0    0    8  128];         % RM ADDED *0.001 for spectra (changed back)
     
GI_B  = [0     0     0    0         % RM ADDED
         0     0     0    0         % was 0 0 0  0
         0     0    32    0         % was 0 0 32 0 
         0     0     0    0];
     
     
% Ensure lateral symmetry in P.GN_intrin and P.GGi_intrin?
%--------------------------------------------------------------------------
% P.GN_intrin([2 4 ])  = P.GN_intrin([1 3 ]);            % RA ADDED, orig [1 3 5] and [2 4 6] for 3 level model
% P.GGi_intrin([2 4 ]) = P.GGi_intrin([1 3 ]);

     
% rate constants (ns x np) (excitatory 4ms, inhibitory 16ms)
%--------------------------------------------------------------------------
P.T(:,1) = P.T(1,1);                      % AMPA time constants same throughout % RA ADDED
P.T(:,2) = P.T(1,2);                      % GABA time constants same throughout
P.T(:,3) = P.T(1,3);                      % NMDA time constants same throughout % JRS changed, orig symmetrical e.g. [1 3 5] and [2 4 6] for 3 level model

KE    = exp(-P.T(:,1))*1000/4;            % excitatory rate constants (AMPA)    % RM CHANGED, to 12
KI    = exp(-P.T(:,2))*1000/8;            % inhibitory rate constants (GABAa)   % RM CHANGED, to 8
KNMDA = exp(-(P.T(:,3) ))*1000/100;       % excitatory rate constants (NMDA)


% Voltages
%--------------------------------------------------------------------------
% VL   = -70*exp(P.K);                      % reversal  potential leak (K)        % RA ADDED
VL   = -70;                               % reversal  potential leak (K)
VE   =  60;                               % reversal  potential excite (Na)
VI   = -90;                               % reversal  potential inhib (Cl)
VR   = -40;                               % threshold potential
VN   =  10;                               % reversal Ca(NMDA)   

CV   = exp(P.CV).*[128 128 256 32]/1000;         % membrane capacitance
%CV   = exp(P.CV).*[0.9 0.9  0.9  0.9]/1000000;  % RM COMMENTED
GL   = 1;                                        % leak conductance
% GL   = 1*exp(P.GL);                              % RA ADDED
 
% mean-field effects:
%==========================================================================

% neural-mass approximation to covariance of states: trial specific
%----------------------------------------------------------------------
Vx   = exp(P.S)*32;
%Vx   = exp(P.S)*1;                              % RM COMMENTED

% mean population firing and afferent extrinsic input
%-------------------------------------------------------------------------- 
% m       = spm_Ncdf_jdw(x(:,:,1),VR,Vx);     % mean firing rate  
% a(:,1)  = A{1}*m(:,2);                      % forward afference  AMPA
% a(:,2)  = A{2}*m(:,4);                      % backward afference AMPA 
% an(:,1) = AN{1}*m(:,2);                     % forward afference  NMDA
% an(:,2) = AN{2}*m(:,4);                     % backward afference NMDA

m_no_delays = spm_Ncdf_jdw(x(:,:,1),VR,Vx);    % DH ADDED: Input without delays
m_in = spm_Ncdf_jdw(x_tau_di(:,:,1),VR,Vx);    % DH ADDED: Input with intrinsic delay
m_ex = spm_Ncdf_jdw(x_tau_de(:,:,1),VR,Vx);    % DH ADDED: Input with extrinsic delay

same_source = eye(ns);                         % DH ADDED: Indices for extrinsic connections within the source (i.e., self connections)
diff_source = ones(ns)-eye(ns);                % DH ADDED: Indices for extrinsic connections across sources

a(:,1)  = A{1}.*diff_source*m_ex(:,2) + A{1}.*same_source*m_no_delays(:,2);   % DH CHANGED: forward afference  AMPA
a(:,2)  = A{2}.*diff_source*m_ex(:,4) + A{2}.*same_source*m_no_delays(:,4);   % DH CHANGED: backward afference AMPA
an(:,1) = AN{1}.*diff_source*m_ex(:,2) + AN{1}.*same_source*m_no_delays(:,2); % DH CHANGED: forward afference  NMDA
an(:,2) = AN{2}.*diff_source*m_ex(:,4) + AN{2}.*same_source*m_no_delays(:,4); % DH CHANGED: backward afference NMDA


% Averge background activity and exogenous input
%==========================================================================
BE     = exp(P.E)*0.8;

Mg_a = 1.50265*exp(P.Mg(1));      % RM ADDED, changed from GAi_intrin to Mg
Mg_b =    0.33*exp(P.Mg(2));
Mg_c =   -0.06*exp(P.Mg(3));

% input
%--------------------------------------------------------------------------
if isfield(M,'u')
    
    % endogenous input
    %----------------------------------------------------------------------
    U = u(:);
    
else
    
    % exogenous input
    %----------------------------------------------------------------------
    U = C*u(:);
    
    % warning: in some cases (large t in particular), U is NaN
    % because of a division by zero in spm_erp_u:
    % U = exp(-(t - delay).^2/(2*scale^2));
    % => U = 0 for t=350; delay=50; scale=5;
    % followed by division by zero
    % U = prop*cumsum(U)/sum(U) + U*(1 - prop);
    % Nan is replaced by zero in this case:
    if ~isempty(isnan(U))
        U(isnan(U))=0;
    end
end


% flow over every (ns x np) subpopulation
%==========================================================================
f     = x;
same_pop = eye(np);          % DH ADDED: Indices for intrisinc connections within the same population (i.e., self connections)
diff_pop = ones(np)-eye(np); % DH ADDED: Indices for intrisinc connections across different population

for i = 1:ns
   
        % intrinsic coupling
        %------------------------------------------------------------------
%         E      = (GE*exp(P.GA_intrin))*m(i,:)'    + (GE_toI*exp(P.GA_intrin))*m(i,:)';   % RM ADDED - RA made all GA/GN/GI scalar
%         ENMDA  = (GN*exp(P.GN_intrin(i)))*m(i,:)' + (GN_toI*exp(P.GNi_intrin))*m(i,:)';  % RA ADDED (i) after GN_intrin
%         I      = (GI*exp(P.GG_intrin))*m(i,:)'    + (GI_B*exp(P.GGi_intrin(i)))*m(i,:)'; % RA ADDED (i) after GGi_intrin
        
        E      = (GE*exp(P.GA_intrin).*diff_pop)*m_in(i,:)' + (GE*exp(P.GA_intrin).*same_pop)*m_no_delays(i,:)' + ...           % DH CHANGED: Added delayed states
                 (GE_toI*exp(P.GA_intrin).*diff_pop)*m_in(i,:)'  + (GE_toI*exp(P.GA_intrin).*same_pop)*m_no_delays(i,:)'; 
             
        ENMDA  = (GN*exp(P.GN_intrin(i)).*diff_pop)*m_in(i,:)' + (GN*exp(P.GN_intrin(i)).*same_pop)*m_no_delays(i,:)' + ...     % DH CHANGED: Added delayed states
                 (GN_toI*exp(P.GNi_intrin).*diff_pop)*m_in(i,:)' + (GN_toI*exp(P.GNi_intrin).*same_pop)*m_no_delays(i,:)'; 
             
        I      = (GI*exp(P.GG_intrin).*diff_pop)*m_in(i,:)' + (GI*exp(P.GG_intrin).*same_pop)*m_no_delays(i,:)' + ...           % DH CHANGED: Added delayed states 
                 (GI_B*exp(P.GGi_intrin(i)).*diff_pop)*m_in(i,:)' + (GI_B*exp(P.GGi_intrin(i)).*same_pop)*m_no_delays(i,:)' ;      

  
        % extrinsic coupling (excitatory only) and background activity
        % (NB RM removed NMDAR-mediated extrinsic connections)
        %------------------------------------------------------------------
        E     = (E +  BE + SA*a(i,:)')*2;
%         ENMDA = (ENMDA + BE  )*2;   % RM CHANGED, was (ENMDA + BE  + SNMDA*an(i,:)')*2;
        ENMDA = (ENMDA + BE  + SNMDA*an(i,:)')*2;

        % and exogenous input(U): needed for sims
        %------------------------------------------------------------------
        E     = E       + U(i);  
        ENMDA = ENMDA   + U(i);
        

        % Voltage
        %==================================================================
          f(i,:,1) =    (GL*(VL - x(i,:,1))+...
                         x(i,:,2).*(VE - x(i,:,1))+...
                         x(i,:,3).*(VI - x(i,:,1))+...
                         x(i,:,4).*(VN - x(i,:,1)).* (Mg_a./(1 + Mg_b*exp(Mg_c.*x(i,:,1)))))./CV  ;  % RM ADDED
                     %   x(i,:,4).*(VN - x(i,:,1)).* mg_switch(x(i,:,1)))./CV ;
                               
        % Conductance
        %==================================================================
        f(i,:,2) = (E' - x(i,:,2)).*KE(i,:);
        f(i,:,3) = (I' - x(i,:,3)).*KI(i,:);
        f(i,:,4) = (ENMDA' - x(i,:,4))*KNMDA(i,:) ;
end

           
           
% vectorise equations of motion
%==========================================================================
f = spm_vec(f);
 
if nargout < 2, return, end

% [Q,J] = spm_dcm_delay(P,M);   % RM ADDED
                                % RM COMMENTED FOLLOWING SECTION - RESTORED


% % Jacobian
% % ==========================================================================
% J = spm_cat(spm_diff(M.f,x,u,P,M,1));
% 
% if nargout < 3, return, end
% 
% % Delays
% %==========================================================================
% % Delay differential equations can be integrated efficiently (but 
% % approximately) by absorbing the delay operator into the Jacobian
% %
% %    dx(t)/dt     = f(x(t - d))
% %                 = Q(d)f(x(t))
% %
% %    J(d)         = Q(d)df/dx
% %--------------------------------------------------------------------------
% % [specified] fixed parameters
% %--------------------------------------------------------------------------
% D  = [2 16];
% 
% d  = -D.*exp(P.D)/1000;
% Sp = kron(ones(nk,nk),kron( eye(np,np),eye(ns,ns)));  % states: same pop.
% Ss = kron(ones(nk,nk),kron(ones(np,np),eye(ns,ns)));  % states: same source
% 
% Dp = ~Ss;                            % states: different sources
% Ds = ~Sp & Ss;                       % states: same source different pop.
% D  = d(2)*Dp + d(1)*Ds;
% 
% 
% % Implement: dx(t)/dt = f(x(t - d)) = inv(1 - D.*dfdx)*f(x(t))
% %                     = Q*f = Q*J*x(t)
% %--------------------------------------------------------------------------
% Q  = spm_inv(speye(length(J)) - D.*J);


