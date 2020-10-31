function [Output] = a1_AM_detection_10sec(y,Fs)
% a1_AM_detection is reproduced from the algorithm developed by the IOA UK
% AMWG. 2016. "A Method for Rating Amplitude Modulation in Wind Turbine Noise
% UK Institute of Acoustics".
% [Output] include [C,Fo_fundamental,AMdepth];
% C: prominence
% Fo_fundamental: fundamental modulation frequency (Hz)
% AMdepth: the depth of AM
% y: Sound pressure (Pa) which is band-pass filtered
% Fs: Sampling frequency (Hz)
% Example: [Ouput] = a1_AM_detection(y,Fs)
% Implemented by Duc Phuc Nguyen November 2019
%==========================================================================


%% Initial input parameters

minfo = 0.4; maxfo = 0.9; % blade pass frequency range
prominence_cutoff = 0.5; % extract all Prominence ratio greater than 0.5
Output = [];

%% Check the input sample size
if length (y)~= Fs*10
    error('The audiofile must be 10 seconds')
end

%% Calculate LAfast
% A-weighted filter
y_Aw = aWeigting(y,Fs);

% Fast-time weighting SPL 100ms
y_fast = blockproc(y_Aw,[floor((1/10)*Fs)+1 1],@(s)rms(s.data(:)));
LAfast = 20*log10(y_fast/(20e-6));

SPL_detrend = detrend(LAfast,3); % 3rd order polynomial

%% Calculate power spectrum (PS)

x = SPL_detrend;
Fs_spl = 10; % sampling frequency of fast-time weighting SPL
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psx = (1/(N^2)) * abs(xdft).^2;
psx(2:end-1) = 2*psx(2:end-1);
freq = Fs_spl*(0:(N/2))/N;
PS = psx; % calculate PS not PSD

%% Identification of fundamental frequency (fo)

[pks,locs] = findpeaks(PS,Fs_spl);
locs_valid = find(locs>=minfo & locs<=maxfo);

if ~isempty(locs_valid)
    pks_fo = pks(locs_valid);
else
    disp('Relevant peaks have not been found')
    return
end

%% C2-Prominence check
A = max(pks_fo);
loc_A = find(PS==A);
B = mean(PS([loc_A-3 loc_A-2 loc_A+2 loc_A+3]));
C = A/B;

if C >= prominence_cutoff
    %disp('Valid 10sec period')
else
    %disp('Invalid 10sec period, not pass C2-prominence check')
    return
end

% Identify locations of Nth harmonic (N=2 and 3)
fo_harmonics = [2*freq(loc_A) 3*freq(loc_A)];

% Calculate AMdepth for fundamental signal
xdft_A([loc_A-1 loc_A loc_A+1]) = xdft([loc_A-1 loc_A loc_A+1]);
A_fundamental = ifft(xdft_A,N,'symmetric');
A_C3 = max(A_fundamental) - min(A_fundamental);

loc_B = [];
loc_C = [];

if A_C3>1.5
    %% C3-Determine whether 1st & 2nd harmonics need to be included
    
    p = 10^-9; % tolerance
    
    % check 1st harmonic frequecy
    f2 = fo_harmonics(1);
    if min(abs((locs-f2)))<p % harmonic is in the same location local peak
        loc_B = find(freq>f2-p & freq<f2+p);
    else
        z = find(abs(locs-f2)<=0.1+p);
        [~,q]=find(freq==locs(z));
        [~,loq] = max(PS(q));
        loc_B = q(loq);
    end
    
    
    if ~isempty(loc_B) % check if 1st harmonic available
        xdft_B([loc_B-1 loc_B loc_B+1]) = xdft([loc_B-1 loc_B loc_B+1]);
        B_fundamental = ifft(xdft_B,N,'symmetric');
        B_C3 = max(B_fundamental) - min(B_fundamental);
        
        if B_C3 > 1.5
            %disp('Include 1st harmonic frequencies')
        else
            loc_B = [];
        end
    end
    
    % check 2nd harmonic frequency
    f3 = fo_harmonics(2);
    
    if min(abs((locs-f3)))<p % harmonic is in the same location local peak
        loc_C = find(freq>f3-p & freq<f3+p);
    else
        z = find(abs(locs-f3)<=0.2+p);
        
        [~,q]=find(freq==locs(z));
        [~,loq] = max(PS(q));
        loc_C = q(loq);
    end
    
    if ~isempty(loc_C)
        xdft_C([loc_C-1 loc_C loc_C+1]) = xdft([loc_C-1 loc_C loc_C+1]);
        C_fundamental = ifft(xdft_C,N,'symmetric');
        C_C3 = max(C_fundamental) - min(C_fundamental);
        
        if C_C3 > 1.5
            %disp('Include 2nd harmonic frequencies')
        else
            loc_C = [];
        end
    end
end

%% Final recreate filtered 10sec time series (F)
loc_final = [loc_A-1 loc_A loc_A+1 loc_B-1 loc_B loc_B+1 loc_C-1 loc_C loc_C+1];
xdft_final(loc_final) = xdft(loc_final);
F = ifft(xdft_final,N,'symmetric');

AMdepth = prctile_linear(F,0.95)- prctile_linear(F,0.05); % the depth of AM
Fo_fundamental = double(freq(loc_A)); % fundamental frequency

%% write results
Output = table(C,Fo_fundamental,AMdepth);

%% Functions
% function calculate prctile using linear interpolation
    function V_x = prctile_linear(F,p)
        V = sort(F,'ascend');
        Nf = length(V);
        xf = p*(Nf-1)+1; % position x
        V_x = V(floor(xf)) + mod(xf,1)*(V(floor(xf)+1) - V(floor(xf)));
    end

% A-weighting function
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