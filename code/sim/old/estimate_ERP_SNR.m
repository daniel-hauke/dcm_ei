function [estimated_SNR, SNR_conditions] = estimate_ERP_SNR_multi(ERP, baseline_window)
    % Estimates the SNR for each condition separately and computes the average SNR.
    %
    % Inputs:
    % - ERP: 3D matrix (samples x EEG channels x conditions)
    % - baseline_window: indices of time points corresponding to baseline period
    %
    % Outputs:
    % - estimated_SNR: computed average SNR across conditions (in dB)
    % - SNR_conditions: vector of SNR estimates for each condition separately

    [numSamples, numChannels, numConditions] = size(ERP);
    SNR_conditions = zeros(numConditions, 1);

    for cond = 1:numConditions
        % Compute signal power (variance across all time points per channel)
        signal_power = mean(var(ERP(:, :, cond), 0, 1), 'all');

        % Compute noise power (variance within baseline period per channel)
        noise_power = mean(var(ERP(baseline_window, :, cond), 0, 1), 'all');

        % Compute SNR in dB
        SNR_conditions(cond) = 10 * log10(signal_power / noise_power);
    end

    % Compute the average SNR across all conditions
    estimated_SNR = mean(SNR_conditions);

    fprintf('Estimated average ERP SNR across conditions: %.2f dB\n', estimated_SNR);
    fprintf('SNR for each condition:\n');
    disp(SNR_conditions);
end

% Example usage:
% ERP = randn(1000, 60, 5);  % Replace with actual ERP signal matrix (samples x channels x conditions)
% baseline_window = 1:50;  % Example: First 50 time points