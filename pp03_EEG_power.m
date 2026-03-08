% Learn Psychophysiology - Germano Gallicchio
% https://germanogallicchio.github.io/LearnPsychophysiology/
%
% This script demonstrates how to analyze band power from EEG data. EEG
% power describes the strength of oscillations for each frequency studied.

%% Initial settings

close all; clearvars; clear global; clc;

% Enter your ID code for figure watermarking
IDcode = input('Enter your ID code (e.g., 50012345678): ', 's');
if isempty(IDcode)
    IDcode = 'DEMO';  % Default for workshop demonstration
end

fprintf('using this ID code: %s \n', IDcode)

%% Import the EEG data 

% Download and save a local copy of the EEG data. Data accessible from the
% Open Science Framework: 
% - https://osf.io/k4ytm/files/vkwcu

% Specify where the data file has been located
fileLoc = '/media/germanog/Gallicchio_C/work/2019_Lboro_QEgolf/JXH3089/';
fileName = 'subj1_eeg.mat';

% Load the data file into MATLAB workspace
% This loads variables: eegVol (channels x time x trials), timeSec, chanLbl, trialVec, trialNum
dataPath = fullfile(fileLoc, fileName);
if ~exist(dataPath,'file')
	disp('Default EEG data file not found. Please select the EEG .mat file...')
	[fname, fpath] = uigetfile('*.mat','Select EEG data file');
	if isequal(fname,0)
		error('No file selected. Cannot proceed.')
	end
	dataPath = fullfile(fpath, fname);
end
load(dataPath)

% Display what we loaded to understand the data structure
disp('Data loaded. Variables in workspace:')
whos eegVol timeSec chanLbl trialVec trialNum

% Compute sampling rate (samples per second)
srate = 1/mean(diff(timeSec));
disp(['Sampling rate: ' num2str(srate) ' Hz'])

%% Understand the data structure

% eegVol is a 3D matrix with dimensions: [channels × time points × trials]
% Let's check its size
disp('Size of eegVol matrix:')
disp(['  Dimension 1 (channels): ' num2str(size(eegVol,1))])
disp(['  Dimension 2 (time points): ' num2str(size(eegVol,2))])
disp(['  Dimension 3 (trials): ' num2str(size(eegVol,3))])

%% The Prisma toolbox is used to extract EEG power from EEG signals
%
% Download the latest release (version unnamed-yet) from:
% - Germano Gallicchio. https://github.com/GermanoGallicchio/Prisma

% Add Prisma toolbox to MATLAB's search path
prismaPath = '/media/germanog/Gallicchio_C/work/functions/Prisma';
if exist(prismaPath,'dir')
	addpath(prismaPath);
	disp(['Added to path: ' prismaPath])
else
	disp('Prisma path not found. If you plan to run time-frequency analysis, download Prisma and add its folder to your MATLAB path.')
end

%% PART 1- Plot a single trial

% Select which trial to analyze 
trialIdx = 1;           % choose trial index
disp(['Analyzing trial number: ' num2str(trialIdx)])

% Select which channel 
chanIdx = 32;            % choose EEG channel (e.g., 32 = Cz, 16 = Oz)
disp(['Using channel: ' chanLbl{chanIdx}])

% Extract data for this single trial
% squeeze() removes dimensions of size 1, converting from 3D to 1D array
timeSeries = squeeze(eegVol(chanIdx, :, trialIdx));
disp(['Extracted time series size: ' num2str(size(timeSeries))])


figure('Name','EEG Single Trial')
plot(timeSec, timeSeries, 'LineWidth', 1.5)
hold on
line([0 0], ylim, 'Color', 'r', 'LineStyle', '--')  % movement onset at t=0
xlabel('Time (s)')
ylabel('EEG (uV)')
title([chanLbl{chanIdx} ', Trial ' num2str(trialIdx)])
grid on

%% Time-Frequency of a single trial

if ~exist('pr_STFT','file')
	error('Prisma function pr_STFT not found on path')
end

% Select which trial to analyze 
trialIdx = 1;           % choose trial index
disp(['Analyzing trial number: ' num2str(trialIdx)])

% Select which channel 
chanIdx = 32;            % choose EEG channel (e.g., 32 = Cz, 16 = Oz)
disp(['Using channel: ' chanLbl{chanIdx}])

% Extract data for this single trial
% squeeze() removes dimensions of size 1, converting from 3D to 1D array
timeSeries = squeeze(eegVol(chanIdx, :, trialIdx));
disp(['Extracted time series size: ' num2str(size(timeSeries))])

% Configure STFT for ~10 Hz focus (0.5 s window)
pr_cfg = struct();
pr_cfg.srate = srate;
pr_cfg.STFT_windowLength_pnt = round(0.5 * srate);
pr_cfg.STFT_windowStep_pnt   = round(0.1 * srate);
pr_cfg.STFT_zeroPadding      = 2;
pr_cfg.physicalAxis_vec = timeSec(:)';  % Provide physical axis to label window centers in seconds rather than points
pr_cfg.physicalAxis_units = 's';

pr_cfg.sanityCheck_text = false;
pr_cfg.sanityCheck_fig  = false;

% run STFT via Prisma
[spectra, pr_cfg] = pr_STFT(timeSeries, pr_cfg);

% pr_STFT returns spectra as [freq x windows x 2], where dim3 = [real, imag]
complex_spectra = complex(spectra(:,:,1), spectra(:,:,2));
amplitude = abs(complex_spectra);

% Convert to one-sided amplitude (do not double DC/Nyquist bins)
if size(amplitude,1) > 2
    amplitude(2:end-1, :) = amplitude(2:end-1, :) * 2;
end

power = amplitude.^2;

% get time-frequency axes from output
freq_axis = pr_cfg.STFT_freq_Hz;
time_axis = pr_cfg.physicalAxis_output;

% Visualize STFT results
figure(2); clf
set(gcf, 'Position', [150 50 1200 600]);
% spectrogram (raw amplitude in original units)
imagesc(time_axis, freq_axis, power);
axis xy; 
c = colorbar;
c.Label.String = 'power';
xlabel('Time (s)', 'FontSize', 12);
ylabel('Frequency (Hz)', 'FontSize', 12);
title('STFFT');
ylim([0 min(30, max(freq_axis))]);
grid on;

colormap(flipud(hot))

%% Extract feature of interest

% Select which trial to analyze 
trialIdx = 1;           % choose trial index
disp(['Analyzing trial number: ' num2str(trialIdx)])

% Select which channel 
chanIdx = 32;            % choose EEG channel (e.g., 32 = Cz, 16 = Oz)
disp(['Using channel: ' chanLbl{chanIdx}])

% Extract data for this single trial
% squeeze() removes dimensions of size 1, converting from 3D to 1D array
timeSeries = squeeze(eegVol(chanIdx, :, trialIdx));
disp(['Extracted time series size: ' num2str(size(timeSeries))])

% Select frequency of interest
F = 10;  % Hz, modify as appropriate

% Select time intervals of interest
T1 = [-4 -3]; % modify as appropriate
T2 = [ 0  1];   % modify as appropriate

% Use nearest frequency bin because exact equality is often not available
[~, fIdx] = min(abs(freq_axis - F));
t1Idx = time_axis >= T1(1) & time_axis <= T1(2);
t2Idx = time_axis >= T2(1) & time_axis <= T2(2);

tmp = power(fIdx, t1Idx);
power_10T1 = mean(tmp(:),'omitnan');
tmp = power(fIdx, t2Idx);
power_10T2 = mean(tmp(:),'omitnan');

% Percentage change from T1 to T2
percChange = (power_10T2 - power_10T1) ./ power_10T1 * 100;
disp(['Percentage change from T1 to T2 at ' num2str(freq_axis(fIdx), '%.2f') ' Hz: ' num2str(percChange)])

%% PART 2A: Multiple trials visualization
%% Figure: stack multiple trials vertically

% Select which trial to analyze 
trialsToShow = 1:5;     
disp(['Analyzing trial number: ' num2str(trialsToShow)])

% Select which channel 
chanIdx = 32;            % choose EEG channel (e.g., 32 = Cz, 16 = Oz)
disp(['Using channel: ' chanLbl{chanIdx}])


figure('Name','Multi-Trial EEG Data')
f = gcf; 
f.Units = 'normalized'; 
f.Position = [0 0 0.9 0.9];

% Track min/max of plotted values for tight axes
yMin = inf; 
yMax = -inf;


colorOrder = lines(length(trialsToShow));

% Loop through each trial to plot
for trialIdx = 1:length(trialsToShow)
	trialNum_current = trialsToShow(trialIdx);

    % Extract data for this trial
    xVec = timeSec;
    
    % Calculate vertical offset to stack waveforms
    % Each trial is shifted down by scaled mean range across trials
    vertOffset = -(trialIdx-1) * 4*range(mean(eegVol(chanIdx,:,:),3));
    
    % Create the y-values: original data + vertical offset
    yVec = vertOffset + squeeze(eegVol(chanIdx, :, trialNum_current));

    % Plot the waveform
	plot(xVec, yVec, 'Color', colorOrder(trialIdx,:))
	hold on
    
	% Track limits
	yMin = min(yMin, min(yVec));
	yMax = max(yMax, max(yVec));
    
	% Add trial number label next to each waveform
    colVec = lines;  % Get MATLAB's default color order
    text(xVec(1), vertOffset, num2str(trialNum_current), ...
        'HorizontalAlignment', 'right', ...
        'Color', colVec(mod(trialIdx-1, size(colVec,1))+1, :));
    
    % Add title when plotting last trial
    if trialIdx == length(trialsToShow)
        title([chanLbl{chanIdx} ' EEG - Multiple Trials'])
    end
end

% Format the plot
box off
ax = gca;
ax.YAxis.Visible = 'off';  % Hide y-axis (each trial has different scale)
ax.XLabel.String = 'Time (s)';
ax.XGrid = "on";

% Add y-axis scale bar
scaleLength = 50;  % microvolts
scalePos_x = [xVec(end)+0.25, xVec(end)+0.25];
scalePos_y = [0, -scaleLength];
line(scalePos_x, scalePos_y, 'LineWidth', 2, 'Color', 'k')
text(scalePos_x(1)+0.1, mean(scalePos_y), [num2str(scaleLength) 'µV'], ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'Rotation',90)

% Set axis limits to fit data tightly
yMargin = (yMax - yMin) * 0.01;  % 1% margin
set(ax, 'YLim', [yMin-yMargin, yMax+yMargin])
set(ax, 'XLim', [xVec(1)-0.1, xVec(end)+0.5])

% Add vertical line at movement onset (time = 0)
line([0 0], ylim, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5)

% Add ID code watermark
text(0.02, 0.98, ['ID: ' IDcode], 'Units', 'normalized', ...
    'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', ...
    'FontSize', 8, 'Color', [0.5 0.5 0.5], 'FontWeight', 'normal');


%% Analyze MULTIPLE trials at once

% Select which trials to analyze (e.g., first 5 trials, or all trials)
trialIndices = 1:5;  % Change to analyze subset of trials if needed
disp(['Analyzing ' num2str(length(trialIndices)) ' trials for power extraction'])

% Select which channel 
chanIdx = 32;            % choose EEG channel (e.g., 32 = Cz, 16 = Oz)
disp(['Using channel: ' chanLbl{chanIdx}])

% Feature settings (same as single-trial section)
F = 10;           % Hz, modify as appropriate
T1 = [-4 -3];     % baseline interval
T2 = [ 0  1];     % task interval

% Store power values for each trial at the selected frequency
power_allTrials = nan(length(trialIndices), 1);

% Compute power for specified frequency and time intervals across all trials
for trialIdx = 1:length(trialIndices)
    % Extract single trial EEG
    timeSeries = squeeze(eegVol(chanIdx, :, trialIndices(trialIdx)));
    
    % Run STFT via Prisma
    pr_cfg_trial = struct();
    pr_cfg_trial.srate = srate;
    pr_cfg_trial.STFT_windowLength_pnt = round(0.5 * srate);
    pr_cfg_trial.STFT_windowStep_pnt   = round(0.1 * srate);
    pr_cfg_trial.STFT_zeroPadding      = 2;
    pr_cfg_trial.physicalAxis_vec = timeSec(:)';
    pr_cfg_trial.physicalAxis_units = 's';
    pr_cfg_trial.sanityCheck_text = false;
    pr_cfg_trial.sanityCheck_fig  = false;
    
    [spectra, pr_cfg_trial] = pr_STFT(timeSeries, pr_cfg_trial);
    
    % Extract power from pr_STFT output [freq x windows x 2]
    complex_spectra = complex(spectra(:,:,1), spectra(:,:,2));
    amplitude = abs(complex_spectra);

    % Convert to one-sided amplitude (do not double DC/Nyquist bins)
    if size(amplitude,1) > 2
        amplitude(2:end-1, :) = amplitude(2:end-1, :) * 2;
    end

    power_trial = amplitude.^2;
    
    % Get frequency and time axes
    freq_axis_trial = pr_cfg_trial.STFT_freq_Hz;
    time_axis_trial = pr_cfg_trial.physicalAxis_output;
    
    % Find closest frequency index to F
    [~, fIdx] = min(abs(freq_axis_trial - F));
    
    % Extract power values for time intervals
    t1Idx = time_axis_trial >= T1(1) & time_axis_trial <= T1(2);
    t2Idx = time_axis_trial >= T2(1) & time_axis_trial <= T2(2);

    if ~any(t1Idx) || ~any(t2Idx)
        warning('Trial %d skipped: selected time windows fall outside STFT output axis.', trialIndices(trialIdx));
        continue;
    end
    
    power_t1 = mean(power_trial(fIdx, t1Idx), 'omitnan');
    power_t2 = mean(power_trial(fIdx, t2Idx), 'omitnan');

    % Store the power change
    power_allTrials(trialIdx) = (power_t2 - power_t1) / power_t1 * 100;

    if trialIdx==1
        fprintf('computing STFT over trials: ')
    end
    fprintf('%d ', trialIndices(trialIdx))
end

disp(' ')
disp('Multi-trial analysis complete')

%% Compute descriptive statistics across trials

fprintf('\n')
disp('Descriptive Statistics:')

% Power change statistics
meanPowerChange = mean(power_allTrials, 'omitnan');
stdPowerChange = std(power_allTrials, 'omitnan');
fprintf('Power percentage change from the first to the second window:\nMean = %.2f %%, SD = %.2f %%\n', meanPowerChange, stdPowerChange)

% Additional statistics
minPowerChange = min(power_allTrials, [], 'omitnan');
maxPowerChange = max(power_allTrials, [], 'omitnan');
fprintf('Power change range: Min = %.2f %%, Max = %.2f %%\n', minPowerChange, maxPowerChange)

%% Save results

% Create a results table with trial information and power metrics
resultsTable = table();
resultsTable.TrialNumber = trialIndices(:);
resultsTable.PowerChange_Percent = power_allTrials(:);

% Display the table
disp(resultsTable)

% Save to CSV file for easy import into report
resultsFile = 'EEG_Power_Results.csv';
writetable(resultsTable, resultsFile);
disp(['Results saved to: ' fullfile(pwd, resultsFile)])

disp(' ')
disp('Analysis complete!')

%% REFLECTIONS

% Think critically about:
%
% - What frequency bands are most relevant for your research question?
% Alpha (8-12 Hz), Beta (12-30 Hz), Theta (4-8 Hz), Delta (0.5-4 Hz)?
%
% - What do alpha power increases/decreases suggest about brain activity?
% Increased power may indicate different cognitive states or fatigue
%
% - How might muscle artifact affect the EEG signal?
% Higher frequencies can pick up muscle activity (EMG contamination)
%
% - Are the results consistent across trials and channels?
% Check multiple electrode locations and temporal consistency
