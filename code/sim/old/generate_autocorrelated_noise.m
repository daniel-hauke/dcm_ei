

% Example usage:
N = 57;  % Number of samples
alpha = 0.8;  % Auto-correlation coefficient

% Generates auto-correlated noise using an autoregressive model.
%
% N     - Number of samples
% alpha - Auto-correlation coefficient (0 < alpha < 1)

noise = zeros(1, N);
noise(1) = randn;  % Initialize with Gaussian noise

for i = 2:N
    noise(i) = alpha * noise(i-1) + randn;  % AR(1) process
end


% Plot the generated noise
figure;plot(noise);
title('Auto-Correlated Noise');
xlabel('Time');
ylabel('Amplitude');





U = full(DCM.M.U');
residuals{1} = (DCM.R{1}*U);

for 
maxOrder = 10; % Maximum AR order to test
AIC = zeros(1, maxOrder);
BIC = zeros(1, maxOrder);

for p = 1:maxOrder
    [coeffs, var] = arburg(residuals, p);
    numParams = p + 1; % AR coefficients + noise variance
    
    % Compute AIC and BIC
    AIC(p) = 2*numParams + length(residuals)*log(var);
    BIC(p) = numParams*log(length(residuals)) + length(residuals)*log(var);
end

% Find the optimal order
[~, optimalOrder_AIC] = min(AIC);
[~, optimalOrder_BIC] = min(BIC);

fprintf('Optimal AR order by AIC: %d\n', optimalOrder_AIC);
fprintf('Optimal AR order by BIC: %d\n', optimalOrder_BIC);




