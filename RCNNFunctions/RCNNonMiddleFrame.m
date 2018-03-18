%% Ronen and Gilad 15.02.18
clear; clc;
%% loading train CSV:
load trainTable; % in: 'Identifying-human-actions-in-video' folder
load uniqueSegmentsIndex; % the indices of the unique segments in the trainTable
%% extract images :
% for now we only want the ones with a pose that is:
% stand = 12, sit = 11, walk = 14
labels = [11; 12];
labelsName = {'sit'; 'stand'};
[isMemberTable,imNames, uniqNames] = extractImages(labels, trainTable);
%% Create frame dataset
FrameData = createFrameData(); % Creates the frameData - an image dataframe with the middle frames in it.
%% get exist table:
% creates the table of all the images in the loaded data, that has boxes
% with the specific labels in it, and fixes the boxes for Training.
existTable = createExistTable(imNames, uniqNames, labels, labelsName, isMemberTable, FrameData);
%% Divide into train and test
% divides into train and test sets according to the percents. Also shows
% some images from the test, with the boxes in them to see that it came out
% well.
trainPercent = 0.8;
testPercent  = 0.2;
[trainTable,testTable, imgPerm] = train_test(FrameData, existTable, trainPercent, testPercent);

%% Load net:
% currently loading existing net, and preparing it for the right number of
% categories:
layers = createNNlayers(labels);
%% train:
% Creat specific options, and trin network to data:
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-6, ...
    'MaxEpochs', 3, ...
    'CheckpointPath', tempdir);
tic
RCNNModl = trainFasterRCNNObjectDetector(trainTable, layers, options, 'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange', [0.7,1])
disp('    --finished training');
toc
%% test:
% Test success ratio and look it detected boxes:
testOutcome = testRCNN(testTable, RCNNModl, FrameData, imgPerm, labelsName);
% % lets say for now that we only checked the imgPerm ones:
% testOutcome = testOutcome(imgPerm,:);
% % Now we want to estimate a score. The idea is to check if the labels are
% % correct, and if so, find the IOU (Intersection Over Union) of every label
% % and add up (normalizing by the number of images tested).
[testScore, outTable] = calcRCNNScore(testTable, testOutcome, labelsName);




