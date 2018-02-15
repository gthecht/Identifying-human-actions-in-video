%% Ronen and Gilad 15.02.18
clear; clc;
%% loading train CSV:
load trainTable; % in: 'Identifying-human-actions-in-video' folder
load uniqueSegmentsIndex; % the indices of the unique segments in the trainTable
%% extract images :
% for now we only want the ones with a pose that is:
% stand = 12, sit = 11, walk = 14
labels = [11; 12; 14];
labelsName = {'sit'; 'stand'; 'walk'};
[isMemberTable,imNames, uniqNames] = extractImages(labels, trainTable);
%% Create frame dataset
FrameData = createFrameData();
%% get extract table:
existTable = createExistTable(imNames, uniqNames, labels, labelsName, isMemberTable, FrameData);
%% Divide into train and test
trainPercent = 0.8;
testPercent  = 0.2;
[trainTable,testTable, imgPerm] = train_test(FrameData, existTable, trainPercent, testPercent);

%% Load net:
layers = createNNlayers(labels);
%% train:
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-6, ...
    'MaxEpochs', 3, ...
    'CheckpointPath', tempdir);
tic
RCNNModl = trainRCNNObjectDetector(trainTable, layers, options)
disp('    --Finished training');
toc
%% test:
testOutcome = testRCNN(testTable, RCNNModl, FrameData, imgPerm);
