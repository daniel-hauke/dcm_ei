
function [avg_order, ar_coeffs, simulated_noise] = estimate_ar_noise(residuals, maxOrder)
    % Estimate the average AR order and coefficients across multiple channels
    % and generate simulated noise.
    %
    % Inputs:
    % - residuals: matrix of time points x channels (observed residuals)
    % - maxOrder: maximum AR order to test
    %
    % Outputs:
    % - avg_order: estimated average AR order across channels
    % - ar_coeffs: AR coefficients for each channel
    % - simulated_noise: synthesized noise matrix with same dimensions as residuals

    [numSamples, numChannels] = size(residuals);
    BIC = zeros(numChannels, maxOrder);
    best_orders = zeros(numChannels, 1);
    ar_coeffs = cell(numChannels, 1);
    simulated_noise = zeros(numSamples, numChannels);

    % Estimate AR order and coefficients for each channel
    for ch = 1:numChannels
        for p = 1:maxOrder
            [coeffs, var] = arburg(residuals(:, ch), p);
            numParams = p + 1; 
            BIC(ch, p) = numParams * log(numSamples) + numSamples * log(var);
        end
        % Select the optimal AR order
        [~, best_orders(ch)] = min(BIC(ch, :));
        ar_coeffs{ch} = arburg(residuals(:, ch), best_orders(ch));

        % Generate simulated noise using the estimated AR model
        simulated_noise(:, ch) = filter([0; -ar_coeffs{ch}(2:end)'], 1, randn(numSamples, 1));
    end

    % Compute the average AR order across channels
    avg_order = round(mean(best_orders));

    fprintf('Estimated average AR order: %d\n', avg_order);


% Example usage:
% residuals = randn(1000, 60);  % Replace with actual residuals
% maxOrder = 10;
% [avg_order, ar_coeffs, simulated_noise] = estimate_ar_noise(residuals, maxOrder);

end