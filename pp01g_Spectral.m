%% JXH-3089 
% Computational psychophysiology workshop

clear all; 

%% load the wave
% 1. check it is the correct one
load("myWorkingWave.mat","myWave","timeVec")

figure(1); clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
nexttile()
plot(timeVec,myWave)
xlabel('time [s]')
ylabel('µV')
ylim(max(abs(myWave(:)))*[-1 1]);
title('my wave''s in time domain')
set(gca,'FontSize',12)

%% what if I want to know what frequencies are naturally included in my signal?
% we can use something called Fourier Transform

Fs = mean(1./diff(timeVec)); % sampling frequency 
Fn = Fs/2; % Nyquist frequency
N = length(timeVec);
freqVec = Fs/N*(0:N-1);   % for fourier

clear myWave_X
myWave_X   = fft(myWave)'/N;  

figure(1); %clf
nexttile()
stem(freqVec,abs(myWave_X)*2)
set(gca,'XLim',[0 40])
xlabel('frequency [Hz]')
ylabel('µV')
title('my wave''s in frequency domain')
set(gca,'FontSize',12)