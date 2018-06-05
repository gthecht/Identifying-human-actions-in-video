function [trainTable,testTable, FrameData, imgPerm] = PreTrainingdata(labels)
% PreTrainingdata: organizes the data for training. Compiling a table of
% all boxes with given labels, that are both in the training tables, and
% who's images really exist in the dataset.
% It does the same for the test (or validation) set, and finally shows a
% few image examples from the test set.
% In addition, it also creates the frame-dataset.

%% Create frame dataset
FrameData = createFrameData(); % Creates the frameData - an image dataframe with the middle frames in it.
disp('    -- created FrameData (image dataframe)');
%% loading train CSV, and test CSV:
% It might be preferable to run this just once, and save it if it takes a
% long time:
[trainingTable,testingTable] = getTrainandTestTables();
disp('    -- extracted trainingTable and testingTable, now need to find existTables');
%% extract images :
% We will take all the boxes with poses. The idea is that we want all the
% people, but most boxes have more than one label. We think every box has
% one pose only.
% Train set:
[isMemberTrainTable,imTrainNames, uniqTrainNames] = ...
                                extractImages(labels, trainingTable); % This doesn't change
% Test set:
[isMemberTestTable,imTestNames, uniqTestNames]    = ...
                                extractImages(labels, testingTable);
%% get exist tables:
% creates the table of all the images in the loaded data, that has boxes
% with the specific labels in it, and fixes the boxes for the network.
trainTable = createExistTablePeople(imTrainNames, uniqTrainNames, labels, ...
                isMemberTrainTable, FrameData, 'training');
testTable  = createExistTablePeople(imTestNames, uniqTestNames, labels, ...
                isMemberTestTable, FrameData, 'testing');
%% Show test examples:
% go to frame directoy:
frameDir = getFrameDir();
cd(frameDir);
% show without boxes:
figure(1); hold on;
imgPerm = randperm(length(testTable.names),20);
for kk = 1:20
    subplot(4,5,kk);
    imshow(FrameData.ReadFcn(testTable.names{imgPerm(kk)}));
end
hold off;
% show with boxes:
figure(2); hold on;
for kk = 1:20
    img = FrameData.ReadFcn(testTable.names{imgPerm(kk)});
    pos = cell2mat([testTable{imgPerm(kk),2:end}]');
    actStr = [''];
    img = insertObjectAnnotation(img, 'rectangle', pos, actStr,...
                'Color', {'cyan'}, 'FontSize', 12, 'Linewidth', 2);
    subplot(4,5,kk);
    imshow(img);
end
hold off;
end

