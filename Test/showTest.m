%% Testing on tublets and showing tests
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
segsNum = 5;
segNames = sort(repmat(vidNames, [segsNum,1]));
times    = rand(length(segNames),1);
nullCell = cell(length(segNames),1);
segs     = table(segNames, zeros(length(segNames),1), nullCell, nullCell, nullCell, nullCell, ...
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
for ii = 1 : length(vidNames)
    % read video
    VR = VideoReader([testDir, '\', vidNames{ii}]);
    for tInd = 1 : segsNum
        segs.times(segsNum * (ii - 1) + tInd) = floor((VR.Duration - 1)*times(segsNum * (ii - 1) + tInd));
        VR.CurrentTime = segs.times(segsNum * (ii - 1) + tInd);
        ind = 0;
        bbox = cell(ceil(VR.FrameRate),1);
        score = cell(ceil(VR.FrameRate),1);
        currTime = zeros(ceil(VR.FrameRate),1);
        while and(VR.hasFrame, VR.CurrentTime < segs.times(segsNum * (ii - 1) + tInd) + 1)
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
        segs.boxes{segsNum * (ii - 1) + tInd} = boxTable;
        % Create tublet:
        maxBoxTable = maxScoreFromboxTable(boxTable);
        [Tublets, tubletBoxes, ~] = segTubeletCreatorPresentation(boxTable,...
                                        maxBoxTable, VR, vggSz, segs.times(segsNum * (ii - 1) + tInd), 1);
        featureMat = getFeaturesFromNet(vggNet, layer, Tublets);
        featureVec = extractFCTrainingMat(featureMat{1}, VR.FrameRate);
        segs.tublets{segsNum * (ii - 1) + tInd} = tubletBoxes;
        segs.featureVec{segsNum * (ii - 1) + tInd} = featureVec(:);
        % And now for the classification
        currPred = predict(classificationNet, featureVec(:));
        [predScore, predLabel]  = max(currPred, [], 1);
        segs.class{segsNum * (ii - 1) + tInd} = [classOrder(predLabel), predScore];
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