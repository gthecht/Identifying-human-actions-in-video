function [Tublets, labels, Times] = segTubeletCreator(boxTable,...
                                    maxBoxTable, currVidTable, v, sz)

% Firstly we want to optimize the way we choose the boxes in the segment by
% using IoU calculation between the relevant boxes in the current segment.
% The boxes with the highest value of IoU we store, and find in the other
% frames another box (if exist) for changing the other box which isn't
% relevant for the segment. after that we continue to create a resized
% tublet for the relevant segment according to the requierd size of the
% next net (VGG16).
% input:    bboxTable - the whole table of boxes in the video v.
%           maxBoxTable - the boxes with maximal value in each frame.
%           currVidTable - the unique (by time) table from the csv file.
%           v - the video after reading it.
%           sz - the size for the resized boxes.
% output:   Tublets - a cell containing in each row the resized tublets for
%                     each time stamp in the first column.
%           labels - the labels of each tublet as a column vector cell.
%           Times - the time stamps of each tublet as Nx3 matrix.

fps = v.FrameRate;
H = v.Height;
W = v.Width;
N = size(currVidTable.middleFrameTimeStamp, 1);
Tublets = cell(N, 1);
labels = cell(N, 1);
Times = zeros(N, 3);
thresh = 0.5;
downToZero = 900;
junkBox = [0 0 1 1];
del = 0;

% Optimize the boxes we choose
for jj = 1:N
    
    midT = currVidTable.middleFrameTimeStamp(jj) - downToZero;
    [~, ind] = min(abs(maxBoxTable.currentTime - midT));
    segFrames = (ind - floor(fps/2)):(ind + ceil(fps/2) - 1);
    realMidT = maxBoxTable.currentTime(ind);
    startT = maxBoxTable.currentTime(segFrames(1));
    endT = maxBoxTable.currentTime(segFrames(end));
    currMaxBoxes = cell2mat(maxBoxTable.bbox(segFrames));
    m = size(currMaxBoxes, 1);
    IOUvals = zeros(m);
    overThresh = zeros(m);
    currTublet = zeros(m, 4);
    
    for kk = 1:m
        currBox = currMaxBoxes(kk, :);
        IOUvals(:, kk) = bboxOverlapRatio(currBox, currMaxBoxes);
        overThresh(:, kk) = (IOUvals(:, kk) > thresh);
    end
    
    sumOverThresh = sum(overThresh);
    [~, boxInd] = max(sumOverThresh);
    if (length(boxInd) > 1)
        maxIOUvals = IOUvals(:, boxInd);
        sumOverIOU = sum(maxIOUvals);
        [~, boxInd] = max(sumOverIOU);
    end
    isGoodBox = overThresh(:, boxInd);
    
    % Changing the irrelevant boxes with another boxes if possible
    isBadBox = ~isGoodBox;
    [badInd, ~] = find(isBadBox);
    [goodInd, ~] = find(isGoodBox);
    currTublet(goodInd, :) = currMaxBoxes(goodInd, :);
    goodMaxBoxes = currMaxBoxes(goodInd, :);

    for kk = 1:sum(isBadBox)
        currBadBoxes = cell2mat(boxTable.bbox(segFrames(badInd(kk))));
        if (size(currBadBoxes, 1) == 0)
            currTublet(badInd(kk), :) = junkBox;
            continue;
        end
        currBadIOU = bboxOverlapRatio(currBadBoxes, goodMaxBoxes);
        sumCurrBadIOU = sum(currBadIOU > thresh, 2);
        [~, newBox] = max(sumCurrBadIOU);
        if (sumCurrBadIOU(newBox) > m/2)
            currTublet(badInd(kk), :) = currBadBoxes(newBox, :);
        else
            currTublet(badInd(kk), :) = junkBox;
        end
    end
    
    Tublets{jj - del} = currTublet;
    
    % Equate the middle frame of the boxes we chose with the boxes in the
    % currVidTable for getting the label of the segment
    
    trainBoxes = cell2mat(currVidTable.boxes(jj));
    midBox = currTublet(ceil(fps/2), :);
    c = 1;
    deviation = [-1 1 -2 2];
    midFlag = sum(midBox == junkBox);
    if(midFlag == 4)
        while (midFlag == 4)
            if (c == length(deviation) + 1)
                Tublets(jj - del) = [];
                labels(jj - del) = [];
                Times(jj - del, :) = [];
                del = del + 1;
                break;
            end
            midBox = currTublet(ceil(fps/2) + deviation(c), :);
            midFlag = sum(midBox == junkBox);
            if (midFlag ~= 4)
                labelIOU = bboxOverlapRatio(trainBoxes, midBox);
                [IOUval, labelInd] = max(labelIOU);
                if (IOUval > 0.05)
                    labels{jj - del} = currVidTable.labels{jj}(labelInd);
                    Times(jj - del, :) = [startT, realMidT, endT];
                else
                    Tublets(jj - del) = [];
                    labels(jj - del) = [];
                    Times(jj - del, :) = [];
                    del = del + 1;
                end
            end
            c = c + 1;
        end
    else
        labelIOU = bboxOverlapRatio(trainBoxes, midBox);
        [IOUval, labelInd] = max(labelIOU);
        if (IOUval > 0.05)
            labels{jj - del} = currVidTable.labels{jj}(labelInd);
            Times(jj - del, :) = [startT, realMidT, endT];
        else
            Tublets(jj - del) = [];
            labels(jj - del) = [];
            Times(jj - del, :) = [];
            del = del + 1;
        end
    end
    
end



end

