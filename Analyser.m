clc; % Clear command window
clear; % Delete all variables
clearvars; % Clear variables from previous runs
fprintf('Running Analyser.m...\n'); % Send running message to command window
workspace; % Show workspace
close all;	% Close all figure windows
imtool close all;  % Close all imtool figures

% Check that the Image Processing Toolbox is installed
hasIPT = license('test', 'image_toolbox');
if ~hasIPT
	% Toolbox not installed
	message = sprintf('Image Processing Toolbox has not been detected.\nPlease install the toolbox before continuing.');
end