%% Gilad Hecht & Ronen Rahamim
% 29th June 2018
% Training the fully connected network that is the last stage of our
% classifier.
clear; clc;
warning('off', 'MATLAB:MKDIR:DirectoryExists');
%% Get training data
trainDir      = uigetdir([], 'choose FCTrainTables directory');
dirTrain      = struct2cell(dir(trainDir));
FCTablesFiles = dirTrain(1,:)';
FCTablesFiles = FCTablesFiles(contains(FCTablesFiles, '.mat')); % take only the files that are .mat files
% trainDSDir    = uigetdir([trainDir, '\..'], 'choose FCTrainDS'); % folder where we'll create the training datastore
% create the labelled directories in the datastore:
labelsCell    = {'bend-bow (at the waist)';'crawl';'crouch-kneel';'dance';...
                 'fall down';'get up';'jump-leap';'lie-sleep';'martial art';...
                 'run-jog';'sit';'stand';'swim';'walk'};
% for dirNum = 1 : length(labelsCell)
%     mkdir(trainDSDir, labelsCell{dirNum});
% end
%% Go video by video and put the images in an ordered training table:
vidNum = 0;
wb = waitbar(vidNum / length(FCTablesFiles), ['video # ', num2str(vidNum), ...
                                ' out of ', num2str(length(FCTablesFiles))]);
FCtrainMat = [];
trainTable = table([], [], [], 'VariableNames', ...
                        {'SegmentName', 'FCfeaturesVector', 'label'});
for vidNum = 1 : length(FCTablesFiles)
    waitbar(vidNum / length(FCTablesFiles), wb,  ['video # ', num2str(vidNum),...
                            ' out of ', num2str(length(FCTablesFiles))]);
    % load current FCTable:
    load([trainDir, '\', FCTablesFiles{vidNum}]); % name is FCTrainingTable
    vidID = strsplit(FCTablesFiles{vidNum}, '_');
    vidID = vidID{1};
    midTimes  = mat2cell(round(FCTrainingTable.Time(:,2)), ones(height(FCTrainingTable),1));
    segName   = cellfun(@(X) sprintf([vidID, '_t=%04d'], X), midTimes, 'UniformOutput', false);
    labelName = cellfun(@(X) labelsCell{X}, FCTrainingTable.label, 'UniformOutput', false);
    featVecs   = cell2mat(cellfun(@(X) reshape(X, [], 1), FCTrainingTable.FCfeaturesVector', 'UniformOutput', false));
    FCtrainMat = cat(2, FCtrainMat, featVecs);
%     trainTable = [trainTable ; [segName, FCTrainingTable.FCfeaturesVector, labelName]];
end
close(wb)
%% Get validation data
validDir      = uigetdir([], 'choose FCValidTables directory');
dirValid      = struct2cell(dir(validDir));
FCTablesFiles = dirValid(1,:)';
FCTablesFiles = FCTablesFiles(contains(FCTablesFiles, '.mat')); % take only the files that are .mat files
validDSDir    = uigetdir([validDir, '\..'], 'choose FCValidDS'); % folder where we'll create the training datastore
% create the labelled directories in the datastore:
labelsCell    = {'bend-bow (at the waist)';'crawl';'crouch-kneel';'dance';...
                 'fall down';'get up';'jump-leap';'lie-sleep';'martial art';...
                 'run-jog';'sit';'stand';'swim';'walk'};
for dirNum = 1 : length(labelsCell)
    mkdir(validDSDir, labelsCell{dirNum});
end
%% Go video by video and put the images in an ordered validation table:
vidNum = 0;
wb = waitbar(vidNum / length(FCTablesFiles), ['video # ', num2str(vidNum), ...
                                ' out of ', num2str(length(FCTablesFiles))]);
FCvalidMat = [];
validTable = table([], [], [], 'VariableNames', ...
                        {'SegmentName', 'FCfeaturesVector', 'label'});
for vidNum = 1 : length(FCTablesFiles)
    waitbar(vidNum / length(FCTablesFiles), wb,  ['video # ', num2str(vidNum),...
                            ' out of ', num2str(length(FCTablesFiles))]);
    % load current FCTable:
    load([validDir, '\', FCTablesFiles{vidNum}]); % name is FCTrainingTable
    vidID = strsplit(FCTablesFiles{vidNum}, '_');
    vidID = vidID{1};
    midTimes  = mat2cell(round(FCTrainingTable.Time(:,2)), ones(height(FCTrainingTable),1));
    segName   = cellfun(@(X) sprintf([vidID, '_t=%04d'], X), midTimes, 'UniformOutput', false);
    labelName = cellfun(@(X) labelsCell{X}, FCTrainingTable.label, 'UniformOutput', false);
    featVecs   = cell2mat(cellfun(@(X) reshape(X, [], 1), FCTrainingTable.FCfeaturesVector', 'UniformOutput', false));
    FCvalidMat = cat(2, FCtrainMat, featVecs);
%     validTable = [validTable ; [segName, FCTrainingTable.FCfeaturesVector, labelName]];
end
close(wb)
%% create Fully Connected Network
FCLayers = [fullyConnectedLayer(200)
         reluLayer
         fullyConnectedLayer(length(labelsCell))
         softmaxLayer
         classificationLayer
         ]
%% create training and validation dataStores:
% trainDirLen = length(trainDSDir) + 1;
% validDirLen = length(validDSDir) + 1;
% trainDS = fileDatastore(trainDSDir,'ReadFcn', @load, 'IncludeSubfolders', true);
% trainLabels = cellfun(@(X) labelsCell{contains(labelsCell, ...
%     X(trainDirLen + 1 : trainDirLen + 3))}, trainDS.Files, ...
%                                                 'UniformOutput', false);
% validDS = fileDatastore(trainDSDir,'ReadFcn', @load, 'IncludeSubfolders', true);
% validLabels = cellfun(@(X) labelsCell{contains(labelsCell, ...
%     X(validDirLen + 1 : validDirLen + 3))}, validDS.Files, ...
%                                                 'UniformOutput', false);
% trainMats = cellfun(@load, trainDS.Files, 'UniformOutput', false);
%% Train
options = trainingOptions('sgdm', ...
    'MaxEpochs',1, ...
    'Verbose',false, ...
    'Plots','training-progress');
ClassificationNet = trainNetwork(FCtrainMat, FCtrainLabels,FCLayers,options);
%% Test
%% Save