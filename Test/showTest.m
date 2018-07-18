%% Testing on tublets and showing tests
% Gilad & Ronen 17th July 18
clear; clc;
%% Get test videos
testDir = uigetdir(pwd, 'choose directory of test files - validation set');
outputDir = uigetdir(pwd, 'choose directory for output');
testVids = struct2cell(dir(testDir))';
vidNames = testVids(:,1);
vidNames(find(strcmp(vidNames, '.'))) = [];
vidNames(find(strcmp(vidNames, '..'))) = [];
% take segments from the videos:
segsNum = 5;
segNames = sort(repmat(vidNames, [segsNum,1]));
times    = randi(900, length(segNames),1);
nullCell = cell(length(segNames),1);
segs     = table(segNames, times, nullCell, nullCell, nullCell, nullCell, ...
    'VariableNames', {'video_name', 'segment_time', 'boxes', 'tublets', ...
    'featureVec', 'class'});
%% Use people finder
[pplFile, pplDir] = uigetfile('.mat', 'Choose peopleDetector');
load([pplDir, '\', pplFile]);
peopleDetector = RCNNModl;
% load vgg16
vggNet = vgg16();
vggSz  = vggNet.Layers(1, 1).InputSize(1:2);
layer = 'fc8';
% load FC:
[fcFile, fcDir] = uigetfile('.mat', 'Load Fully-Connected network');
load([fcDir, '\', fcFile]);
classOrder = classificationNet.Layers(8,1).ClassNames;
%% Use the detector
for ii = 1 : length(vidNames)
    % read video
    VR = VideoReader([testDir, '\', vidNames{ii}]);
    for tInd = 1 : segsNum
        VR.CurrentTime = times(segsNum * (ii - 1) + tInd);
        ind = 0;
        bbox = cell(ceil(VR.FrameRate),1);
        score = cell(ceil(VR.FrameRate),1);
        currTime = zeros(ceil(VR.FrameRate),1);
        while VR.CurrentTime < times(segsNum * (ii - 1) + tInd) + 1
            ind  = ind + 1;
            vidFrame = readFrame(VR);
            [currBbox, currScore, currLabel] = detect(peopleDetector, vidFrame);
            bbox{ind}  = currBbox;
            score{ind} = currScore;
            currTime(ind) = VR.CurrentTime;
        end
        boxTable = table(bbox, score, currTime, 'VariableNames', {'bbox', 'score', 'currentTime'});
        segs.boxes{segsNum * (ii - 1) + tInd} = boxTable;
        % Create tublet:
        maxBoxTable = maxScoreFromboxTable(boxTable);
        [Tublets, ~] = segTubeletCreatorPresentation(boxTable,...
                                        maxBoxTable, VR, vggSz, times(segsNum * (ii - 1) + tInd), 1);
        featureMat = getFeaturesFromNet(vggNet, layer, Tublets);
        featureVec = extractFCTrainingMat(featureMat{1}, VR.FrameRate);
        segs.tublets{segsNum * (ii - 1) + tInd} = Tublets{1};
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
    VR.CurrentTime = segs.segment_time;
    VW = VideoWriter([outputDir, '\', segs.video_name{ii}, num2str(segs.segment_time)]);
    open(VW);
    mkdir(outputDir, [segs.video_name{ii}, num2str(segs.segment_time)]);
    class    = segs.class{ii};
    ind = 0;
    while VR.CurrentTime < segs.segment_time(ii) + 1
        ind = ind + 1;
        vidFrame = readFrame(VR);
        currBox  = segs.tublets{ii}{ind};
        newFrame = insertObjectAnnotation(vidFrame, 'rectangle', currBox, ...
            class, 'FontSize',18);
        writeVideo(VW, newFrame);
        imwrite(newFrame, [outputDir, '\', segs.video_name{ii}, ...
                      num2str(segs.segment_time), 'frame_', num2str(ind)]);
    end
    close(VW);
end