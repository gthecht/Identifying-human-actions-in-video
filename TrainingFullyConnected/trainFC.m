%% Gilad Hecht & Ronen Rahamim
% 29th June 2018
% Training the fully connected network that is the last stage of our
% classifier.
clear; clc;
warning('off', 'MATLAB:MKDIR:DirectoryExists');
%% Pick directories:
trainDir      = uigetdir([], 'choose FCTrainTables directory');
validDir      = uigetdir([], 'choose FCValidTables directory');
saveDir       = uigetdir([], 'choose dir to save FC network');
%% Get training data
dirTrain      = struct2cell(dir(trainDir));
FCTablesFiles = dirTrain(1,:)';
FCTablesFiles = FCTablesFiles(contains(FCTablesFiles, '.mat')); % take only the files that are .mat files
% create the labelled directories in the datastore:
labelsCell    = {'bend-bow (at the waist)';'crawl';'crouch-kneel';'dance';...
                 'fall down';'get up';'jump-leap';'lie-sleep';'martial art';...
                 'run-jog';'sit';'stand';'swim';'walk'};
labelsNum = length(labelsCell);
%% Go video by video and put the images in an ordered training table:
vidNum = 0;
wb = waitbar(vidNum / length(FCTablesFiles), ['video # ', num2str(vidNum), ...
                                ' out of ', num2str(length(FCTablesFiles))]);
FCTMatrix = [];
FCTlabels = [];
FCTNames  = [];
for vidNum = 1 : length(FCTablesFiles)
    waitbar(vidNum / length(FCTablesFiles), wb,  ['video # ', num2str(vidNum),...
                            ' out of ', num2str(length(FCTablesFiles))]);
    % load current FCTable:
    load([trainDir, '\', FCTablesFiles{vidNum}]); % name is FCTrainingTable
    vidID = strsplit(FCTablesFiles{vidNum}, '_');
    vidID = vidID{1};
    % get names, labels and feature matrices:
    midTimes  = mat2cell(round(FCTrainingTable.Time(:,2)), ones(height(FCTrainingTable),1));
    segName   = cellfun(@(X) sprintf([vidID, '_t=%04d'], X), midTimes, 'UniformOutput', false);
    % labelName = cellfun(@(X) labelsCell{X}, FCTrainingTable.label, 'UniformOutput', false);
    labelName = FCTrainingTable.label;
    labelsCtg = categorical(labelName');
    featVecs  = cell2mat(cellfun(@(X) reshape(X, [], 1), FCTrainingTable.FCfeaturesVector', 'UniformOutput', false));
    % concatenate to training arrays:
    FCTMatrix = cat(2, FCTMatrix, featVecs);
    FCTlabels = cat(2, FCTlabels, labelsCtg);
    FCTNames  = cat(1, FCTNames, segName);
end
close(wb)
%% Balance the training data:
% show histogram of training data:
figure(1); subplot(1,2,1); histogram(FCTlabels);
title('unbalanced training histogram');
% pick nClass or less from each class:
nClass = 1000;
balancedTInds = [];
for ii = 1 : labelsNum
    currClass = find(FCTlabels == labelsCell{ii});
    if length(currClass) < nClass + 1
        balancedTInds = cat(2, balancedTInds, currClass);
    else
        currPerm = randperm(length(currClass), nClass);
        balancedTInds = cat(2, balancedTInds, currClass(currPerm));
    end
end
balancedTMat = FCTMatrix(:, balancedTInds);
balancedTLab = FCTlabels(:, balancedTInds);
subplot(1,2,2); histogram(balancedTLab);
title('balanced training histogram');
%% Get validation data
dirValid      = struct2cell(dir(validDir));
FCTablesFiles = dirValid(1,:)';
FCTablesFiles = FCTablesFiles(contains(FCTablesFiles, '.mat')); % take only the files that are .mat files
%% Go video by video and put the images in an ordered validation table:
vidNum = 0;
wb = waitbar(vidNum / length(FCTablesFiles), ['video # ', num2str(vidNum), ...
                                ' out of ', num2str(length(FCTablesFiles))]);
FCVMatrix = [];
FCVlabels = [];
FCVNames  = [];
for vidNum = 1 : length(FCTablesFiles)
    waitbar(vidNum / length(FCTablesFiles), wb,  ['video # ', num2str(vidNum),...
                            ' out of ', num2str(length(FCTablesFiles))]);
    % load current FCTable:
    load([validDir, '\', FCTablesFiles{vidNum}]); % name is FCTrainingTable
    vidID = strsplit(FCTablesFiles{vidNum}, '_');
    vidID = vidID{1};
    % get names, labels and feature matrices:
    midTimes  = mat2cell(round(FCTrainingTable.Time(:,2)), ones(height(FCTrainingTable),1));
    segName   = cellfun(@(X) sprintf([vidID, '_t=%04d'], X), midTimes, 'UniformOutput', false);
    % labelName = cellfun(@(X) labelsCell{X}, FCTrainingTable.label, 'UniformOutput', false);
    labelName = FCTrainingTable.label;
    labelsCtg = categorical(labelName');
    featVecs  = cell2mat(cellfun(@(X) reshape(X, [], 1), FCTrainingTable.FCfeaturesVector', 'UniformOutput', false));
    % concatenate to training arrays:
    FCVMatrix = cat(2, FCVMatrix, featVecs);
    FCVlabels = cat(2, FCVlabels, labelsCtg);
    FCVNames  = cat(1, FCVNames, segName);
end
close(wb)
%% Save data:
beep
disp('    -- finished organizing data for training and validation');
%% create Fully Connected Network
FCLayers = [sequenceInputLayer(5000, 'Name', 'input')
         fullyConnectedLayer(1000, 'Name', 'fc1')
         reluLayer
         fullyConnectedLayer(100, 'Name', 'fc2')
         reluLayer
         fullyConnectedLayer(labelsNum, 'Name', 'fc3')
         softmaxLayer
         classificationLayer
         ]
%% Train
options = trainingOptions('sgdm', ...
    'MaxEpochs',500, ...
    'Verbose',false, ...
    'MiniBatchSize', 256, ...
    'InitialLearnRate', 1E-6, ...
    'Plots','training-progress');
classificationNet = trainNetwork(balancedTMat, balancedTLab,FCLayers,options);
%% Test
validPred = predict(classificationNet, FCVMatrix);
% validPred = predict(classificationNet, balancedTMat);
% GTLabels = balancedTLab';
% [predScore, predLabel]  = max(validPred, [], 1);
% validLabs = categorical(labelsCell(predLabel));
% confMat = confusionmat(validLabs, GTLabels, 'order', labelsCell);
% confTable = array2table(confMat, 'VariableNames', confTLabs, 'RowNames', confTLabs);
GTLabels = FCVlabels';
[predScore, predLabel]  = max(validPred, [], 1);
validLabs = categorical(labelsCell(predLabel));
confMat = confusionmat(validLabs, GTLabels, 'order', labelsCell);
confTLabs = {'bend_bow';'crawl';'crouch_kneel';'dance';...
                 'fall_down';'get_up';'jump_leap';'lie_sleep';'martial_art';...
                 'run_jog';'sit';'stand';'swim';'walk'};
confTable = array2table(confMat, 'VariableNames', confTLabs, 'RowNames', confTLabs);
compareTable = table(validLabs, GTLabels, 'VariableNames', {'Prediction', 'GroundTruth'});
score     = sum(diag(confMat)) / sum(confMat(:));
%% Save
save('FCNetwork', 'classificationNet');