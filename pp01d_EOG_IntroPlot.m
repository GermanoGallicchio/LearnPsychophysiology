% Learn Psychophysiology - Germano Gallicchio
% https://germanogallicchio.github.io/LearnPsychophysiology/
%
% pp01d_EOG_IntroPlot.m
% Goal: Load EOG data and plot a single trial and a small set of trials.
% This bridges from pp01c (I/O) to pp02 (QE analysis) with minimal steps.

clear all; clc; close all;

%% Import EOG data file
fileName = 'subj1_eog.mat';
dataFolder = uigetdir(pwd, 'Select the folder containing the EOG data');
if isequal(dataFolder, 0)
    error('No folder selected. Cannot proceed.')
end

dataPath = fullfile(dataFolder, fileName);
if ~exist(dataPath,'file')
    disp(['File not found in selected folder: ' fileName])
    disp('Please select the EOG .mat file directly...')
    [fname, fpath] = uigetfile('*.mat','Select EOG data file');
    if isequal(fname,0)
        error('No file selected. Cannot proceed.')
    end
    dataPath = fullfile(fpath, fname);
end
load(dataPath)

% Data variables typically available:
% eogDeg [channels x time x trials], timeSec [time points],
% chanLbl {channel labels}, trialVec [trial numbers], trialNum [count]
whos eogDeg timeSec chanLbl trialVec trialNum

%% Compute sampling rate
% how many data points per second?
srate = 1/mean(diff(timeSec));
disp(['Sampling rate: ' num2str(srate) ' Hz'])

% is this sampling rate high enough for this type of data?

%% SINGLE TRIAL PLOT (horizontal EOG, first trial)
chanIdx = 1;            % 1 = horizontal EOG
trialIdx = 1;           % first trial

% Extract single trial time series (squeeze removes singleton dims)
eogDeg_oneSeries = eogDeg(chanIdx, :, trialIdx);

figure('Name','Single Trial EOG')
plot(timeSec, eogDeg_oneSeries, 'LineWidth', 1.5)
hold on
line([0 0], ylim, 'Color', 'r', 'LineStyle', '--')  % movement onset at t=0
xlabel('Time (s)')
ylabel('EOG (deg)')
title(['Single Trial: ' chanLbl{chanIdx} ', Trial ' num2str(trialIdx)])
grid on

%% MULTI-TRIAL PLOT (stack a few trials vertically)
trialsToShow = 1:5;     % keep small to stay quick

figure('Name','Stacked EOG Trials')
f = gcf; f.Units = 'normalized'; f.Position = [0 0 1 1];

% Track min/max of plotted values for tight axes
yMin = inf; yMax = -inf;
colorOrder = lines(length(trialsToShow));

for i = 1:length(trialsToShow)
    tIdx = trialsToShow(i);
    xVec = timeVector;
    
    % Vertical offset: half-range of this trial, multiplied by index
    trialRange = range(eogDeg(chanIdx, :, tIdx));
    vertOffset = -(i-1) * trialRange / 2;
    
    yVec = vertOffset + squeeze(eogDeg(chanIdx, :, tIdx));
    plot(xVec, yVec, 'Color', colorOrder(i,:))
    hold on
    
    % Track limits
    yMin = min(yMin, min(yVec));
    yMax = max(yMax, max(yVec));
    
    % Label each stacked waveform with trial number
    text(xVec(1), vertOffset, num2str(trialVec(tIdx)), 'HorizontalAlignment','right', 'Color', colorOrder(i,:));
end

box off
ax = gca; ax.YAxis.Visible = 'off'; ax.XGrid = 'on';
ax.XLabel.String = 'Time (s)';

% Add vertical line at movement onset (t=0)
line([0 0], [yMin yMax], 'Color', 'r', 'LineStyle', '--')

% Tight axis limits with small margin
yMargin = (yMax - yMin) * 0.02;
set(ax, 'YLim', [yMin - yMargin, yMax + yMargin])
set(ax, 'XLim', [xVec(1)-0.1, xVec(end)+0.5])

title([chanLbl{chanIdx} ' EOG - Stacked Trials'])

disp('pp01d_EOG_IntroPlot complete.')