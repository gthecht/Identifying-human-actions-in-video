%% Ronen and Gilad 30.05.18
% Running CNN on the labeled boxes of the middle-frames, in order to get a
% vector to push into the RNN at the end.
clear; clc;
%% Choose labels and label Names: We'll begin with poses
labels = 1:14;
labelsName = {'bend/bow', 'crawl', 'crouch/kneel', 'dance', 'fall_down', ...
    'get_up', 'jump/leap', 'lie/sleep', 'martial_art', 'run/jog', 'sit', ...
    'stand', 'swim', 'walk'};
%% loading train CSV, and test CSV:
[trainTable,testTable, FrameData, imgPerm] = PreTrainingdata(labels);
%% Load net:
% currently loading existing net, and preparing it for the right number of
% categories:
layers = createNNlayers(labelsName);
%% train:
% Creat specific options, and trin network to data:
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-6, ...
    'MaxEpochs', 2, ...
    'MiniBatchSize', 128, ... % 32 works with RCNN, maybe 128 will also work
    'Verbose', true, ...
    'VerboseFrequency', 320, ...
    'Plots','training-progress', ...
    'CheckpointPath', tempdir);
tic
CNNModl = trainNetwork(trainTable, layers, options)
disp('    --finished training');
toc
%% test:
% Test success ratio and look it detected boxes:
nTest = length(testTable.names);
bbox  = cell(nTest,1);
score = cell(nTest,1);
label = cell(nTest,1);
startIndx = 1;
testOutcome = testRCNN(testTable, CNNModl, FrameData, imgPerm, labelsName, ...
    bbox, score, label, nTest, startIndx);
% Now we want to estimate a score. The idea is to check if the labels are
% correct, and if so, find the IOU (Intersection Over Union) of every label
% and add up (normalizing by the number of images tested).
[confTable, testScore, outTable] = calcRCNNScore(testTable, testOutcome, labelsName);

%% Save to temp file:
fileName  = 'CnnBoxesDetectorWorkspace';
path      = mfilename('fullpath');
splitPath = strsplit(path, '\');
direcPath = strjoin(splitPath(1:end-1), '\');
filePath  = [direcPath, '\', 'tempSave'];
saveVars = {'bbox','confTable', 'existTable', 'FrameData', 'imgPerm', ...
    'label', 'labels', 'labelsName', 'layers', 'nTest', 'options', ...
    'outTable', 'RCNNModl', 'score', 'testOutcome', 'trainTable'};
saved     = save2Temp(fileName, filePath, saveVars);

