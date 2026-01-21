%% JXH-3089 
% Computational psychophysiology workshop

clear all; 

%% load the wave
% 1. check it is the correct one
load("myWorkingWave.mat","myWave","timeVec")


figure(1); clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
plot(timeVec,myWave)
xlabel('time [s]')
ylabel('µV')
ylim(max(abs(myWave(:)))*[-1 1]);
title('my wave')
set(gca,'FontSize',12)




%% use a low-pass filter to remove the fast trends
% (and enhance the slower frequencies)


d1 = designfilt("lowpassiir", FilterOrder=2, HalfPowerFrequency=1, SampleRate=mean(1./diff(timeVec)), DesignMethod='butter');

                
myWave_lowpass = filtfilt(d1, myWave);


figure(1); clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
nexttile()
plot(timeVec,myWave);
xlabel('time [s]')
ylabel('µV')
ylim(max(abs(myWave(:)))*[-1 1]);
title('my wave')
set(gca,'FontSize',12)

hold on
plot(timeVec,myWave_lowpass,'-','LineWidth',1.5);

legend(["original wave" "low-pass filtered wave"])

%% use a high-pass filter to remove the slow trends 
% (and enhance the faster frequencies)
% this "straightens" the wave

d1 = designfilt("highpassiir", FilterOrder=2, HalfPowerFrequency=1, SampleRate=mean(1./diff(timeVec)), DesignMethod='butter');

                
myWave_highpass = filtfilt(d1, myWave);


figure(1); % clf
nexttile()
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
plot(timeVec,myWave);
xlabel('time [s]')
ylabel('µV')
ylim(max(abs(myWave(:)))*[-1 1]);
title('my wave')
set(gca,'FontSize',12)

hold on
plot(timeVec,myWave_highpass,'-');

legend(["original wave" "high-pass filtered wave"])