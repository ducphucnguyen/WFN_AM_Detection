function [T] = FFeature(x,Fs)
% This function is used to extract 13 spectral shape features
% x: sound pressure, Pa
% Fs: sampling frequency, Hz
% Implemented by Phuc NGUYEN May 2020
%==========================================================================

% Initial parameters
wlen = 0.125;       % ms, window length
overlap = 0.5;      % 50% overlaping

% Audio feature extractor set-up
aFE = audioFeatureExtractor('SpectralDescriptorInput','barkSpectrum');
aFE.Window = hamming(round(Fs*wlen),"periodic");
aFE.OverlapLength = round(Fs*wlen*overlap);
aFE.SampleRate = Fs;
aFE.SpectralDescriptorInput = 'barkSpectrum';


aFE.spectralCentroid = true;        % Feature 1
aFE.spectralCrest = true;           % Feature 2
aFE.spectralDecrease = true;        % Feature 3
aFE.spectralEntropy = true;         % Feature 4
aFE.spectralFlatness = true;        % Feature 5
aFE.spectralFlux = true;            % Feature 6
aFE.spectralKurtosis = true;        % Feature 7
aFE.spectralRolloffPoint = true;    % Feature 8
aFE.spectralSkewness = true;        % Feature 9
aFE.spectralSlope = true;           % Feature 10
aFE.spectralSpread = true;          % Feature 11
aFE.pitch = true;                   % Feature 12
aFE.harmonicRatio = true;           % Feature 13


features = extract(aFE,x);
idx = info(aFE);

% Calculate mean of windows
spectralCentroid = mean(features(:,idx.spectralCentroid));
spectralCrest = mean(features(:,idx.spectralCrest));
spectralDecrease = mean(features(:,idx.spectralDecrease));
spectralEntropy = mean(features(:,idx.spectralEntropy));
spectralFlatness = mean(features(:,idx.spectralFlatness));
spectralFlux = mean(features(:,idx.spectralFlux));
spectralKurtosis = mean(features(:,idx.spectralKurtosis));
spectralRolloffPoint = mean(features(:,idx.spectralRolloffPoint));
spectralSkewness = mean(features(:,idx.spectralSkewness));
spectralSlope = mean(features(:,idx.spectralSlope));
spectralSpread = mean(features(:,idx.spectralSpread));
pitch = mean(features(:,idx.pitch));
harmonicRatio = mean(features(:,idx.harmonicRatio));

% Write 13 features to table
T = table(spectralCentroid,spectralCrest,spectralDecrease,spectralEntropy,...
    spectralFlatness,spectralFlux,spectralKurtosis,...
    spectralRolloffPoint,spectralSkewness,spectralSlope,spectralSpread,...
    pitch,harmonicRatio);
end
