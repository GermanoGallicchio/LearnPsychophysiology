%% JXH-3089 
% Computational psychophysiology workshop

clear all; 

%% let's create a sine wave of a certain frequency, amplitude, and phase offset
% 1. plot
% 2. observe how changes in frequency, amplitude, and phase offset change the wave

Fs = 500;  % sampling frequency 
Fn = Fs/2; % Nyquist frequency
Ts = 1/Fs; % reverse of sampling frequency
timeVec = 0:Ts:5;  timeVec(end) = [];
N = length(timeVec);

f = 2; % frequency 
A = 3; % amplitude 
phi = 0; % phase shift vector

myWave = A*sin(2*pi*f.*timeVec+phi);

figure(1);
plot(timeVec,myWave)
xlabel('time [s]')
ylabel('voltage [µV]')
set(gca,'YLim',10*[-1 1])
grid on
title(['frequency = ' num2str(f) ' Hz'])
hold on

%% create multiple waves

fF = [ 4  9  24.87]; % fundamental frequency vector
A = [3 2 1]; % amplitude vector
phi = [0 pi/2 pi*0.9]; % phase shift vector
nWaves = length(fF);
Fs = 500; % sampling frequency 
Fn = Fs/2; % Nyquist frequency
Ts = 1/Fs; % reverse of sampling frequency
timeVec = 0:Ts:5;  timeVec(end) = [];
N = length(timeVec);

%% fixed amplitude and phase shift // different frequency

waves = nan(nWaves,N);
for wIdx = 1:nWaves
    waves(wIdx,:)  = A(1)*sin(2*pi*fF(wIdx).*timeVec+phi(1));
end

figure(1); clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
nrow = nWaves; 
ncol = 1;
td = tiledlayout(nrow,ncol);
td.Padding = 'tight';
td.TileSpacing = 'loose';
for wIdx = 1:nWaves
    nexttile(td)
    plot(timeVec,waves(wIdx,:))
    xlabel('time [s]')
    ylabel('voltage [µV]')
    title(['frequency = ' num2str(fF(wIdx)) ' Hz'])
    set(gca,'FontSize',12)
end
sgtitle('varying frequency')

%% fixed amplitude and frequency // different phase shift

waves = nan(nWaves,N);
for wIdx = 1:nWaves
    waves(wIdx,:)  = A(1)*sin(2*pi*fF(1).*timeVec+phi(wIdx));
end

figure(1); clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
nrow = nWaves; 
ncol = 1;
td = tiledlayout(nrow,ncol);
td.Padding = 'tight';
td.TileSpacing = 'loose';
for wIdx = 1:nWaves
    nexttile(td)
    plot(timeVec,waves(wIdx,:))
    xlabel('time [s]')
    ylabel('voltage [µV]')
    title(['phase shift = ' num2str(phi(wIdx)) ' rad'])
    set(gca,'FontSize',12)
end
sgtitle('varying phase shift')

%% fixed phase shift and frequency // different amplitude

waves = nan(nWaves,N);
for wIdx = 1:nWaves
    waves(wIdx,:)  = A(wIdx)*sin(2*pi*fF(1).*timeVec+phi(1));
end

figure(1); clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
nrow = nWaves; 
ncol = 1;
td = tiledlayout(nrow,ncol);
td.Padding = 'tight';
td.TileSpacing = 'loose';
for wIdx = 1:nWaves
    nexttile(td)
    plot(timeVec,waves(wIdx,:))
    xlabel('time [s]')
    ylabel('voltage [µV]')
    ylim(max(A)*[-1 1]);
    yticks(-1*max(A) : 1 : 1*max(A));
    title(['amplitude = ' num2str(A(wIdx)) ' µV'])
    set(gca,'FontSize',12)
end
sgtitle('varying amplitude')

%% let's sum waves pointwise

waves = nan(nWaves,N);
for wIdx = 1:nWaves
    waves(wIdx,:)  = A(wIdx)*sin(2*pi*fF(wIdx).*timeVec+phi(wIdx));
end
waves(nWaves+1,:) = sum(waves,1);

figure(1); clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
nrow = nWaves+1; 
ncol = 1;
td = tiledlayout(nrow,ncol);
td.Padding = 'tight';
td.TileSpacing = 'loose';
for wIdx = 1:nWaves+1
    nexttile(td)
    plot(timeVec,waves(wIdx,:))
    %xlabel('time [s]')
    ylabel('µV')
    ylim(max(waves(:))*[-1 1]);
    if wIdx==nWaves+1
        title('sum of waves')
    end
    set(gca,'FontSize',12)
end


%% let's add noise

% generate noise
alpha = [0 -1 2];
multip = [0 2 1]; % noise multiplier
wavesN = nan(length(alpha),N);
for wIdx = 1:length(alpha)
    cn = dsp.ColoredNoise(Color='custom', SamplesPerFrame=N, InverseFrequencyPower=alpha(wIdx));
    noiseOut = cn();
    wavesN(wIdx,:) = waves(end,:)+multip(wIdx)*noiseOut()';
end


figure(1); clf
f = gcf; f.Units = 'normalized'; f.Position = [0.01 0.1 0.8 0.7];
nrow = size(wavesN,1); 
ncol = 1;
td = tiledlayout(nrow,ncol);
td.Padding = 'tight';
td.TileSpacing = 'loose';
for wIdx = 1:size(wavesN,1)
    nexttile(td)
    plot(timeVec,wavesN(wIdx,:))
    %xlabel('time [s]')
    ylabel('µV')
    ylim(max(abs(wavesN(:)))*[-1 1]);
    if wIdx==nWaves+1
        title('sum of waves')
    end
    set(gca,'FontSize',12)
end

%% save the last wave

myWave = wavesN(end,:);

save('myWorkingWave',"myWave", "timeVec")

