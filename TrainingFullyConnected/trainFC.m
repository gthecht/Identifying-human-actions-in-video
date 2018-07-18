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
labelsCell    = {'bend_bow';'crawl';'crouch_kneel';'dance';...
                 'fall_down';'get_up';'jump_leap';'lie_sleep';'martial_art';...
                 'run_jog';'sit';'stand';'swim';'walk'};
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
    labelName = cellfun(@(X) labelsCell{X}, FCTrainingTable.label, 'UniformOutput', false);
    % labelName = cell2mat(FCTrainingTable.label);
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
    currClass = find(FCTlabels == categorical(labelsCell(ii)));
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
    labelName = cellfun(@(X) labelsCell{X}, FCTrainingTable.label, 'UniformOutput', false);
    % labelName = cell2mat(FCTrainingTable.label);
    labelsCtg = categorical(labelName');
    featVecs  = cell2mat(cellfun(@(X) reshape(X, [], 1), FCTrainingTable.FCfeaturesVector', 'UniformOutput', false));
    % concatenate to training arrays:
    FCVMatrix = cat(2, FCVMatrix, featVecs);
    FCVlabels = cat(2, FCVlabels, labelsCtg);
    FCVNames  = cat(1, FCVNames, segName);
end
close(wb)
%% Balancing validation data:
balancedVInds = [];
for ii = 1 : labelsNum
    currClass = find(FCVlabels == categorical(labelsCell(ii)));
    if length(currClass) < nClass + 1
        balancedVInds = cat(2, balancedVInds, currClass);
    else
        currPerm = randperm(length(currClass), nClass);
        balancedVInds = cat(2, balancedVInds, currClass(currPerm));
    end
end
balancedVMat = FCVMatrix(:, balancedVInds);
balancedVLab = FCVlabels(:, balancedVInds);
%% finished data:
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
    'MaxEpochs',100, ...
    'Verbose',false, ...
    'MiniBatchSize', 256, ...
    'InitialLearnRate', 1E-6, ...
    'Plots','training-progress');
classificationNet = trainNetwork(balancedTMat, balancedTLab,FCLayers,options);
classOrder = classificationNet.Layers(8,1).ClassNames;
%% Test
validPred = predict(classificationNet, balancedVMat);
GTLabels = balancedVLab';
[predScore, predLabel]  = max(validPred, [], 1);
validLabs = categorical(classOrder(predLabel));
confMat = confusionmat(validLabs, GTLabels, 'order', categorical(classOrder));
confTLabs = {'bend_bow';'crawl';'crouch_kneel';'dance';...
                 'fall_down';'get_up';'jump_leap';'lie_sleep';'martial_art';...
                 'run_jog';'sit';'stand';'swim';'walk'};
confTable = array2table(confMat, 'VariableNames', classOrder, 'RowNames', classOrder);
compareTable = table(validLabs, GTLabels, 'VariableNames', {'Prediction', 'GroundTruth'});
score     = sum(diag(confMat)) / sum(confMat(:));
%% show confMat:
sumConf  = sum(confMat);
normConf = confMat ./ repmat(sumConf, labelsNum, 1);
normSurf = kron(normConf, ones(10));
[X, Y] = meshgrid(1:140);
% surf:
figure(2); s = surf(X, Y, normSurf(end:-1:1, :));
view(0,90);
% labels:
set(gca,'xtick',[],'ytick',[]);
text(10*(1:14)-5, 0.5*ones(1,14), classOrder, 'Rotation', -90, ...
                                    'Interpreter', 'none',  'FontSize', 16); % x axes
text(0.5*ones(1,14), 10*(1:14)-5, classOrder(end:-1:1), ...
    'HorizontalAlignment', 'right', 'Interpreter', 'none', 'FontSize', 16); % y axes
% numbers in the table:
ratioStr = cell(labelsNum);
for ii = 1 : labelsNum
    for jj = 1 : labelsNum
        ratioStr{ii,jj} = sprintf('$\\frac{%d}{%d}$', confMat(labelsNum + 1 - ii,jj), sumConf(jj));
    end
end
[ratX, ratY] = meshgrid(10 * (1:14) - 5);
ratZ = ones(labelsNum);
text(ratX(:), ratY(:), ratZ(:), ratioStr(:), 'Interpreter', 'latex', 'FontSize', 26, 'HorizontalAlignment', 'center');
% title:
title('Normalized confusion matrix for FC network');
s.EdgeColor = 'none';
%% Precision and recall:
threshold = (0.2 : 0.05 : 1);
precision   = zeros(length(threshold), labelsNum);
recall      = zeros(length(threshold), labelsNum);
figure(3); hold on
for ii = 1 : labelsNum
    currLab = classOrder{ii};
    for jj = 1 : length(threshold)
        predClass = ismember(compareTable.Prediction, currLab);% 1 where prediction is currClass
        % we need to remove those that are with lower confidence than the
        % threshold:
        predClass = predClass .* (predScore' > threshold(jj));
        GTClass   = double(ismember(compareTable.GroundTruth, currLab)); % 1 where GT is currClass
        currConf  = confusionmat(predClass, GTClass, 'Order', [1, 0]); % confusion matrix for current class
        truePos   = currConf(1,1) + currConf(2,2);
        selected = currConf(1,2);
        relevent = currConf(2,1);
        if truePos + selected == 0
            precision(jj,ii) = 1;
        else
            precision(jj,ii)  = truePos ./ (truePos + selected);
        end
        if truePos + relevent == 0
            recall(jj,ii)    = 0;
        else
            recall(jj,ii)     = truePos ./ (truePos + relevent);
        end
    end
    % plot:
    plot(recall(:,ii), precision(:,ii), '-o');
    text(recall(:,ii)+0.01, precision(:,ii), num2str(threshold'));
end
title(['Precision(recall) for threshold = [', num2str(threshold(1)),',',...
     num2str(threshold(end)), ']']);
 xlabel('Recall'); ylabel('Precision');
legend(classOrder, 'Interpreter', 'none');
xlim([0, 1.05]); ylim([0,1]);
hold off
%% Save
save('FCNetwork', 'classificationNet');