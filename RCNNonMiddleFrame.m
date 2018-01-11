%% Ronen and Gilad 12.12.17
clear; clc;
%% loading train CSV:
load trainTable; % in: 'Identifying-human-actions-in-video' folder
load uniqueSegmentsIndex; % the indices of the unique segments in the trainTable
%% extract images (plus resize):
% for now we only want the ones with a pose that is:
% stand = 12, sit = 11, walk = 14
labels = [11; 12; 14];
labelsName = {'sit'; 'stand'; 'walk'};
poseTable = trainTable(find(ismember(trainTable.actionLabel, labels)),:);
imNames = cell(length(poseTable.videoID), 1);
for ii = 1:length(poseTable.videoID)
    imNames{ii} = [poseTable.videoID{ii}, '_t=', num2str(poseTable.middleFrameTimeStamp(ii)), '_MiddleFrame.jpg'];
end
uniqNames = unique(imNames, 'stable');
%% dataTable:
load LabelsTable11_12_14

imsize = [227 227];
emptyCell = cell(length(uniqNames),1);
% labelsTable = table(uniqNames,emptyCell ,emptyCell ,emptyCell);
% labelsTable.Properties.VariableNames = {'names', 'sit', 'stand', 'walk'};
% for ii = 1:length(uniqNames)
%     currName = uniqNames{ii};
%     segIndx  = find(ismember(imNames, currName));
%     currBox  = poseTable(segIndx, 3:6);
%     currLab  = poseTable(segIndx, 7);
% %     sit = 11
%     for jj = 1:length(labels)
%         Label   = find(ismember(currLab.actionLabel, labels(jj)));
%         if ~isempty(Label)
%             x1 = currBox.topLeft_x(Label);
%             y1 = currBox.topLeft_y(Label);
%             x2 = currBox.bottomRight_x(Label);
%             y2 = currBox.bottomRight_y(Label);
%             BBox = floor([x1 * imsize(1), y1 * imsize(2),...
%                 (x2 - x1) * imsize(1), (y2 - y1) * imsize(2)]);
%             BBox(BBox < 1) = 1;
%             if jj == 1
%                 labelsTable.sit(ii)   = {BBox};
%             elseif jj == 2
%                 labelsTable.stand(ii) = {BBox};
%             elseif jj == 3
%                 labelsTable.walk(ii)  = {BBox};
%             end
%         end
%     end
% end

% Now we want to find the ones we have in the MiddleFrames dataset:
disp('     --finished loading table.');

%% loading existing dataset:
% prompt={'Enter MiddleFrame directory'};
% dir_title  = 'MiddleFrames';
% src_cell   = inputdlg(prompt,dir_title);
% src_dir    = src_cell{1};
src_dir = 'Z:\MiddleFrames';
cd(src_dir);
frames = struct2cell(dir);
frames = frames(1,:)';

existIndx  = find(ismember(uniqNames, frames));
existTable = labelsTable(existIndx,:);

FrameDatasetPath = fullfile(cd);
FrameData = imageDatastore(FrameDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');
for ii = 1:length(existTable.names)
    existTable.names{ii} = [FrameDatasetPath,'\', existTable.names{ii}];
end
disp('     --finished loading dataset.');
%% divide into train and test:
dataLength = length(existTable.names);
dataPerm = randperm(dataLength);
trainTable = existTable(dataPerm(1 : round(0.8*dataLength)),:); % note that this is a constant number - will change later.
testTable  = existTable(dataPerm(round(0.8*dataLength) + 1 : end),:); % note that this is a constant number - will change later.

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
    pos = [testTable.sit{imgPerm(kk)} ; testTable.stand{imgPerm(kk)} ; testTable.walk{imgPerm(kk)}];
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
layers = alex.Layers 

% Modify Pre-trained Network 
% AlexNet was trained to recognize 1000 classes, we need to modify it to
% recognize just 3 classes. 
layers(23) = fullyConnectedLayer(4); % change this based on # of classes + background
layers(25) = classificationLayer()

disp('     --finished loading alexnet.');
%% train:
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-6, ...
    'MaxEpochs', 3, ...
    'CheckpointPath', tempdir);

fRCNNModl = trainFasterRCNNObjectDetector(trainTable, layers, options)
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


