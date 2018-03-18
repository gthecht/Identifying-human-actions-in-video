function [figHandle] = compDetectandTest(FrameData, labelsName, testTable,testOutcome, ind, figNum)
%Shows detected image, alongside the test image, and returns the
%figure-handle
img = FrameData.ReadFcn(testTable.names{ind});
    % detectedImg = insertShape(img, 'Rectangle', testOutcome.bbox{ind}, 'LineWidth', 2);
    if ~isempty(testOutcome.bbox{ind})
        detectedImg = insertObjectAnnotation(img, 'rectangle', ...
            testOutcome.bbox{ind}, cellstr(testOutcome.label{ind}), ...
            'FontSize', 24, 'LineWidth', 2, 'TextBoxOpacity', 0.3);
    else
        detectedImg = img;
    end
    pos = cell2mat([testTable{ind,2:end}]');
    annInd = [];
    for ii = 2 : length(labelsName) + 1
        annInd = [annInd; ones(size(testTable{ind,ii}{:},1),1)];
    end
    annot  = labelsName(annInd);
    testedImg   = insertObjectAnnotation(img, 'rectangle', ...
        pos, annot, 'FontSize', 24, 'LineWidth', 2, 'TextBoxOpacity', 0.3);
    figHandle = figure(figNum);
    subplot(1,2,1); imshow(detectedImg);
    title('detected boxes');
    subplot(1,2,2); imshow(testedImg);
    title('real boxes');
end

