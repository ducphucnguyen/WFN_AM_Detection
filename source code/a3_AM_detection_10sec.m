function DAM = a3_AM_detection_10sec(y,Fs)
% a3_AM_detection using DAM method proposed by Fukushima et al. (2013)
% DAM: the depth of AM (dBA)
% y: sound pressure (Pa).
% Fs: sampling frequency (Hz)
% Example: DAM = a3_AM_detection_10sec(y,8192)
% Implemented by Duc Phuc Nguyen November 2019

%% Check the input sample size
if length (y)~= Fs*10
    error('The audiofile must be 10 seconds')
end
%% Preprocess analysis

% Consider SPL between [20-1000Hz] 1/3-octave bands
y = filter_band(y,17.8,1122,Fs);

% Apply A-weighting filter
y_Aw = aWeigting(y,Fs);

% Fast-time weighting SPL 100ms
y_fast = blockproc(y_Aw,[floor((1/10)*Fs)+1 1],@(s)rms(s.data(:)));
SPL_fast = 20*log10(y_fast/(20e-6));

% Slow-time weighting SPL 1s
y_slow = blockproc(y_Aw,[floor((1/1)*Fs)+1 1],@(s)rms(s.data(:)));
SPL_slow = 20*log10(y_slow/(20e-6));

% 1-D data interpolation
t_fast = (1:length(SPL_fast))*0.1;
t_slow = (1:length(SPL_slow))*1-0.5;

trend = interp1(t_slow,SPL_slow,t_fast,'pchip');

% Detrended SPL
SPL_detrend = SPL_fast-trend';

% plot(t_fast,SPL_fast,'LineWidth',2.5); hold on
% plot(t_fast,SPL_fast2,'--','LineWidth',2.5)
% legend('blockproc','Kristy function')
% xlabel('time,s')
% ylabel('SPL, dBA')
% xlim([0 10])

%% Calculate DAM

DAM = prctile_linear(SPL_detrend,0.95)- prctile_linear(SPL_detrend,0.05);

%% function calculate prctile using linear interpolation
    function V_x = prctile_linear(F,p)
        V = sort(F,'ascend');
        N = length(V);
        x = p*(N-1)+1; % position x
        V_x = V(floor(x)) + mod(x,1)*(V(floor(x)+1) - V(floor(x)));
    end
%% bandpass filter function
    function y = filter_band(x,fl,fu,Fs)
        [B,A] = butter(3,[fl/(Fs/2) fu/(Fs/2)]);
        R=0.05; % 10% of signal
        N=size(x,1);
        NR=round(N*R); % At most 50 points
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




