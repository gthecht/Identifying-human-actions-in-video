function [] = surfTubletor(vidTable, k)
%  Given the boxes of a video-segment, and the k neighbors to compare with,
% find the optimal tublets for the given segment, using SURF to compare the
% boxes in the different frames and create tubes from similar boxes.

% Variables:
%       boxTable: table with the following variables:
%           vidName: name of the video\segment
%           boxes:   Cell that holds the boxes of all frames. Each element in
%                    the cell has a 4xL matrix which is the L boxes found in the
%                    frame.
%           scores:  Cell holding the scores for all the boxes, meaning how
%                    sure the system is of each box. We won't use it right
%                    now, but may add it later.
frameNum = length(boxTable.boxes{1}); % number of frames in segment
%% Read video:
videoName  = boxTable.vidName{1};
VR         = VideoReader(videoName); % make sure you are on the right path!
% Table hodling the k+1 frames and the boxes, surf and features:
kTable     = cell2table(cell(k+1, 4), 'VariableNames', {'frame', 'boxes', 'surf', 'features'});
for ii = 1 : k
    kTable = updatekTable(ii, kTable, VR, vidTable);
end
%% Run over frames:
for ii = 1:frameNum % Running frame by frame
    % Move frames back:
    kTable(1:k,:) = kTable(2:k+1,:);
    % get new frame, and update kTable:
    kTable = updatekTable(k, kTable, VR, vidTable);
    % For each frame, we look at the k next frames, and try to find fitting
    % boxes:
    for jj = ii + 1:k
        indexPairs = matchFeatures(features1,features2);
    end
end
end
        