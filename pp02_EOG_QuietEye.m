% Learn Psychophysiology - Germano Gallicchio
% https://germanogallicchio.github.io/LearnPsychophysiology/
%
% This script demonstrates how to analyze Quiet Eye (QE) periods from 
% electrooculography (EOG) data. QE is the final fixation before a 
% critical movement in sports performance.
%
% To know more you can read: Gallicchio, G., Ryu, D., Krishnani, M.,
% Tasker, G. L., Pecunioso, A., & Jackson, R. C. (2024). Temporal and
% spectral electrooculographic features in a discrete precision task.
% Psychophysiology, 61(3), e14461.

%% Initial settings

close all; clearvars; clear global; clc;

% Enter your ID code for figure watermarking
IDcode = input('Enter your ID code (e.g., 50012345678): ', 's');
if isempty(IDcode)
    IDcode = 'DEMO';  % Default for workshop demonstration
end

fprintf('using this ID code: %s \n', IDcode)

%% Import the EOG data 

% Download and save a local copy of the EOG data. Data accessible from the
% Open Science Framework: 
% - https://osf.io/k4ytm/files/vkwcu

% Specify where the data file has been located
fileLoc = '/media/germanog/Gallicchio_C/work/2019_Lboro_QEgolf/JXH3089/';
fileName = 'subj1_eog.mat';

% Load the data file into MATLAB workspace
% This loads variables: eogDeg, timeSec, chanLbl, trialVec, trialNum
dataPath = fullfile(fileLoc, fileName);
if ~exist(dataPath,'file')
    disp('Default EOG data file not found. Please select the EOG .mat file...')
    [fname, fpath] = uigetfile('*.mat','Select EOG data file');
    if isequal(fname,0)
        error('No file selected. Cannot proceed.')
    end
    dataPath = fullfile(fpath, fname);
end
load(dataPath)

% Display what we loaded to understand the data structure
disp('Data loaded. Variables in workspace:')
whos eogDeg timeSec chanLbl trialVec trialNum

% Compute sampling rate (samples per second)
% diff() calculates differences between consecutive time points
% mean() averages these differences (should all be the same)
% 1/mean() converts from seconds per sample to samples per second
srate = 1/mean(diff(timeSec));
disp(['Sampling rate: ' num2str(srate) ' Hz'])

%% Add folder: Quiet-Eye-EOG (toolbox)

% The QE_EOG function analyzes eye movement data to detect quiet eye periods
%
% Download the latest release (version v1.1.0) from:
% - Germano Gallicchio. (2023). GermanoGallicchio/Quiet-Eye-EOG: v1.0 (v1.0). 
% Zenodo. https://doi.org/10.5281/zenodo.8411092
%   or
% - Germano Gallicchio. https://github.com/GermanoGallicchio/Quiet-Eye-EOG

% Add the QE_EOG function to MATLAB's search path
addOnPath = '/media/germanog/Gallicchio_C/work/functions/Quiet-Eye-EOG';
if exist(addOnPath,'dir')
    addpath(addOnPath);
    disp(['Added to path: ' addOnPath])
else
    warning('QE_EOG toolbox path not found. Please add the folder to your MATLAB path or download it from GitHub/Zenodo.')
end

%% Understand the data structure

% eogDeg is a 3D matrix with dimensions: [channels × time points × trials]
% Let's check its size
disp('Size of eogDeg matrix:')
disp(['  Dimension 1 (channels): ' num2str(size(eogDeg,1))])
disp(['  Dimension 2 (time points): ' num2str(size(eogDeg,2))])
disp(['  Dimension 3 (trials): ' num2str(size(eogDeg,3))])

%% PART 1: Analyze a SINGLE trial first (simpler to understand)

% Select which trial to analyze 
trialIdx = 1; % start with trial 1
disp(['Analyzing trial number: ' num2str(trialIdx)])

% Select which channel 
chanIdx = 1; % 1 = horizontal EOG
disp(['Using channel: ' chanLbl{chanIdx}])

% Extract data for this single trial
% squeeze() removes dimensions of size 1, converting from 3D to 1D array
timeSeries = squeeze(eogDeg(chanIdx, :, trialIdx));
disp(['Extracted time series size: ' num2str(size(timeSeries))])

% The time vector is the same for all trials
timeVector = timeSec(:); % (:) ensures it's a column vector
disp(['Time vector size: ' num2str(size(timeVector))])

%% Visualize the single trial

figure('Name', 'Single Trial EOG Data')
plot(timeVector, timeSeries, 'LineWidth', 1.5)
xlabel('Time (s)')
ylabel('EOG (degrees)')
title(['Trial ' num2str(trialIdx) ' - ' chanLbl{chanIdx}])
grid on
% Add a vertical line at time = 0 (movement initiation)
hold on
line([0 0], ylim, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
legend('EOG signal', 'Movement onset')

%% Apply median filter to visualize smoothing

% When using the dispersion algorithm, the QE_EOG function internally
% applies a median filter .Let's demonstrate this filtering step explicitly

% Define the filter window length (must be odd)
medianFilterLength_sec = 0.25; % 250 ms window
medianFilterLength_pnt = round(medianFilterLength_sec * srate)-1;  
if mod(medianFilterLength_pnt, 2) == 0
    medianFilterLength_pnt = medianFilterLength_pnt - 1;  % Make it odd
end

% Apply median filter to smooth the signal
timeSeries_filtered = movmedian(timeSeries, medianFilterLength_pnt);

figure('Name', 'Effect of Median Filter')
plot(timeVector, timeSeries, 'Color', [0.7 0.7 0.7], 'LineWidth', 1)
hold on
plot(timeVector, timeSeries_filtered, 'b', 'LineWidth', 1.5)
line([0 0], ylim, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
xlabel('Time (s)')
ylabel('EOG (degrees)')
title(['Median Filtering (window = ' num2str(medianFilterLength_sec) ' s)'])
legend('Raw signal', 'Median filtered', 'Movement onset')
grid on

disp(' ')
disp('Median filter applied for visualization.')
disp(['Filter window length: ' num2str(medianFilterLength_sec, '%.3f') ' s (' num2str(medianFilterLength_pnt) ' samples)'])

%% Apply QE_EOG function to the single trial

% Set up the algorithm parameters
% dispersion
% algorithmChoice.name = 'dispersion';  % Algorithm type: 'velocity' or 'dispersion'
% algorithmChoice.winlen = round(0.25 * srate) - 1;  % Filter window length in samples
% algorithmChoice.threshold = 3;  % Threshold in degrees (or use 'auto')
% velocity
algorithmChoice.name = 'velocity';  % Algorithm type: 'velocity' or 'dispersion'
algorithmChoice.winlen = 767;        % Savitzky-Golay frame length (samples)
algorithmChoice.polynDeg = 5;        % Savitzky-Golay polynomial
algorithmChoice.threshold = 33;  % Threshold in degrees (or use 'auto')

% Run the QE detection function
% Inputs: time series data, time vector, parameters, show plot?
[QEonset_single, QEoffset_single] = QE_EOG(timeSeries, timeVector, algorithmChoice, true);

% Display the results
disp(' ')
disp('Single trial results:')
disp(['  QE onset: ' num2str(QEonset_single, '%.3f') ' s'])
disp(['  QE offset: ' num2str(QEoffset_single, '%.3f') ' s'])
disp(['  QE duration: ' num2str(QEoffset_single - QEonset_single, '%.3f') ' s'])

%% PART 2: Analyze MULTIPLE trials (all trials at once)

% Select which trials to analyze (e.g., first 5 trials, or all trials)
trialIndices = 1:trialNum;  % Change to 1:trialNum to analyze all trials
disp(['Analyzing ' num2str(length(trialIndices)) ' trials'])

% Extract data for multiple trials
% This creates a 2D matrix: [time points × number of trials]
timeSeries_multi = squeeze(eogDeg(chanIdx, :, trialIndices));
disp(['Extracted multi-trial data size: ' num2str(size(timeSeries_multi))])

% The QE_EOG function can handle multiple trials automatically
% It will return vectors of onset and offset times (one per trial)
[QEonset_multi, QEoffset_multi] = QE_EOG(timeSeries_multi, timeVector, algorithmChoice, false);

% Display results for all trials
disp(' ')
disp('Multi-trial results:')
for trialIdx = 1:length(trialIndices)
    QEduration = QEoffset_multi(trialIdx) - QEonset_multi(trialIdx);
    fprintf('  Trial %d: Onset=%.3f s, Offset=%.3f s, Duration=%.3f s\n', ...
        trialIndices(trialIdx), QEonset_multi(trialIdx), QEoffset_multi(trialIdx), QEduration)
end

%% Compute descriptive statistics across trials

QEdurations_multi = QEoffset_multi - QEonset_multi;

fprintf('\n')
disp('Descriptive Statistics:')

% QE onset statistics
meanQEonset = mean(QEonset_multi);
stdQEonset = std(QEonset_multi);
fprintf('QE onset:    Mean = %.2f s, SD = %.2f s\n', meanQEonset, stdQEonset)

% QE offset statistics  
meanQEoffset = mean(QEoffset_multi);
stdQEoffset = std(QEoffset_multi);
fprintf('QE offset:   Mean = %.2f s, SD = %.2f s\n', meanQEoffset, stdQEoffset)

% QE duration statistics
meanQEduration = mean(QEdurations_multi);
stdQEduration = std(QEdurations_multi);
fprintf('QE duration: Mean = %.2f s, SD = %.2f s\n', meanQEduration, stdQEduration)

%% Visualize waveforms for all analyzed trials

figure('Name', 'Multi-Trial EOG Data')
f = gcf;
f.Units = 'normalized'; 
f.Position = [0 0 1 1];  % Full screen

% Track min/max of plotted data for axis limits
yMin = inf;
yMax = -inf;

% Loop through each trial to plot
for trialIdx = 1:length(trialIndices)
    trialNum_current = trialIndices(trialIdx);
    
    % Extract data for this trial
    xVec = timeVector;
    
    % Calculate vertical offset to stack waveforms
    % Each trial is shifted down by the mean range across trials
    vertOffset = -(trialIdx-1) * range(mean(eogDeg(chanIdx,:,:),3));
    

    % Create the y-values: original data + vertical offset
    yVec = vertOffset + squeeze(eogDeg(chanIdx, :, trialNum_current));
    
    % Add patch area representing the QE period (from onset to offset)
    if trialIdx <= length(QEonset_multi)
        qe_onset = QEonset_multi(trialIdx);
        qe_offset = QEoffset_multi(trialIdx);
        
        % Define patch vertices: rectangle from QE onset to QE offset
        % with vertical extent from min to max of the waveform
        buffer = 0.1*range(yVec);
        patch_xvals = [qe_onset; qe_offset; qe_offset; qe_onset];
        patch_yvals = [buffer; buffer; -buffer; -buffer] +vertOffset;

        
        
        % Plot the patch with semi-transparent fill
        patch(patch_xvals, patch_yvals, [1 1 0], 'FaceAlpha', 0.8, 'EdgeColor', 'none')
    end
    hold on

    % Plot the waveform
    plot(xVec, yVec)
    hold on
    
    % Track min/max for axis limits
    yMin = min(yMin, min(yVec));
    yMax = max(yMax, max(yVec));
    
    % Add trial number label next to each waveform
    colVec = lines;  % Get MATLAB's default color order
    text(xVec(1), vertOffset, num2str(trialNum_current), ...
        'HorizontalAlignment', 'right', ...
        'Color', colVec(mod(trialIdx-1, size(colVec,1))+1, :));
    
    % Add title when plotting last trial
    if trialIdx == length(trialIndices)
        title([chanLbl{chanIdx} ' EOG - All Trials'])
    end
end

% Format the plot
box off
ax = gca;
ax.YAxis.Visible = 'off';  % Hide y-axis (each trial has different scale)
ax.XLabel.String = 'Time (s)';
ax.XGrid = "on";

% Add y-axis scale bar
scaleLength = 50;  % degrees
scalePos_x = [xVec(end)+0.25, xVec(end)+0.25];
scalePos_y = [0, -scaleLength];
line(scalePos_x, scalePos_y, 'LineWidth', 2, 'Color', 'k')
text(scalePos_x(1)+0.1, mean(scalePos_y), [num2str(scaleLength) '°'], ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')

% Set axis limits to fit data tightly
yMargin = (yMax - yMin) * 0.01;  % 1% margin
set(ax, 'YLim', [yMin-yMargin, yMax+yMargin])
set(ax, 'XLim', [xVec(1)-0.1, xVec(end)+0.5])

% Add vertical line at movement onset (time = 0)
line([0 0], ylim, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5)

% Add ID code watermark
text(0.02, 0.98, ['ID: ' IDcode], 'Units', 'normalized', ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
    'FontSize', 8, 'Color', [0.5 0.5 0.5], 'FontWeight', 'normal');

disp(' ')
disp('Analysis complete!')

%% Save results

% Create a results table with trial information and QE metrics
resultsTable = table();
resultsTable.TrialNumber = trialIndices(:);
resultsTable.QE_Onset_s = QEonset_multi(:);
resultsTable.QE_Offset_s = QEoffset_multi(:);
resultsTable.QE_Duration_s = QEdurations_multi(:);

% Display the table
disp(resultsTable)

% Save to CSV file for easy import into report
resultsFile = 'EOG_QE_Results.csv';
writetable(resultsTable, resultsFile);
disp(['Results saved to: ' fullfile(pwd, resultsFile)])

%% REFLECTIONS 

% Think critically about:
%
% - How was the threshold determined? 
% Try various thresholds (check paper mentioned at the start)
%
% - How different are the results obtained when using the dispersion and
% the velocity algorithms?
% Do the same computations but use the velocity threshold
%
% - What assumptions does the algorithm make about eye movement?
% It assumes movements beyond threshold are "not quiet". But is always valid?
%
% - How might head movements affect the EOG signal?
% EOG measures eye position relative to head, not relative to world
%
% - What does a longer QE duration suggest about the golfer's performance?
% Quiet Eye literature links QE to expertise and performance
%
% - If QE duration was very short (e.g., 0.2s), what might that indicate?
% Rushed preparation? Lack of focus? Different strategy?