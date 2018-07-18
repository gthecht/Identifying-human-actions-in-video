function [tubletLabelsTable] = createLabelsTableforTublets(labelIDs, dataTable, memberVid)
% Gets a table of data (for instance trainTable from the csv), and extracts
% a table of boxes for existing movies ordered in the following manner:
% tubletLabelsTable = [videoID | middleFrameTimeStamp | boxes | actionLabels]
% Where the columns are:
%   videoID: a string
%   middleFrameTimeStamp: an integer (or double), of the number of seconds
%                         (including the 15 minutes from the start 900 sec).
%   boxes: a Kx4 matrix, where each row is a box [x, y, width, height]. x,y
%       are of the upper-right corner of the box. The units are the number
%       of pixels.
%   actionLabels: an integer - corresponding to a specific label.
%% Clean dataTable of rows with labels that aren't on labelNums:
cleanDatTable = dataTable(ismember(dataTable.actionLabel, labelIDs),:);% = [];
%% Get unique ID's of the dataTable:
uniqIDs = unique(cleanDatTable.videoID); % ID's of the movies in dataTable.
%% Getting the videos in the directory - to compare to those in the dataTable
% now we want the rows in the table that are only from videos we
% have in our directory:
containsVid    = cell2mat(cellfun(@(X) sum(contains(memberVid, X)) > 0, ...
                            cleanDatTable.videoID, 'UniformOutput', false));
existDataTable = cleanDatTable(containsVid,:); % this table has only the rows that exist.
%% Now we want to change the box data:
% From 4 columns of the table, to one, and for each segment (second), just
% one row. This is similar to the labelsTable of training the RCNN
% detectors.
% We'll define a new table:
tubletLabelsTable = table([],[],[],[], 'VariableNames', ...
                {'videoID', 'middleFrameTimeStamp', 'boxes', 'labels'});
% We'll run over the videos:
for ii = 1 : length(uniqIDs)
    currVid = uniqIDs{ii};
    % We'll check if the video is in our dir:
    if sum(contains(memberVid, currVid)) == 0
        continue
    end
    % So it exists and we can continue: (note that here it doesn't matter,
    % but we'll need the video in the dir for the frame-size later on.
    currTable = existDataTable(contains(existDataTable.videoID,currVid),:);
    % We want to change the columns so that the boxes are in one column,
    % and each segment is in one row:
    tempTable  = SegmentData2Row(currTable);
    % Now we want to update the size of the box to pixel units. For that we
    % need the frame-size:
    VR = VideoReader([currVid,'.mp4']);
    FrameSize = [VR.Height, VR.Width];
    tempTable.boxes = cellfun(@(X) round(X.*[FrameSize, FrameSize]), ...
                                tempTable.boxes, 'UniformOutput', false);
    % And now we'll save the tempTable:
    tubletLabelsTable = [tubletLabelsTable ; tempTable];
end
end