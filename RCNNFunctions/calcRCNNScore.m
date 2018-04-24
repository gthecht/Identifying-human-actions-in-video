function [confTable, testScore, outTable, precision, recall] = ...
                        calcRCNNScore(testTable, testOutcome, labelsName)
% find the optimal pairing between the boxes found, and the groundTruth
% boxes. Then compare the labels between them to see if the classification
% was correct. plot a precision and recall graph where the threshold is on
% the IOU between the boxes (how well the fit each other), and lastly write
% the confusion matrix for the minimal threshold.

%% Turn testTable boxes into a cell of columns of boxes
% So that we can fit the best boxes in testOutcome and testTable
nTest     = length(testTable.names);
thresh = 0.5; % threshold under which we don't count the boxes as paired
labNum    = length(labelsName);
testBoxes = createTestBoxesTable(nTest, testTable, labelsName);
%% IOU:
% Now that the table is ordered, we want use the intersection over union,
% to calculate the overall score
% The problem is that we don't really know what box fits what. One option
% might be to check every box in outTable, with that of the same label in
% testTable, and then use only the one with the top grade.
pairsTable = pairTheBoxes(nTest, testOutcome, testBoxes, thresh);
%% Precision and recall
% We now want to creat a precision and recall graph. This means that we
% will run over different IOU thresholds, and plot the precision as a
% function of the recall:
threshold   = thresh : 0.05 : 1;
[precision, recall] = precisionAndRecall(threshold, labelsName, pairsTable);
%% Confusion matrix with threshold 'thresh'
order     = [labelsName; {'background'}]; % the labels with background in the order for the confusion matrix
confusionMatrix      = confusionmat(pairsTable.GTLabels, ...
            pairsTable.OutcomeLabels, 'Order', order);
confTable = array2table(confusionMatrix, 'RowNames', order, 'VariableNames', order);
testScore = sum(diag(confusionMatrix)) / sum(confusionMatrix(:));
%% Turn testOutcome into a table like testTable
% testOutcome comes as [bbox, score, label]
outTable = createOutTable(testOutcome, testTable, labelsName, nTest, labNum);
end
