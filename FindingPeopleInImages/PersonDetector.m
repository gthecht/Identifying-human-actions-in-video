%% Ronen and Gilad 15.02.18
% Training network to find people in images!
% This is without labels.
clear; clc;
%% loading train CSV:
load trainTable; % in: 'Identifying-human-actions-in-video' folder
load uniqueSegmentsIndex; % the indices of the unique segments in the trainTable
%% extract images :
% We willo take all the boxes with poses. THe idea is that we want all the
% people, but most boxes have more than one label. We think every box has
% one pose only.

labels = 1:14;
labelsName = {'person'};
[isMemberTable,imNames, uniqNames] = extractImages(labels, trainTable); % This doesn't change
%% Create frame dataset
FrameData = createFrameData(); % Creates the frameData - an image dataframe with the middle frames in it.
%% get exist table:
% creates the table of all the images in the loaded data, that has boxes
% with the specific labels in it, and fixes the boxes for Training.
existTable = createExistTablePeople(imNames, uniqNames, labels, isMemberTable, FrameData);
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
layers = createNNlayers(labelsName);
%% train:
% Creat specific options, and trin network to data:
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-6, ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 128, ... % 32 works with RCNN, maybe 128 will also work
    'CheckpointPath', tempdir);
tic
RCNNModl = trainFasterRCNNObjectDetector(trainTable, layers, options, 'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange', [0.7,1])
disp('    --finished training');
toc
%% test:
% Test success ratio and look it detected boxes:
nTest = length(testTable.names);
bbox  = cell(nTest,1);
score = cell(nTest,1);
label = cell(nTest,1);
startIndx = 1;
testOutcome = testRCNN(testTable, RCNNModl, FrameData, imgPerm, labelsName, ...
    bbox, score, label, nTest, startIndx);
% Now we want to estimate a score. The idea is to check if the labels are
% correct, and if so, find the IOU (Intersection Over Union) of every label
% and add up (normalizing by the number of images tested).
[confTable, testScore, outTable] = calcRCNNScore(testTable, testOutcome, labelsName);

%% Save to temp file:
fileName  = 'PersonDetectorWorkspace';
path      = mfilename('fullpath');
splitPath = strsplit(path, '\');
direcPath = strjoin(splitPath(1:end-1), '\');
filePath  = [direcPath, '\', 'tempSave'];
saveVars = {'bbox','confTable', 'existTable', 'FrameData', 'imgPerm', ...
    'label', 'labels', 'labelsName', 'layers', 'nTest', 'options', ...
    'outTable', 'RCNNModl', 'score', 'testOutcome', 'trainTable'};
% saved     = save2Temp(fileName, filePath, saveVars);

