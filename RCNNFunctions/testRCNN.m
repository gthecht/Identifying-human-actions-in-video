function [testOutcome] = testRCNN(testTable, RCNNModl, FrameData, imgPerm, ...
                        labelsName, bbox, score, label, nTest, startIndx)
% runs detect over all images in test-batch, and returns frames with
% labels. Shows a few examples with boxes detected and real side by side
% and allows to save them.
try
    waitf = waitbar(0,['Tested 0 images out of ', num2str(nTest)]);
    for ii = startIndx:nTest
    % for ii = imgPerm
        waitStr = ['Tested ', num2str(ii - 1), ' images out of ', num2str(nTest)];
        waitbar(ii/nTest, waitf, waitStr);
        img = FrameData.ReadFcn(testTable.names{ii});
        [currBbox, currScore, currLabel] = detect(RCNNModl, img);
        bbox{ii}  = currBbox;
        score{ii} = currScore;
        label{ii} = currLabel;
    end
catch ME
    startIndx = ii;
    save('testRCNN_bboxScoreLabel', 'bbox', 'score', 'label', 'startIndx');
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

