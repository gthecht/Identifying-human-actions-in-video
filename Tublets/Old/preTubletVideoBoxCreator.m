%% Ronen and Gilad 26.04.18
% Extract Table of boxes for the video segments. We do this by using a
% RCNN-people detector on each frame, and saving the boxes for each
% segment. After that the boxes will be used to create tublets.

%% Note:
%  Maybe a quicker way would be to run it on the whole videos, and then cut
%  it up into segments.
clear; clc;
%% Create dataframe of videos:
% D:\Projects\Project2_AVA\OneMovieSegments
% dataPath = uigetdir();
% dataPath   = 'D:\Projects\Project2_AVA\OneMovieSegments';
dataPath    = uigetdir();
vidDetails = struct2table(dir(dataPath));
vidName    = vidDetails.name;
vidName    = vidName(3:end);
vidNum     = length(vidName);
%% Run peopleDetector on video frames:
% Load people detector:
[rcnnmodl, path] = uigetfile('*.mat', 'people detector model');
load([path, '\', rcnnmodl]);
% Create output Table:

boxes = cell(vidNum,1);
scores = cell(vidNum,1);
%% Run loop over all videos (trying to run in parallel):
parfor ii = 1 : vidNum
    % videoBoxMaker:
    v = VideoReader([dataPath, '\', vidName{ii}]);
    % load people detector model:
    ind = 0;
    bbox  = cell(v.FrameRate * 2.5,1);
    score = cell(v.FrameRate * 2.5,1);
    while hasFrame(v)
        ind = ind+1;
        vidFrame = readFrame(v);
        [currBbox, currScore, currLabel] = detect(RCNNModl, vidFrame);
        bbox{ind}  = currBbox;
        score{ind} = currScore;
    %     if ~isempty(bbox{ind})
    %         detectedImg = insertShape(vidFrame, 'rectangle', bbox{ind});
    %     else
    %         detectedImg = vidFrame;
    %     end
    %     figure(1); imshow(detectedImg);
    %     title(['frame no. ', num2str(ind)]);
    end
    boxes{ii}  = bbox;
    scores{ii} = score;
%     vidTable.scores{ii} = score;
end
%% Create Table:
vidTable = table(vidName, boxes, scores);
