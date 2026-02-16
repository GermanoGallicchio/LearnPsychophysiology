% Learn Psychophysiology - Germano Gallicchio
% https://germanogallicchio.github.io/LearnPsychophysiology/
%
% This script introduces advanced data structures needed for working with
% psychophysiological data: multi-dimensional arrays, structures, and cells

clear all; clc;

%% Working with Multi-Dimensional Arrays (3D and beyond)

% Psychophysiological data is often stored in 3D arrays with structure:
% [channels × time points × trials]
% For example: [2 channels × 100 time points × 5 trials]

% Create example 3D data (2 channels, 100 time points, 5 trials)
data3D = randn(2, 100, 5);

% Check the size of each dimension
disp('Size of 3D array:')
disp(['  Dimension 1 (channels): ' num2str(size(data3D, 1))])
disp(['  Dimension 2 (time): ' num2str(size(data3D, 2))])  
disp(['  Dimension 3 (trials): ' num2str(size(data3D, 3))])


%% The Colon Operator (:) - Accessing Entire Dimensions

% The colon : means "all elements" in that dimension

% Extract ALL time points from channel 1, trial 3
% Read as: data3D(channel 1, all time points, trial 3)
singleTrial = data3D(1, :, 3);

%% Let's plot the data for that channel and trial

% Visualize the difference
figure('Name', 'data3D: all time points from a channel and a trial')
plot(singleTrial)  % Need to index [1,:,1] because it's 3D


% let's improve this figure by adding axis labels, grid, and title
% xlabel('time')
% ylabel('arbitrary units')
% grid on

%% Practice: Extracting Different Slices from 3D Data

% Extract all trials for channel 2 at time point 50
% data3D(channel, time, trial) → data3D(2, 50, :)
allTrials_oneTimepoint = squeeze(data3D(2, 50, :));
disp(' ')
disp('All trials at one time point:')
disp(['  Size: ' num2str(size(allTrials_oneTimepoint))])

% Extract all time points from channel 1 for all trials
% This gives us a 2D matrix: [time × trials]
allData_channel1 = squeeze(data3D(1, :, :));
disp(' ')
disp('All data from channel 1:')
disp(['  Size: ' num2str(size(allData_channel1))])

%% The (:) Operator for Reshaping to Column Vectors

% Many MATLAB functions expect column vectors
% The (:) operator forces any array into a column vector

rowVec = [1, 2, 3, 4, 5];  % Row vector: commas separate elements
colVec = [1; 2; 3; 4; 5];  % Column vector: semicolons separate elements

disp(' ')
disp('Row vector created with commas:')
disp(['  Size: ' num2str(size(rowVec))])  % [1 × 5]

disp('Column vector created with semicolons:')
disp(['  Size: ' num2str(size(colVec))])  % [5 × 1]

% Convert row to column using (:)
rowVec_as_column = rowVec(:);
disp('Row vector converted to column with (:):')
disp(['  Size: ' num2str(size(rowVec_as_column))])  % [5 × 1]

%% Structure Arrays for Grouping Related Parameters

% Instead of managing many separate variables:
threshold = 10;
windowSize = 50;
algorithmName = 'velocity';

% Use a STRUCTURE to group related settings together:
settings = struct();  % Create empty structure
settings.threshold = 10;
settings.windowSize = 50;
settings.name = 'velocity';

% Access fields with dot notation:
disp(' ')
disp('Settings structure:')
disp(['  Algorithm: ' settings.name])
disp(['  Threshold: ' num2str(settings.threshold)])
disp(['  Window size: ' num2str(settings.windowSize)])

% You can also create structures directly:
params = struct('threshold', 20, 'type', 'dispersion', 'plotResults', true);

% Check what fields a structure has:
disp(' ')
disp('Fields in params structure:')
disp(fieldnames(params))

%% Cell Arrays for Mixed Data Types

% Regular arrays can only hold ONE data type
% Cell arrays can hold DIFFERENT data types

% Create a cell array with curly braces {}
mixedData = {42, 'Hello', [1,2,3], true, rand(2,2)};

% Access elements with curly braces {}
disp(' ')
disp('Cell array contents:')
disp(['  Element 1 (number): ' num2str(mixedData{1})])
disp(['  Element 2 (string): ' mixedData{2}])
disp(['  Element 3 (array): [' num2str(mixedData{3}) ']'])

% Practical example: Channel labels
channelNames = {'Horizontal EOG', 'Vertical EOG', 'Heart Rate'};

disp(' ')
disp('Channel labels:')
for i = 1:length(channelNames)
    disp(['  Channel ' num2str(i) ': ' channelNames{i}])
end

%% Combining Structures and Cells - Real World Example

% This is how psychophysiology data is often organized:
experimentData = struct();

% Metadata (mixed types) - use structure
experimentData.subjectID = 'S001';
experimentData.date = '2026-02-27';
experimentData.samplingRate = 1000;  % Hz

% Channel labels - use cell array
experimentData.channelLabels = {'Horizontal EOG', 'Vertical EOG'};

% Raw data - use 3D array
experimentData.rawData = randn(2, 1000, 10);  % 2 channels, 1000 samples, 10 trials

% Display the organized data
disp(' ')
disp('Experiment data structure:')
disp(experimentData)

% Access specific information
disp(' ')
disp('Accessing experiment information:')
disp(['  Subject: ' experimentData.subjectID])
disp(['  Sampling rate: ' num2str(experimentData.samplingRate) ' Hz'])
disp(['  Channel 1: ' experimentData.channelLabels{1}])
disp(['  Data dimensions: ' num2str(size(experimentData.rawData))])

%% Practice Exercise

disp(' ')
disp('=== PRACTICE EXERCISE ===')
disp('Try the following:')
disp('1. Extract trial 5 from channel 2 of experimentData.rawData')
disp('2. Create a structure called "mySettings" with your own parameters')
disp('3. Create a cell array with your name, age, and favorite numbers')
