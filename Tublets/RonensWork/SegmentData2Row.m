function [outTable] = SegmentData2Row(vidTable)
% gets a table like dataTable, and turns it into the following table:
% [videoID | middleFrameTimeStamp | boxes | actionLabels]
% Where the columns are:
%   videoID: a string
%   middleFrameTimeStamp: an integer (or double), of the number of seconds
%                         (including the 15 minutes from the start 900 sec).
%   boxes: a Kx4 matrix, where each row is a box [x, y, width, height]. x,y
%       are of the upper-right corner of the box. The units are the ratio
%       compared to the picture.
%   actionLabels: an integer - corresponding to a specific label.
%
% The input is the followinf Table:
% [videoID | middleFrameTimeStamp | topLeft_x | topLeft_y | bottomRight_x | bottomRight_y | actionLabels]
%% Run for each timestamp:
% define unique time stamps:
uniqTS   = unique(vidTable.middleFrameTimeStamp);
emptyTableCol = cell(length(uniqTS),1);
% Empty table for output:
outTable = table(emptyTableCol, uniqTS, emptyTableCol, emptyTableCol, 'VariableNames', ...
    {'videoID', 'middleFrameTimeStamp', 'boxes', 'labels'});
% video ID:
vidID = vidTable.videoID{1};
for ii = 1 : length(uniqTS)
    currTime       = uniqTS(ii);
    currTimeinfo   = table2array(vidTable(vidTable.middleFrameTimeStamp == ...
        currTime, 3:7)); % 3:6 is the box, and 7 is the label
    % extract boxes:
    currTimeBoxes  = [currTimeinfo(:,1:2), ...
                      currTimeinfo(:,3) - currTimeinfo(:,1), ...
                      currTimeinfo(:,4) - currTimeinfo(:,2)]; % [x,y,width,height]
    % extract labels:
    currTimeLabels = currTimeinfo(:, 5);
    % plug into outTable:
    outTable.videoID{ii} = vidID;
    outTable.boxes{ii}   = currTimeBoxes;
    outTable.labels{ii}  = currTimeLabels;
end
end
