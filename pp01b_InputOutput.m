%% JXH-3089 
% Computational psychophysiology workshop

clear all; 

%% identify the current folder 
% 1. outside of matlab, open the folder and see its content

currentFolder = pwd;
disp(currentFolder)

%% create a matrix of random numbers
% 1. save it somewhere on the hard drive
% 2. check its content

myMatrix = randn(5,5);

writematrix(myMatrix, fullfile(currentFolder, 'myRandomMatrix.csv')); % save as comma separated file that can be interpreted as table by Excel

save(fullfile(currentFolder, 'myRandomMatrix.mat'),"myMatrix"); % this saves an "m" file, MATLAB's native data file format

%% create a new matrix to load
% 1. matrix to edit in Excel
% 2. load it in MATLAB  

myOneMatrix = ones(5,5);

writematrix(myOneMatrix, fullfile(currentFolder, 'myOneMatrix.csv')); % save as comma separated file that can be interpreted as table by Excel

myNextMatrix = readmatrix(fullfile(currentFolder, 'myOneMatrix.csv'));



