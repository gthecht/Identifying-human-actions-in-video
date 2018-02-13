%% Ronen and Gilad 12.12.17
clear; clc;
%% loading train CSV:
load trainTable; % in: 'Identifying-human-actions-in-video' folder
load uniqueSegmentsIndex; % the indices of the unique segments in the trainTable
%% extract images :
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
% these are the names of the images that have at least one of the labels, with no duplicates of the name.
%% dataTable:
load LabelsTable11_12_14 % holds the table with the images and the boxes in
% them as suits the RCNN algorithm. The only problem is that the boxe's values are in [0,1], and not according to the image size.
% emptyCell = cell(length(uniqNames),1);
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
%             BBox = [x1, y1, (x2 - x1), (y2 - y1)];
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

% We want to know where the data is. Currently it is either on Gilad's
% desktop, or in the disk-on-key:
hostName = getComputerName();
if hostName == 'desktop-gloria' % Gilad's desktop
    frame_dir = 'D:\Projects\Project2_AVA\MiddleFrames';
else % Not finding any known name, we'll revert to the dok location
    frame_dir = 'Z:\MiddleFrames';
end
cd(frame_dir);
frames = struct2cell(dir);
frames = frames(1,:)';

existIndx  = find(ismember(uniqNames, frames)); % which frames from uniqFrames is in our data-directory
existTable = labelsTable(existIndx,:); % The table for the existing data.
%% Now We need to adjust the names so that they hold the path to the files:
FrameDatasetPath = fullfile(cd);
FrameData = imageDatastore(FrameDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');
for ii = 1:length(existTable.names)
    existTable.names{ii} = [FrameDatasetPath,'\', existTable.names{ii}];
end
% existTable is the table of the dataset that we have in our data-directory
%% Get image sizes:
% According to existIndices, we need to find the sizes of the images. Then
% we'll plug this into the boxes of existTable.
FrameLen = length(FrameData.Files);
% If ImageSize already exists, we only want to load it and see that it is
% of the same length as the number of frames - to make sure it is updated.
load ImgSize.mat
if length(ImgSize) ~= FrameLen
    ImgSize = zeros(FrameLen,2);
    for ii = 1:FrameLen
        currImg  = readimage(FrameData, ii);
        currSize = size(currImg);
        ImgSize(ii,:) = currSize(1:2);
    end
end
% Now for updating the table:
% We'll run a loop through the all the files, and multiply each box by
% [sizeX, sizeY, sizeX, sizeY]:
for ii = 1:length(existIndx)
    indx = find(ismember(FrameData.Files, existTable.names{ii}));
    pixFrame = [ImgSize(indx,2), ImgSize(indx,1), ImgSize(indx,2), ...
                    ImgSize(indx,1)]; % = [sizeX, sizeY, sizeX, sizeY]
	% if the cell in the table is empty, it won't allow to multiply.
    if ~isempty(existTable(ii,:).sit{:})
        existTable(ii,:).sit{:}   = round(existTable(ii,:).sit{:} .* pixFrame);
    end
    if ~isempty(existTable(ii,:).stand{:})
        existTable(ii,:).stand{:} = round(existTable(ii,:).stand{:} .* pixFrame);
    end
    if ~isempty(existTable(ii,:).walk{:})
        existTable(ii,:).walk{:}  = round(existTable(ii,:).walk{:} .* pixFrame);
    end
end

% load ExistTable11_12_14.mat;
disp('     --finished loading dataset.');
%% divide into train and test:
dataLength = length(existTable.names);
dataPerm = randperm(dataLength);
trainTable = existTable(dataPerm(1 : round(0.8*dataLength)),:);
testTable  = existTable(dataPerm(round(0.8*dataLength) + 1 : end),:);

figure(1); hold on;
imgPerm = randperm(length(testTable.names),20);
for kk = 1:20
    subplot(4,5,kk);
    imshow(FrameData.ReadFcn(testTable.names{imgPerm(kk)}));
end
% suptitle(['images from our dataset']);
hold off;

figure(2); hold on;
for kk = 1:20
    img = FrameData.ReadFcn(testTable.names{imgPerm(kk)});
    pos = [testTable.sit{imgPerm(kk)}; testTable.stand{imgPerm(kk)}; testTable.walk{imgPerm(kk)}];
    actStr = [''];
    img = insertObjectAnnotation(img, 'rectangle', pos, actStr,...
                'Color', {'cyan'}, 'FontSize', 12, 'Linewidth', 2);
    subplot(4,5,kk);
    imshow(img);
%     title(testTable.names{imgPerm(kk)});
end
% suptitle('images from our dataset');
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


