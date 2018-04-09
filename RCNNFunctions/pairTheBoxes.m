function [pairsTable] = pairTheBoxes(nTest, testOutcome, testBoxes, thresh)
% Creates a table of pairs of boxes in all the images - pairing each box
% from the testOutcome, with the best suited one in the real boxes. If
% there is no such pair, than the pairing is with the background. The
% output is a table of pairs, and alongside, the IOU between the boxes.
pairsCell = cell(nTest,1);
for ii = 1:nTest
try
    if ~or(isempty(testOutcome(ii,:).bbox{:}), isempty(testBoxes(ii,:).bbox{:}))
        % We take the IOU matrix, and find the most suitable pairs of
        % boxes, such that the sum of IOU's will be greatest:
        [IOU, flippedIOU, IOUSort, maxInd] = pairByIOU(testOutcome, testBoxes, ii);
        %% Pairing the boxes:
        % The top row of IOUind are the indices of the boxes. We need to
        % know if the columns are the testOutcome or the real boxes.
        indLen = length(maxInd);
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
        labelPairs = cell(size(pairs, 1) , 3);
        for jj = 1 : size(pairs, 1)
            % if we have a 0 as one of the indices in the pairs, we'll
            % label it 'background':
            if pairs(jj, 1) == 0
                labelPairs{jj, 1} = 'background';
                labelPairs{jj, 3} = 0;
            else
                labelPairs{jj, 1} = testLabels{pairs(jj, 1)}; % deleted: testLabels{pairs(jj, 1),:}
                labelPairs{jj, 3} = pairs(jj,3);
            end
            % Similarly for the real boxes column:
            if pairs(jj, 2) == 0
                labelPairs{jj, 2} = 'background';
                labelPairs{jj, 3} = 0;
            else
                labelPairs{jj, 2} = outcomeLabels{pairs(jj, 2)}; % outcomeLabels{pairs(jj, 2), :}
                labelPairs{jj, 3} = pairs(jj,3);
            end
        end
        labelPairs = cell2table(labelPairs, 'VariableNames', {'OutcomeLabels', 'TestLabels', 'IOU'});
        pairsCell{ii} = labelPairs;
%         %% Now we need to compare labels, and create a confusion matrix.
%         confMat = confusionmat(labelPairs.TestLabels, ...
%             labelPairs.OutcomeLabels, 'Order', order);
%         confArray(:, :, ii) = confMat;
    end
catch ME
    disp(['ERROR at image: ', num2str(ii)])
    break
end
end
% Now we have a cell of tables for image. We will concatenate the tables so
% that we get one long table for all the boxes, with: {'OutcomeLabels',
% 'TestLabels', 'IOU'} as columns:
pairsTable = cat(1, pairsCell{:});
end

