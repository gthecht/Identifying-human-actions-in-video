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

% vidTable for playing with the function: '55Ihr6uVIDA_15Min_boxTable.mat'
% from the DataOutput\PeopleDetectorV2\Alex2Epochs\vid2BoxTables directory
% int the OneDrive folder.
frameNum = numel(vidTable.bbox); % number of frames in segment
%% Read video:
videoName  = vidTable.vidName{1};
VR         = VideoReader(videoName); % make sure you are on the right path! D:\OneDrive\OneDrive - Technion\Courses\Project2\segments\exampleSegments
% Table hodling the k+1 frames and the boxes, surf and features:
kTable     = cell2table(cell(k+1, 4), 'VariableNames', {'frame', 'boxes', 'surf', 'features', 'points'});
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
    for jj = 1:k
        indexPairs = matchFeatures(kTable{1}.features,kTable{jj+1}.features);
    end
end
end
        