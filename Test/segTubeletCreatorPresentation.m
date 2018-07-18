function [Tublets, Times] = segTubeletCreatorPresentation(boxTable,...
                                        maxBoxTable, v, sz, tStart, tLen)

% input:    bboxTable - the whole table of boxes in the video v.
%           maxBoxTable - the boxes with maximal value in each frame.
%           v - the video after reading it.
%           sz - the size for the resized boxes.
%           tStart - the starting time of the segment.
%           tLen - the length of the segment.
% output:   Tublets - a cell containing in each row the resized tublets for
%                     each time stamp in the first column.
%           Times - the time stamps of each tublet as Nx3 matrix.

N = 1;
fps = round(v.FrameRate);
tmpTublets = cell(N, 1);
Times = zeros(N, 2);
thresh = 0.5;
junkBox = [0 0 1 1];

% tStartFrame = tStart * fps;
% tEndFrame   = (tLen + tStart) * fps;

[~, FirstFrame] = min(abs(maxBoxTable.currentTime - tStart));
[~, LastFrame] = min(abs(maxBoxTable.currentTime - (tStart + tLen)));
segFrames = (FirstFrame : LastFrame);
startT = maxBoxTable.currentTime(segFrames(1));
endT = maxBoxTable.currentTime(segFrames(end));
currMaxBoxes = cell2mat(maxBoxTable.bbox(segFrames));
m = size(currMaxBoxes, 1);
IOUvals = zeros(m);
overThresh = zeros(m);
currTublet = zeros(m, 4);


% Now we calculate the IOU between every pair of boxes
for kk = 1:m
    currBox = currMaxBoxes(kk, :);
    IOUvals(:, kk) = bboxOverlapRatio(currBox, currMaxBoxes);
    overThresh(:, kk) = (IOUvals(:, kk) > thresh); % All good neighbors have an IOu above the threshold
end
% Now we want the best frame whose box has the most IOU's above thresh,
% and we'll then save them as our tublet
sumOverThresh = sum(overThresh);
[~, boxInd] = max(sumOverThresh);
if (length(boxInd) > 1)
    maxIOUvals = IOUvals(:, boxInd);
    sumOverIOU = sum(maxIOUvals);
    [~, boxInd] = max(sumOverIOU);
end
isGoodBox = overThresh(:, boxInd);


%% Changing the irrelevant boxes with other boxes if possible - to fit the best tublet:
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

tmpTublets{1} = currTublet;
Times{1} = [startT, endT];


%% Tublets = tmpTublets;
% Now we read the video-frames themselves, and save the parts inside the
% tublet. In addition we resize it for the vgg. If there's a junkbox, it
% remains a junkbox, and we won't run anything through the vgg. Instead the
% output vector will be zeros(1000,1).
Tublets = cell(1, 1);

Ton = Times(1, 1);
Toff = Times(1, 2);
v.CurrentTime = Ton;
currTublet = tmpTublets{1};
segmentTublet = cell(LastFrame - FirstFrame + 1, 1);    % NOT SURE ABOUT THE "+1" !
c = 1;
while (v.CurrentTime <= Toff)
    currFrame = readFrame(v);
    currBox = currTublet(c, :);
    if (currBox == junkBox)
        segmentTublet{c} = junkBox;
        c = c + 1;
        continue;
    end
    currBox(3:4) = currBox(3:4) + currBox(1:2) - 1;
    rows = currBox(2):currBox(4);
    cols = currBox(1):currBox(3);
    relevantPart = currFrame(rows, cols, :);
    resizedFrame = imresize(relevantPart, sz);
    segmentTublet{c} = resizedFrame;
    c = c + 1;
end
Tublets{1} = segmentTublet;








end

