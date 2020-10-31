function [Output] = a2_AM_detection_10sec(y,Fs)
% a2_AM_detection using Lundmark method (2011); Larson et al. (2014)
% Output: [binary classification(1/0), fundamental frequency (Hz) and
% AMfactor].
% y: sound pressure (Pa)
% Fs: sampling frequency (Hz)
% We made several modifications to the original method:
%   1, using integration time 100ms
%   2, SPL calculated from 20 to 1000Hz 1/3-octave band
%   3, sample length is 10 seconds
%   4, SPL are detrened before calculating FFT
% Example: [Output] = a2_AM_detection(y,8192)
% Implemented by Duc Phuc Nguyen November 2019
%----------------------------------------------
%% Preprocess analysis

% Bandpass filter 1/3-octave band center [20-1000Hz]
y = filter_band(y,17.8,1122,Fs);

% A-weighted filter and edge effects
y_Aw = aWeigting(y,Fs);

% Fast-time weighting SPL 100ms
y_fast = blockproc(y_Aw,[floor((1/10)*Fs)+1 1],@(s)rms(s.data(:)));
SPL_fast = 20*log10(y_fast/(20e-6));

% detrend using 3rd order
SPL_detrend = detrend(SPL_fast,3);
%plot(SPL_fast,'--')
%% Amplitude modulation spectra (AMS)
Fs_spl = 10; % sampling frequency of fast-time weighting SPL
x = SPL_detrend;

N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
AMS = sqrt(2) * abs(xdft)/N;
freq = Fs_spl*(0:(N/2))/N;

%% AM factor calculation

index = find(freq>= 0.6 & freq<=1);
[AMfactor,loc] = max(AMS(index));
Fo_fundamental = freq(index(loc));

% Valid AM sample
if AMfactor>=0.4
    Valid = 1;
else
    Valid = 0;
end

% save output
Output = table(Valid,Fo_fundamental,AMfactor);

%% bandpass filter function
    function y = filter_band(x,fl,fu,Fs)
        [B,A] = butter(3,[fl/(Fs/2) fu/(Fs/2)]);
        R=0.05; % 10% of signal
        Ns=size(x,1);
        NR=round(Ns*R); % At most 50 points
        for i=1:size(x,2)
            x1(:,i)=2*x(1,i)-flipud(x(2:NR+1,i));  % maintain continuity in level and slope
            x2(:,i)=2*x(end,i)-flipud(x(end-NR:end-1,i));
        end
        x=[x1;x;x2];
        y = filter(B,A,x);
        y=y(NR+1:end-NR,:);
    end
%% edge effects and A weigting filter function
    function y_Aw = aWeigting(x,Fs)
        % improve original A-weigting function with edge errors
        
        R=0.05; % 5% of signal
        Nx=size(x,1);
        NR=round(Nx*R); % At most 50 points
        for i=1:size(x,2)
            x1(:,i)=2*x(1,i)-flipud(x(2:NR+1,i));  % maintain continuity in level and slope
            x2(:,i)=2*x(end,i)-flipud(x(end-NR:end-1,i));
        end
        x=[x1;x;x2];
        % Do filtering
        HawfA = fdesign.audioweighting('WT,Class','A',1,Fs);
        Afilter = design(HawfA,'SystemObject',true);
        y_Aw = Afilter(x);
        y_Aw=y_Aw(NR+1:end-NR,:);
    end
end