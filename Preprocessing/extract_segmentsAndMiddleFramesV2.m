%% Gilad & Ronen 6th May 2018
%% Extracting 1 second segments and still frames from the pruned videos.
clear; clc;
%% Get table of segments
[list, listPath] = uigetfile('*.csv', 'Select ava_train or ava_test');
csvID = fopen([listPath, list]);
avaTrain = textscan(csvID,'%s %f %f %f %f %f %f', 'Delimiter', ',');
fclose(csvID);
trainTable = table(avaTrain{1}, avaTrain{2}, avaTrain{3}, avaTrain{4}, ...
    avaTrain{5}, avaTrain{6}, avaTrain{7}, ...
    'VariableName', {'videoID', 'middleFrameTimeStamp', 'topLeft_x',...
    'topLeft_y', 'bottomRight_x', 'bottomRight_y', 'actionLabel'});
%% Read videos:
