function [T] = SFeature(x,Fs)
% this function is used to extract overall noise features (14-17)
% T: table
% x: sound pressure, Pa
% Fs: sampling frequency, Hz
% Implemented by Phuc NGUYEN May 2020
%==========================================================================

% Sound pressure reference
pref = 20e-6;

% Design filters (A,C,G)
aWeight = weightingFilter('A-weighting','SampleRate',Fs); % A-weighting filter
cWeight = weightingFilter('C-weighting','SampleRate',Fs); % C-weighting filter

% Calculate SPL
LA = 20*log10(rms(aWeight(x))/pref);        % Feature 14
LC = 20*log10(rms(cWeight(x))/pref);
LG = 20*log10(rms(gWeight(x,Fs))/pref);

ratioLGLA = LG/LA;                          % Feature 15
ratioLCLA = LC/LA;                          % Feature 16
diffLCLA = LC-LA;                           % Feature 17

% save to table
T = table(LA,ratioLGLA,ratioLCLA,diffLCLA);

%% G-weighting filter
    function [xf] = gWeight(x,Fs)
        n = 8;
        y = downsample(x,n); % down sampling
        Fsd = round(Fs/n);
        
        %Analog G-weighting filter according to ISO 7196
        z = [0+0*1i; 0+0*1i; 0+0*1i; 0+0*1i];
        p = [2*pi*(-0.707 + 0.707*1i); 2*pi*(-0.707 - 0.707*1i); 2*pi*(-19.27 + 5.16*1i); 2*pi*(-19.27 - 5.16*1i);...
            2*pi*(-14.11 + 14.11*1i); 2*pi*(-14.11 - 14.11*1i); 2*pi*(-5.16 + 19.27*1i); 2*pi*(-5.16 - 19.27*1i)];
        
        k = 9.825e8;
        
        % Zero-pole to continuous tf conversion
        [bc,ac] = zp2tf(z,p,k);
        
        % Bilinear transformation of analog design to get the digital filter.
        [b,a] = bilinear(bc,ac,Fsd);
        xf = filter(b,a,y); % applying the filter to random noise
    end

end
