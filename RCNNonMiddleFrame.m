%% Ronen and Gilad 12.12.17
clear; clc;
%% loading train CSV:
load trainTable; % in: 'Identifying-human-actions-in-video' folder
load uniqueSegmentsIndex; % the indices of the unique segments in the trainTable
%% extract images (plus resize):
% for now we only want the ones with a pose that is:
% stand = 12, sit = 11, walk = 14
labels = [12, 11, 14];
poseTable = trainTable(find(ismember(trainTable.actionLabel, labels)),:);
imNames = cell(length(poseTable.videoID), 1);
for ii = 1:length(poseTable.videoID)
    imNames{ii} = [poseTable.videoID{ii}, '_t=', num2str(poseTable.middleFrameTimeStamp(ii)), '_MiddleFrame.jpg'];
end
uniqNames = unique(imNames);
%% dataTable:
N = cell(length(uniqNames),1);
labelsTable = table(uniqNames,N ,N ,N);
labelsTable.Properties.VariableNames = {'names', 'sit', 'stand', 'walk'};
%% divide iunto train and test:
%% load alexnet:
%% train:
%% test:
%%
figure(); imshow(midFrame);
hold on;
rectangle('Position',[50 50 150 150],'EdgeColor','y','linewidth',5)
size_im = size(midFrame);
%%
pos = zeros(2,4);
actStr = cell(2,1);
for ii = 1:2
    pos(ii,:) = floor([box(ii,1) * size_im(2), box(ii,2) * size_im(1), ...
        (box(ii,3) - box(ii,1)) * size_im(2), (box(ii,4) - box(ii,2)) * size_im(1)]);
    actStr{ii} = [act{ii}];
end
im_anot = insertObjectAnnotation(midFrame, 'rectangle', pos, actStr,...
                'Color', {'cyan', 'yellow'}, 'FontSize', 15, 'Linewidth', 2);
imshow(im_anot);

%%
% loading a segment, and boxes, and depicting the box for the mid-frame.
vidName = 'F3dPH6Xqf5M_t=1180.mp4';

%       tlx    tly    brx    bry
box = [0.291, 0.25, 0.441, 0.741;
	   0.478, 0.286, 0.604, 0.762];
dictionary = { '12 = stand'; '41 = play musical instrument'; '80 = watch (a person)'; ...
    '11 = sit'; '74 = listen to (a person)'; '80 = watch (a person)'}; 
act = {'12 + 41 + 80'; '11 + 74 + 80'};

VR = VideoReader(vidName);
VR.CurrentTime = 1.5;
midFrame = readFrame(VR);
%%
figure(); imshow(midFrame);
hold on;
rectangle('Position',[50 50 150 150],'EdgeColor','y','linewidth',5)
size_im = size(midFrame);
%%
pos = zeros(2,4);
actStr = cell(2,1);
for ii = 1:2
    pos(ii,:) = floor([box(ii,1) * size_im(2), box(ii,2) * size_im(1), ...
        (box(ii,3) - box(ii,1)) * size_im(2), (box(ii,4) - box(ii,2)) * size_im(1)]);
    actStr{ii} = [act{ii}];
end
im_anot = insertObjectAnnotation(midFrame, 'rectangle', pos, actStr,...
                'Color', {'cyan', 'yellow'}, 'FontSize', 18, 'Linewidth', 2);
imshow(im_anot);




