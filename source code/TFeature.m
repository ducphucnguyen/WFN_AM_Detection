function [T] = TFeature(x,Fs)
% this function is used to extract overall noise features (18-21); The code
% partly based on Nordtest NT ACOUT 112.
% T: table
% x: sound pressure, Pa
% Fs: sampling frequency, Hz
% Implemented by Phuc NGUYEN May 2020
% Modified: 7/5/2020
%==========================================================================

delta = 0.025; % second, fast-time weighting window
tav = 0.125; % second, averaging time

[LA25] = fast_SPL(x,Fs,delta,tav); % fast-time weighting tav second, overlap (tav-delta)
LA25m = movmean(LA25,floor(tav*delta*Fs)); % smooth signal SPL, 

div = diff(LA25m)/delta; % get slope of SPL
divm = movmean(div,round(tav*delta*Fs));  % smooth of slope signals

pos_slope = mean(divm((divm>0))); % mean positive slope (Feature #20)
neg_slope = mean(divm((divm<0))); % mean negative slope (Feature #21)

% Find the variation frequency and abitrary amplitude of the slope signals
freq_res = 0.05; % frequency resolution
Fsnew = 1/delta;
fftn = round(Fsnew/freq_res);
[PD,~] = pwelch(divm,hann(100),[],fftn,Fsnew,'psd');
[psor,lsor] = findpeaks(PD,1/freq_res,'SortStr','descend'); % find peak

% Get maximum peak
peakloc = lsor(1); % Feature #18
peakval = psor(1); % Feature #19

% save to table
T = table(peakloc,peakval,pos_slope,neg_slope);

% fast-time weighting function
    function [A_SPL2] = fast_SPL(y,Fs,delta,tav)
        A_wtn = aWeigting(y,Fs);
        Len = floor(tav*Fs); % define length of window
        movRMS = dsp.MovingRMS(Len); % moving rms object
        fast = movRMS(A_wtn); % calculate moving rms
        A_SPL = 20*log10(fast/(20e-6));
        A_SPL2 = A_SPL(floor(tav*Fs):floor(delta*Fs):length(y));
    end

% A-weiting function
function y_Aw = aWeigting(x,Fs)
% improve original A-weigting function with edge errors

R=0.05; % 5% of signal
Nx=size(x,1);
NR=round(Nx*R); 
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