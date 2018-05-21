%% Ronen and Gilad 12.12.17
% RCNN only on stand, assuming we can load all the tables from
% stand-sit-walk:
clear; clc;

%% loading train CSV:
load existTable11_12_14;
disp('     --finished loading dataset.');
% take only 'stand':
existTable2 = existTable;
emptyInd = cellfun(@(X) isempty(X), existTable.stand);
existTable2(emptyInd,:) = [];
existTable2 = existTable2(:,[1,3]);

src_dir = 'Z:\MiddleFrames';
cd(src_dir);
FrameDatasetPath = fullfile(cd);
FrameData = imageDatastore(FrameDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');

%% divide into train and test:
dataLength = length(existTable2.names);
dataPerm = randperm(dataLength);
trainTable = existTable2(dataPerm(1 : round(0.8*dataLength)),:);
testTable  = existTable2(dataPerm(round(0.8*dataLength) + 1 : end),:);

figure(1); hold on;
imgPerm = randperm(length(testTable.names),20);
for kk = 1:20
    subplot(4,5,kk);
    imshow(FrameData.ReadFcn(testTable.names{imgPerm(kk)}));
end
suptitle('images from our dataset');
hold off;

figure(2); hold on;
for kk = 1:20
    img = FrameData.ReadFcn(testTable.names{imgPerm(kk)});
    pos = [testTable.stand{imgPerm(kk)}];
    actStr = [''];
    img = insertObjectAnnotation(img, 'rectangle', pos, actStr,...
                'Color', {'cyan'}, 'FontSize', 12, 'Linewidth', 2);
    subplot(4,5,kk);
    imshow(img);
%     title(testTable.names{imgPerm(kk)});
end
suptitle('images from our dataset');
hold off;

%% load alexnet:
alex = alexnet; 

% Review Network Architecture 
layers = alex.Layers;

% Modify Pre-trained Network 
% AlexNet was trained to recognize 1000 classes, we need to modify it to
% recognize just 3 classes. 
layers(23) = fullyConnectedLayer(2); % change this based on # of classes + background
layers(25) = classificationLayer()

disp('     --finished loading alexnet.');

%% train:
mkdir('RCNNTrainCheckpoint');
tempdir = fullfile(cd,'RCNNTrainCheckpoint');
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-6, ...
    'MaxEpochs', 1, ...
    'CheckpointPath', tempdir);
fRCNNModl = trainRCNNObjectDetector(trainTable(1:1000,:), layers, options)
% fRCNNModl = trainFasterRCNNObjectDetector(trainTable(1:1000,:), layers, options)
disp('    --Finished training');

%% test:
nTest = length(testTable.names);
bbox  = cell(nTest,1);
score = cell(nTest,1);
label = cell(nTest,1);
for ii = nTest
    img = FrameData.ReadFcn(testTable.names{ii});
    [bbox{ii}, score{ii}, label{ii}] = detect(fRCNNModl, double(img));
end
testOutcome = table(bbox, score, label);
testOutcome.Properties.VariableNames = {'bbox', 'score', 'label'};
figure(3); hold on;
for kk = 1:20
    img = FrameData.ReadFcn(testTable.names{imgPerm(kk)});
    detectedImg = insertShape(img, 'Rectangle', bbox{imgPerm(kk)});
    subplot(4,5,kk);
    imshow(detectedImg);
end
suptitle('Now the same images with the recognized boxes')
disp('     --finished testing.');


