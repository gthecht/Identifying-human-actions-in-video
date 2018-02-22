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
detectedImg = cell(20,1);
testedImg   = cell(20,1);
figHandle   = cell(20,1);
for kk = 1:20
    img = FrameData.ReadFcn(testTable.names{imgPerm(kk)});
    detectedImg{kk} = insertShape(img, 'Rectangle', bbox{imgPerm(kk)}, 'LineWidth', 2);
    pos = cell2mat([testTable{imgPerm(kk),2:end}]');
    testedImg{kk}   = insertShape(img, 'Rectangle', pos, 'LineWidth', 2);
%     subplot(4,5,kk);
    figHandle{kk} = figure(kk + 2);
    subplot(1,2,1); imshow(detectedImg{kk});
    title('detected boxes');
    subplot(1,2,2); imshow(testedImg{kk});
    title('real boxes');
end
% lastly we want to ask if we should save this:
savechoice = questdlg('Would you like to save these figures?',...
    'saving figures', 'Yes', 'No', 'No');
switch savechoice
    case 'Yes'
        saveDir = uigetdir;
        prevDir = cd(saveDir);
        for kk = 1:20
            NameSplit = strsplit(testTable.names{imgPerm(kk)}, '\');
            NameSplit = strsplit(NameSplit{end}, '.');
            FrameID   = NameSplit{1};
            if FrameID(1) == '-'
                FrameID = ['_', FrameID];
            end
            saveas(figHandle{kk}, FrameID, 'jpg');
        end
        cd(prevDir);
    case 'No'
end
disp('     --finished testing.');
end

