function [confusionMatrix, testScore, outTable] = calcRCNNScore(testTable, testOutcome, labelsName)
% The ide is to find the most suitable boxes in the testOutcome, to those of
% testTable. Then we will find out how good the IOU (Intersection Over 
% Union) is, and also whether the labels are correct.
% It would also be a good idea to create a confusion matrix!
%% Turn testTable boxes into a cell of columns of boxes
% So that we can fit the best boxes in testOutcome and testTable
nTest     = length(testTable.names);
labNum    = length(labelsName);
testBoxes = table(cell(nTest, 1));
testBoxes.Properties.VariableNames = {'bbox'};
for ii = 1:nTest
    currRow = testTable(ii,:);
    row2Cell = currRow{:,2:end};
    testBoxes.bbox{ii} = cell2mat(reshape(row2Cell, [], 1));
    labelSizes = cellfun(@(X) size(X, 1), row2Cell);
    testBoxes.labels{ii} = repelem(labelsName, labelSizes);
end
%% For the confusion matrix:
order     = [labelsName; {'background'}];
confArray  = zeros(labNum + 1, labNum + 1, nTest);
%% IOU:
% Now that the table is ordered, we want use the intersection over union,
% to calculate the overall score
% The problem is that we don't really know what box fits what. One option
% might be to check every box in outTable, with that of the same label in
% testTable, and then use only the one with the top grade.
scoreVec = zeros(nTest,1);
for ii = 1:nTest
try
    if ~or(isempty(testOutcome(ii,:).bbox{:}), isempty(testBoxes(ii,:).bbox{:}))
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
        %% We can pair the boxes:
        % The top row of IOUind are the indices of the boxes. We need to
        % know if the columns are the testOutcome or the real boxes.
        indLen = length(maxInd);
        thresh = 0.1; % threshold under which we don't count the boxes as paired
        if flippedIOU
            % If IOUSort is smaller then some threshold, then in fact there
            % is no pairing:
            pairs     = [maxInd .* (IOUSort(1,:) >= thresh); (1 : indLen);...
                IOUSort(1,:)]'; %[outcome(if the IOU is above threhsold), testBox, IOU]
            % We'll add unpaired boxes:
            % Since we flipped, we know that there are more in outcome than
            % testbox:
            noPair    = find(~ismember(1 : size(IOU, 1), pairs(:,1)));
            noPairAdd = zeros(length(noPair), 3);
            noPairAdd(:,1) = noPair;
            pairs     = cat(1,pairs, noPairAdd);
        else
            pairs     = [(1 : indLen); maxInd .* (IOUSort(1,:) >= thresh);...
                IOUSort(1,:)]'; %[outcome, testBox (if the IOU is above threhsold), IOU]
            noPair    = find(~ismember(1 : size(IOU, 1), pairs(:,2)));
            noPairAdd = zeros(length(noPair), 3);
            noPairAdd(:,2) = noPair;
            pairs     = cat(1,pairs, noPairAdd);
        end
        % labels:
        outcomeLabels  = cellstr(testOutcome.label{ii,:});
        testLabels     = (testBoxes.labels{ii,:});
        labelPairs = cell(size(pairs, 1) , 2);
        for jj = 1 : size(pairs, 1)
            % if we have a 0 as one of the indices in the pairs, we'll
            % label it 'background':
            if pairs(jj, 1) == 0
                labelPairs{jj, 1} = 'background';
            else
                labelPairs{jj, 1} = testLabels{pairs(jj, 1),:};
            end
            % Similarly for the real boxes column:
            if pairs(jj, 2) == 0
                labelPairs{jj, 2} = 'background';
            else
                labelPairs{jj, 2} = outcomeLabels{pairs(jj, 2),:};
            end
        end
        labelPairs = cell2table(labelPairs, 'VariableNames', {'OutcomeLabels', 'TestLabels'});
        %% Now we need to compare labels, and create a confusion matrix.
        confMat = confusionmat(labelPairs.TestLabels, ...
            labelPairs.OutcomeLabels, 'Order', order);
        confArray(:, :, ii) = confMat / sum(confMat(:)); % So that it will be normalized
    end
catch ME
    ii
    break
end
end
confusionMatrix = sum(confArray, 3) / nTest;
testScore           = sum(diag(confusionMatrix)) - confusionMatrix(end,end);
%% Turn testOutcome into a table like testTable
% testOutcome comes as [bbox, score, label]

emptyCell = cell(nTest,2*labNum);
outTable = [table(testTable.names), emptyCell];
labelsScore = strcat(labelsName, 'Score');
outTable.Properties.VariableNames = [{'names'}; labelsName; labelsScore];
for ii = 1:nTest
    currLabs = cellstr(testOutcome(ii,:).label{:});
    labsIndx = cellfun(@(X) find(ismember(labelsName, X)), currLabs, 'UniformOutput', false);
    for jj = 1:length(labsIndx)
        outTable{ii, labsIndx{jj}+1} = {[outTable{ii, labsIndx{jj} + 1}{:};...
            testOutcome(ii,:).bbox{:}(jj,:)]};
        outTable{ii, labsIndx{jj}+1+labNum} = {[outTable{ii, ...
            labsIndx{jj}+1+labNum}{:}; testOutcome(ii,:).score{:}(jj,:)]};
    end
end
