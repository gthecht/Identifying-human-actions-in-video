function [testOutcome] = testRCNN(testTable, RCNNModl, FrameData, imgPerm, labelsName)
nTest = length(testTable.names);
bbox  = cell(nTest,1);
score = cell(nTest,1);
label = cell(nTest,1);
for ii = 1:nTest
% for ii = imgPerm
    img = FrameData.ReadFcn(testTable.names{ii});
    [currBbox, currScore, currLabel] = detect(RCNNModl, img);
    bbox{ii}  = currBbox;
    score{ii} = currScore;
    label{ii} = currLabel;
end
testOutcome = table(bbox, score, label);
testOutcome.Properties.VariableNames = {'bbox', 'score', 'label'};
%% We'll show a few images just to see how it went:
close all;
figHandle   = cell(20,1);
for kk = 1:20
    figHandle{kk} = compDetectandTest(FrameData, labelsName, testTable, ...
                        testOutcome, imgPerm(kk), kk);
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
            savefig(figHandle{kk}, FrameID);
        end
        cd(prevDir);
    case 'No'
end
disp('     --finished testing.');
end

