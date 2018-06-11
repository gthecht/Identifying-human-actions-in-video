function [tublets] = IOUTubletor(boxTable, k)
% Given the boxes of a video-segment, and the k neighbors to compare with,
% find the optimal tublets for the given segment.
frameNum = length(boxTable); % number of frames in segment
%% Create cell of IOU matrices between boxes:
iouCell = cell(frameNum, k); % Cell that will contain the iou matrices
for ii = 1:frameNum % run over frames to find tublets
    for jj = ii + 1:k % run over neighbors
        if jj > frameNum
            continue
        end
        % Find the IOU between all boxes of the two frames:
        iouCell{ii,jj - ii + k} = bboxOverlapRatio(boxTable(ii), boxTable(jj));
    end
end

end
    