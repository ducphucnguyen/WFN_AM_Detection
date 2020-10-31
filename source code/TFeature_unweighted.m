function T = TFeature_unweighted(x,Fs)
% this function is used to extract overall noise features (22-27); 
% all calculattions are based on unweighted signals
% x: sound pressure, Pa
% Fs: sampling frequency, Hz
% Implemented by Phuc NGUYEN May 2020
%==========================================================================

tav = 0.1; % second, averaging time

%% fast-time unweighted SPL,100ms
fast = blockproc(x,[floor((tav)*Fs)+1 1],@(s)rms(s.data(:)));
Lfast = 20*log10(fast/(20e-6));

% Find the variation frequency using FFT
Fs_SPL = floor(1/tav);
Y = fft(Lfast);
L = length(Lfast);
f = Fs_SPL*(0:(L/2))/L;
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
[~,lsor] = findpeaks(P1,Fs_SPL,'SortStr','descend'); % find peak

% Get maximum peak
peakloc = lsor(1); % Feature #22
%% Initial parameter for octave band filter design
BW = '1 octave'; % use 1 octave
Nb = 8;
F0 = 1000;
oneOctaveFilter = octaveFilter('FilterOrder',Nb, ...
    'CenterFrequency',F0,'Bandwidth',BW,'SampleRate',Fs);
F0 = getANSICenterFrequencies(oneOctaveFilter);
F0(F0<50) = []; % use center frequency greater than 50 Hz
F0(F0>1e3) = []; % and lower than 1kHz
Nfc = length(F0);

% Design one octave filter
for i = 1:Nfc
    oneOctaveFilterBank{i} = octaveFilter('FilterOrder',Nb, ...
        'CenterFrequency',F0(i),'Bandwidth',BW,'SampleRate',Fs);%#ok
end

% Appy to signals
for i = 1:Nfc
    oneOctaveFilter = oneOctaveFilterBank{i};
    yw(:,i) = oneOctaveFilter(x);
end


% Calculate fast time weighting for all band signals
fast = blockproc(yw,[floor((tav)*Fs)+1 1],@(s)rms(s.data(:)));
unweightedSPL = 20*log10(fast/(20e-6));

% Create template for table
sz = [1 6];
varTypes = {'double','double','double','double','double','double'};
varNames = {'peakloc_unweightedSPL','L63','L125','L250','L500','L1000'};
T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

k=2;
for i=1:5
    DAM = prctile(unweightedSPL(:,i),95)-prctile(unweightedSPL(:,i),5);
    T(1,k) = {DAM}; % Feature # 27 to 23
    k=k+1;
end

T.peakloc_unweightedSPL = peakloc;
end