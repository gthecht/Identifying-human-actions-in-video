%% Gilad 17.11.17
% trying to extract the videos for training:
clear; clc;
csvID = fopen('ava_train_v1.0.csv');
avaTrain = textscan(csvID,'%s %f %f %f %f %f %f', 'Delimiter', ',');
fclose(csvID);
trainTable = table(avaTrain{1}, avaTrain{2}, 'VariableName', {'video_id', 'top-left x',...
    'top-left y', 'bottom-right x', 'bottom-right y', 'action-label'});