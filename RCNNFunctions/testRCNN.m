function [testOutcome] = testRCNN(testTable, RCNNModl, FrameData, imgPerm)
nTest = length(testTable.names);
bbox  = cell(nTest,1);
score = cell(nTest,1);
label = cell(nTest,1);
for ii = nTest
    img = FrameData.ReadFcn(testTable.names{ii});
    [bbox{ii}, score{ii}, label{ii}] = detect(RCNNModl, double(img));
end
testOutcome = table(bbox, score, label);
testOutcome.Properties.VariableNames = {'bbox', 'score', 'label'};
figure(3); hold on;
for kk = 1:20
    img = FrameData.ReadFcn(testTable.names{imgPerm(kk)});
    detectedImg = insertShape(img, 'Rectangle', bbox{imgPerm(kk)});
    subplot(4,5,kk);
    figure()
    imshow(detectedImg);
end
disp('     --finished testing.');
end

