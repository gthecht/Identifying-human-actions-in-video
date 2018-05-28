%% Ronen and Gilad 15.02.18
% Training network to find people in images!
% This is without labels.
clear; clc;
%% Choose labels and label Names:
labels = 1:14;
labelsName = {'person'};
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
    'Plots','training-progress', ...
    'CheckpointPath', tempdir);
tic
RCNNModl = trainFasterRCNNObjectDetector(trainTable, layers, options, ...
    'NegativeOverlapRange', [0 0.3], ...
    'PositiveOverlapRange', [0.7,1], 'NumStrongestRegions', 2000)
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
% filePath  = [direcPath, '\', 'tempSave'];
filePath  = 'D:\OneDrive\OneDrive - Technion\Courses\Project2\DataOutput\PeopleDetectorV2\Alex2Epochs';
saveVars = {'bbox','confTable', 'existTable', 'FrameData', 'imgPerm', ...
    'label', 'labels', 'labelsName', 'layers', 'nTest', 'options', ...
    'outTable', 'RCNNModl', 'score', 'testOutcome', 'trainTable'};
% saved     = save2Temp(fileName, filePath, saveVars);
saveName = [filePath, '\', fileName, '_', date];
save(saveName, saveVars);
done = 1;
