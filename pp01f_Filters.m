%% JXH-3089 
% Computational psychophysiology workshop

clear all; 

%% load the wave
% 1. check it is the correct one
load("myWorkingWave.mat","myWave","timeVec")


figure; clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
plot(timeVec,myWave)
xlabel('time [s]')
ylabel('µV')
ylim(max(abs(myWave(:)))*[-1 1]);
title('my wave')
set(gca,'FontSize',12)


%% use a low-pass filter to remove the fast trends
% (and enhance the slower frequencies)

d1 = designfilt("lowpassiir", FilterOrder=2, HalfPowerFrequency=10, SampleRate=mean(1./diff(timeVec)), DesignMethod='butter');

                
myWave_lowpass = filtfilt(d1, myWave);

yLimits = max(abs([myWave(:); myWave_lowpass(:)])) * [-1 1];


figure; clf
tldLayout = tiledlayout(2,1);
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
nexttile(tldLayout)
plot(timeVec,myWave);
xlabel('time [s]')
ylabel('µV')
title('original wave')
ylim(yLimits)
set(gca,'FontSize',12)

nexttile(tldLayout)
plot(timeVec,myWave_lowpass,'-','LineWidth',1.5);
title('low-pass filtered wave')
ylim(yLimits)
set(gca,'FontSize',12)


%% use a high-pass filter to remove the slow trends 
% (and enhance the faster frequencies)

d1 = designfilt("highpassiir", FilterOrder=2, HalfPowerFrequency=10, SampleRate=mean(1./diff(timeVec)), DesignMethod='butter');

                
myWave_highpass = filtfilt(d1, myWave);

yLimits = max(abs([myWave(:); myWave_highpass(:)])) * [-1 1];


figure; % clf
tldLayout = tiledlayout(2,1);
nexttile(tldLayout)
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
plot(timeVec,myWave);
xlabel('time [s]')
ylabel('µV')
title('original wave')
ylim(yLimits)
set(gca,'FontSize',12)

nexttile(tldLayout)
plot(timeVec,myWave_highpass,'-', 'LineWidth',0.5);
title('high-pass filtered wave')
ylim(yLimits)
set(gca,'FontSize',12)

