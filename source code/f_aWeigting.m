function y_Aw = f_aWeigting(x,Fs)
% improve original A-weigting function with edge errors
R=0.05; % 5% of signal
Nx=size(x,1);
NR=round(Nx*R);

x1(:,1)=2*x(1)-flipud(x(2:NR+1));  % maintain continuity in level and slope
x2(:,1)=2*x(end)-flipud(x(end-NR:end-1));

x=[x1;x;x2];
% Do filtering
%HawfA = fdesign.audioweighting('WT,Class','A',1,Fs);
%Afilter = design(HawfA,'SystemObject',true);
%y_Aw = Afilter(x);
[y_Aw]= Afilter(x,Fs);
y_Aw=y_Aw(NR+1:end-NR,:);
end

function [y_Aw]= Afilter(x,Fs)
% A-weighting filter
f1 = 20.598997;
f2 = 107.65265;
f3 = 737.86223;
f4 = 12194.217;
A1000 = 1.9997;
NUM = [ (2*pi*f4)^2*(10^(A1000/20)) 0 0 0 0 ];
DEN = conv([1 +4*pi*f4 (2*pi*f4)^2],[1 +4*pi*f1 (2*pi*f1)^2]);
DEN = conv(conv(DEN,[1 2*pi*f3]),[1 2*pi*f2]);

%Bilinear transformation of analog design to get the digital filter.
[b,a] = bilinear(NUM,DEN,Fs);
y_Aw = filter(b,a,x);
end