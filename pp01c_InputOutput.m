% Learn Psychophysiology - Germano Gallicchio
% https://germanogallicchio.github.io/LearnPsychophysiology/
%
% This script shows how to save and load data files in MATLAB

clear all; clc;

%% Identify the current folder 
% pwd = "Print Working Directory" - shows where MATLAB is currently working

currentFolder = pwd;
disp('Current folder:')
disp(currentFolder)

% NOTE: You can also open this folder outside of MATLAB to see files

%% Create and save a matrix to disk

% Create a 5×5 matrix of random numbers
myMatrix = randn(5,5);

% Save as CSV (Comma-Separated Values) - can be opened in Excel
csvFile = fullfile(currentFolder, 'myRandomMatrix.csv');
writematrix(myMatrix, csvFile);
disp(['Saved CSV file: ' csvFile])

% Save as MAT (MATLAB's native format) - faster, preserves data types
matFile = fullfile(currentFolder, 'myRandomMatrix.mat');
save(matFile, "myMatrix");
disp(['Saved MAT file: ' matFile])

%% Load data from disk

% Load the CSV file
myMatrix_fromCSV = readmatrix(csvFile);
disp('Loaded from CSV:')
disp(myMatrix_fromCSV)

% Load the MAT file
load(matFile)  % This creates variable 'myMatrix' in workspace
disp('Loaded from MAT file:')
disp(myMatrix)

%% Understanding whos and size

% whos shows detailed information about variables
disp(' ')
disp('Variable information:')
whos myMatrix

% size shows just the dimensions
disp('Matrix dimensions:')
disp(['  Rows: ' num2str(size(myMatrix, 1))])
disp(['  Columns: ' num2str(size(myMatrix, 2))])

%% Practice: Create, save, and load your own matrix

% Create a 5×5 matrix of ones
myOneMatrix = ones(5,5);

% Save as CSV
writematrix(myOneMatrix, fullfile(currentFolder, 'myOneMatrix.csv'));

% Load it back
myNextMatrix = readmatrix(fullfile(currentFolder, 'myOneMatrix.csv'));

disp('Successfully saved and loaded matrix of ones!')
disp(myNextMatrix)



