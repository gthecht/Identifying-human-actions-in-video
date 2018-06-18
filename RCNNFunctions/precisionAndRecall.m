function [precision, recall] = precisionAndRecall(threshold, labelsName, pairsTable)
% We now want to creat a precision and recall graph for every label. This 
% means that we will run over different IOU thresholds, and plot the 
% precision as a function of the recall:
precision   = zeros(length(threshold), length(labelsName));
recall      = zeros(length(threshold), length(labelsName));
figure(); hold on
for ii = 1:length(labelsName)
    testLabel      = strcmp(pairsTable.GTLabels,labelsName(ii)); % all testLabels of Label ii
    outcomeLabel   = strcmp(pairsTable.OutcomeLabels,labelsName(ii)); % all outcomeLabels of Label ii
    for jj = 1:length(threshold)
        % the problem is that if the IOU is too low, then we'll need to
        % turn the test label into 0:
        outcomeLabel(pairsTable.Score < threshold(jj)) = 0;
        % Now we can plug this into the confusion matrix:
        confMat  = confusionmat(outcomeLabel,  testLabel, 'Order', [1,0]);
        truePos  = confMat(1,1)+confMat(2,2);
        selected = confMat(1,2);
        relevent = confMat(2,1);
        precision(jj,ii)  = truePos ./ (truePos + selected);
        recall(jj,ii)     = truePos ./ (truePos + relevent);
    end
	% plot:
    plot(recall(:,ii), precision(:,ii), '-o');
    text(recall(:,ii)+0.01, precision(:,ii), num2str(threshold'));
end
title(['Precision(recall) for threshold = [', num2str(threshold(1)),',',...
     num2str(threshold(end)), ']']);
 xlabel('Recall'); ylabel('Precision');
legend(labelsName);
end

