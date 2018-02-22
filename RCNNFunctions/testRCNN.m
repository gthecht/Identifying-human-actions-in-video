function [testOutcome] = testRCNN(testTable, RCNNModl, FrameData, imgPerm)
nTest = length(testTable.names);
bbox  = cell(nTest,1);
score = cell(nTest,1);
label = cell(nTest,1);
% for ii = 1:nTest
for ii = imgPerm
    img = FrameData.ReadFcn(testTable.names{ii});
    [currBbox, currScore, currLabel] = detect(RCNNModl, img);
    bbox{ii}  = currBbox;
    score{ii} = currScore;
    label{ii} = currLabel;
end
testOutcome = table(bbox, score, label);
testOutcome.Properties.VariableNames = {'bbox', 'score', 'label'};
% figure(3); hold on;
for kk = 1:20
    img = FrameData.ReadFcn(testTable.names{imgPerm(kk)});
    detectedImg = insertShape(img, 'Rectangle', bbox{imgPerm(kk)});
    pos = cell2mat([testTable{imgPerm(kk),2:end}]');
    testedImg   = insertShape(img, 'Rectangle', pos);
%     subplot(4,5,kk);
    figure(kk + 2);
    subplot(1,2,1); imshow(detectedImg);
    title('detected boxes');
    subplot(1,2,2); imshow(testedImg);
    title('real boxes');
end
disp('     --finished testing.');
end

