function [IOU, flippedIOU, IOUSort, maxInd] = pairByIOU(testOutcome, testBoxes, ii)
% We take the IOU matrix, and find the most suitable pairs of boxes, such
% that the sum of IOU's will be greatest.
IOU = bboxOverlapRatio(testOutcome(ii,:).bbox{:}, ... % This IOU's of all rows in the first with those of the second
                            testBoxes(ii,:).bbox{:}, 'Union');
% The IOU matrix is now the IOU(i,j) = bbox(testOutcome.bbox(i), testBoxes.bbox(j))
% Now we need to see which ones fit best.
% First, we need to find whether there are more boxes in the detected
% or in the real (usually it will be in the detected I think). If not,
% we will flip the IOU (and remember it)
if size(IOU, 1) < size(IOU,2)
    IOU = IOU';
    flippedIOU = true;
else
    flippedIOU = false;
end
% Now we know that a solution exists to the optimization problem.
IOURep = IOU;
[IOUSort, IOUind] = sort(IOURep, 1, 'descend');
maxInd = IOUind(1,:);
% if one of the boxes in the outTable is the best option for two real
% boxes (from testTable), we need to pick to which box it is better
% suited, and then choose the second best for the other one if that is
% possible.
cnt = 0;
while length(unique(maxInd)) ~= length(maxInd) % if 2 boxes go to 1 box
    % find the pair with the same index:
    [~,~,vc] = unique(maxInd, 'Stable');
    odd = find(vc' < 1 : length(vc));
    % If there are two pairs or a trio, we want to work on one pair at a time.
    appear2 = odd(1);
    appear1 = vc(appear2); % because the vc will be the index of the first appearance
    smaller = IOU(maxInd(appear1), appear1) < IOU(maxInd(appear2), appear2);
    if smaller % the first one is smaller
        IOURep(maxInd(appear1), appear1) = -1;
        [IOUSort, Sortind] = sort(IOURep, 1, 'descend');
        IOUind = IOUind(Sortind);
        maxInd = IOUind(2,:);
    else       % the second one is smaller
        IOURep(maxInd(appear2), appear2) = -1;
        [IOUSort, IOUind] = sort(IOURep, 1, 'descend');
        maxInd = IOUind(1,:);
    end
    % Since rows >= columns, we know that a solution exists. So the
    % while loop should stop. But just in case, we'll make sure that it
    % doesn't go through more than the number of possible combinations:
    cnt = cnt + 1;
    if cnt > factorial(size(IOU,1))
        break;
    end
end
end

