%% Gilad & Ronen 6th May 2018
%% Extracting 1 second segments and still frames from the pruned videos.
clear; clc;
%% Get table of segments
[list, listPath] = uigetfile('*.csv', 'Select ava_train or ava_test');
csvID = fopen([listPath, list]);
avaTrain = textscan(csvID,'%s %f %f %f %f %f %f', 'Delimiter', ',');
fclose(csvID);
trainTable = table(avaTrain{1}, avaTrain{2}, avaTrain{3}, avaTrain{4}, ...
    avaTrain{5}, avaTrain{6}, avaTrain{7}, ...
    'VariableName', {'videoID', 'middleFrameTimeStamp', 'topLeft_x',...
    'topLeft_y', 'bottomRight_x', 'bottomRight_y', 'actionLabel'});
%% Create uniqIndex:
% Here we create a unique list of the segments and their times:
numstr  = arrayfun(@(X) num2str(X), trainTable.middleFrameTimeStamp, 'UniformOutput', false);
segName = strcat(trainTable.videoID,'_t=', numstr);
[segName, uniqIndx] = unique(segName, 'stable');
%% Read middleFrames:
% Now we extract the middle frames of the segments:
% First we go to the prunedVids directory:
prompt  = 'Enter pruned video directory';
src_dir = uigetdir(pwd, prompt);
cd(src_dir);
% We want to know which videos are in the source dir:
vids    = struct2cell(dir);
vids    = vids(1,:)';
notVids = ismember(vids, '.') + ismember(vids, '..');
vids    = vids(not(notVids));
% Likewise, we want to know which images we already exported:
midIms  = struct2cell(dir('../MiddleFrames'));
midIms  = midIms(1,:)';
% We will read each video in turn (or in parallel), and extract the
% middleFrames in it:
uniqVids = unique(trainTable.videoID);
times = [];
parfor ii = 1:length(uniqVids)
    vidName = uniqVids{ii};
    if ~ismember([vidName,'_15Min.mp4'], vids)
        disp(['didn''t find video: ', vidName, ' in prunedVids']);
        continue
    end
    currVidindx = ismember(trainTable.videoID, vidName);
    midTimes    = trainTable.middleFrameTimeStamp(currVidindx);
    VR = VideoReader([vidName,'_15Min.mp4']);
    for time = 1 : 899
        realTime = round(VR.CurrentTime) + 900; % +900 for the 15 minutes we don't have here
        if ismember([vidName,'_t=', num2str(realTime), '.jpg'], midIms)
            continue
        end
        frameName = ['../MiddleFrames/', vidName,'_t=', num2str(realTime), '.jpg'];
        try
            VR.CurrentTime = time;
            currFrame = readFrame(VR);
            imwrite(currFrame, frameName);
        catch ME
            disp(['    --error in frame: ', vidName,'_t=', num2str(realTime), '.jpg']);
        end
    end
end

