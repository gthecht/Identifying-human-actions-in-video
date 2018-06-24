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
tmpTublets = cell(N, 1);
labels = cell(N, 1);
Times = zeros(N, 3);
thresh = 0.5;
downToZero = 900; % If you are using the full video. Otherwise:
junkBox = [0 0 1 1];
del = 0;

% Optimize the boxes we choose
for jj = 1:N
    
    midT = currVidTable.middleFrameTimeStamp(jj) - 900;
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
    
    tmpTublets{jj - del} = currTublet;
    % Now that we have the tublet, we want to know what label it has in the
    % middle frame - this is for the training later on.
    % Equate the middle frame of the boxes we chose with the boxes in the
    % currVidTable for getting the label of the segment
    
    trainBoxes = cell2mat(currVidTable.boxes(jj));
    midBox = currTublet(ceil(fps/2), :);
    c = 1;
    % if we got a junkbox in the middle frame, ten look at neighboring
    % frames. If those are junk also, then the tublet (and the segment
    % are bad).
    deviation = [-1 1 -2 2];
    midFlag = sum(midBox == junkBox);
    if(midFlag == 4)
        while (midFlag == 4)
            if (c == length(deviation) + 1)
                tmpTublets(jj - del) = [];
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
                    Times(jj - del, :) = [startT, realMidT, endT] + downToZero;
                else
                    tmpTublets(jj - del) = [];
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
            Times(jj - del, :) = [startT, realMidT, endT] + downToZero;
        else
            tmpTublets(jj - del) = [];
            labels(jj - del) = [];
            Times(jj - del, :) = [];
            del = del + 1;
        end
    end
end

%% Tublets = tmpTublets;
% Now we read the video-frames themselves, and save the parts inside the
% tublet. In addition we resize it for the vgg. If there's a junkbox, it
% remains a junkbox, and we won't run anything through the vgg. Instead the
% output vector will be zeros(1000,1).
N2 = size(labels, 1);
Tublets = cell(N2, 1);

for jj = 1:N2
    Ton = Times(jj, 1);
    Toff = Times(jj, 3);
    v.CurrentTime = Ton;
    currTublet = tmpTublets{jj};
    segmentTublet = cell(fps, 1);
    c = 1;
%     while (v.CurrentTime <= Toff)
    while (c < fps + 1)
        currFrame = readFrame(v);
        currBox = currTublet(c, :);
        if (currBox == junkBox)
            segmentTublet{c} = junkBox;
            c = c + 1;
            continue;
        end
        currBox(3:4) = currBox(3:4) + currBox(1:2) - 1;
%         currBox(3) = currBox(3) + currBox(1);
%         currBox(4) = currBox(4) + currBox(2);
        rows = currBox(2):currBox(4);
        cols = currBox(1):currBox(3);
        relevantPart = currFrame(rows, cols, :);
        resizedFrame = imresize(relevantPart, sz);
        segmentTublet{c} = resizedFrame;
        c = c + 1;
    end
    Tublets{jj} = segmentTublet;
end
end

