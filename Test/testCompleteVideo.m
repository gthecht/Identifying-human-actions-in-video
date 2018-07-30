%% Testing on tublets and showing tests on complete video
% Gilad & Ronen 17th July 18
clear; clc;
%% Get test videos
FullTestDir = pwd;
% testDir = uigetdir(pwd, 'choose directory of test files - validation set');
% outputDir = uigetdir(pwd, 'choose directory for output');
testDir = [FullTestDir, '\testVids'];
outputDir = [FullTestDir, '\testOutput'];
testVids = struct2cell(dir(testDir))';
vidNames = testVids(:,1);
vidNames(find(strcmp(vidNames, '.'))) = [];
vidNames(find(strcmp(vidNames, '..'))) = [];
% take segments from the videos:
times = [];
video_name = [];
for vidInd = 1 : length(vidNames)
    VR = VideoReader([testDir, '\', vidNames{vidInd}]);
    currTime   = floor(VR.Duration);
    times      = [times ; (0 : currTime - 1)'];
    video_name = [video_name ; repmat(vidNames, [length(times), 1])];
end
nullCell = cell(length(times),1);
segs     = table(video_name, times, nullCell, nullCell, nullCell, nullCell, ...
    'VariableNames', {'video_name', 'times', 'boxes', 'tublets', ...
    'featureVec', 'class'});
%% Use people finder
% [pplFile, pplDir] = uigetfile('.mat', 'Choose peopleDetector');
% [fcFile, fcDir] = uigetfile('.mat', 'Load Fully-Connected network');
% load([pplDir, '\', pplFile]);
load('AlexNet2Epochs.mat');
peopleDetector = RCNNModl;
% load vgg16
vggNet = vgg16();
vggSz  = vggNet.Layers(1, 1).InputSize(1:2);
layer = 'fc8';
% load FC:
% load([fcDir, '\', fcFile]);
load('FCNetwork.mat');
classOrder = classificationNet.Layers(8,1).ClassNames;
%% Use the detector
rowNum = 0;
for ii = 1 : length(vidNames)
    % read video
    VR = VideoReader([testDir, '\', vidNames{ii}]);
    for tInd = find(contains(segs.video_name,  vidNames{ii}))'
        rowNum = rowNum + 1;
        VR.CurrentTime = segs.times(rowNum);
        ind = 0;
        bbox = cell(ceil(VR.FrameRate),1);
        score = cell(ceil(VR.FrameRate),1);
        currTime = zeros(ceil(VR.FrameRate),1);
        while and(VR.hasFrame, VR.CurrentTime < segs.times(rowNum) + 1)
            ind  = ind + 1;
            vidFrame = readFrame(VR);
            [currBbox, currScore, currLabel] = detect(peopleDetector, vidFrame);
            bbox{ind}  = currBbox;
            score{ind} = currScore;
            currTime(ind) = VR.CurrentTime;
        end
        if ~VR.hasFrame
            bbox(ind + 1 : end) = [];
            score(ind + 1 : end) = [];
            currTime(ind + 1 : end) = [];
        end
        boxTable = table(bbox, score, currTime, 'VariableNames', {'bbox', 'score', 'currentTime'});
        segs.boxes{rowNum} = boxTable;
        % Create tublet:
        maxBoxTable = maxScoreFromboxTable(boxTable);
        [Tublets, tubletBoxes, ~] = segTubeletCreatorPresentation(boxTable,...
                                        maxBoxTable, VR, vggSz, segs.times(rowNum), 1);
        featureMat = getFeaturesFromNet(vggNet, layer, Tublets);
        featureVec = extractFCTrainingMat(featureMat{1}, VR.FrameRate);
        segs.tublets{rowNum} = tubletBoxes;
        segs.featureVec{rowNum} = featureVec(:);
        % And now for the classification
        currPred = predict(classificationNet, featureVec(:));
        [predScore, predLabel]  = max(currPred, [], 1);
        segs.class{rowNum} = [classOrder(predLabel), predScore];
    end
end
%% Show output
for ii = 1 : height(segs)
    VR = VideoReader([testDir, '\', segs.video_name{ii}]);
    VR.CurrentTime = segs.times(ii);
    VW = VideoWriter([outputDir, '\', segs.video_name{ii}, num2str(segs.times(ii))]);
    open(VW);
    mkdir(outputDir, [segs.video_name{ii}, num2str(segs.times(ii))]);
    class    = segs.class{ii};
    ind = 0;
    for ind = 1 : length(segs.tublets{ii})
        vidFrame = readFrame(VR);
        currBox  = segs.tublets{ii}(ind,:);
        if currBox(2) + currBox(4) > VR.Height - 30
            currBox(4) = VR.Height - 30 - currBox(2);
        end
        newFrame = insertObjectAnnotation(vidFrame, 'rectangle', currBox, ...
            [class{1}, '  ', num2str(class{2})], 'FontSize',18);
        writeVideo(VW, newFrame);
        imwrite(newFrame, [outputDir, '\', segs.video_name{ii}, ...
             num2str(segs.times(ii)), '\', segs.video_name{ii}, ...
             num2str(segs.times(ii)), 'frame_', num2str(ind), '.jpg']);
    end
    close(VW);
end
%% One video
for vidInd = 1 : length(vidNames)
    VR = VideoReader([testDir, '\', vidNames{vidInd}]);
    VW = VideoWriter([outputDir, '\', segs.video_name{ii}, num2str(segs.times(ii))]);
    open(VW);
    mkdir(outputDir, vidNames{vidInd});
    for ii = find(contains(segs.video_name,  vidNames{vidInd}))'
        class    = segs.class{ii};
        ind = 0;
        for ind = 1 : length(segs.tublets{ii})
            if ~ VR.hasFrame
                continue
            end
            vidFrame = readFrame(VR);
            currBox  = segs.tublets{ii}(ind,:);
            if currBox(2) + currBox(4) > VR.Height - 30
                currBox(4) = VR.Height - 30 - currBox(2);
            end
            newFrame = insertObjectAnnotation(vidFrame, 'rectangle', currBox, ...
                [class{1}, '  ', num2str(class{2})], 'FontSize',18);
            writeVideo(VW, newFrame);
            imwrite(newFrame, [outputDir, '\', vidNames{vidInd}, ...
                '\', segs.video_name{ii}, num2str(segs.times(ii)), ...
                'frame_', num2str(ind), '.jpg']);
        end
    end
    close(VW);
end