%% Gilad & Ronen 2nd May 2018
%% Extracting 15-30 section of movies:
clear; clc;
%% Get table of videos:
[list, listPath] = uigetfile('*.csv', 'Select ava_train or ava_test');
csvID = fopen([listPath, list]);
avaTrain = textscan(csvID,'%s %f %f %f %f %f %f', 'Delimiter', ',');
fclose(csvID);
trainTable = table(avaTrain{1}, avaTrain{2}, avaTrain{3}, avaTrain{4}, ...
    avaTrain{5}, avaTrain{6}, avaTrain{7}, ...
    'VariableName', {'videoID', 'middleFrameTimeStamp', 'topLeft_x',...
    'topLeft_y', 'bottomRight_x', 'bottomRight_y', 'actionLabel'});
%% videoFileReader:
%% entering the 'videos' directory
% example in Gilad's:   E:\Project2\videos
% Gilad's onedrive:     C:\Users\User\OneDrive - Technion\Courses\Project2\vidDatabase\videos
prompt     = 'Enter video directory';
src_dir    = uigetdir(pwd, prompt);
cd(src_dir);
% find which videos are in src_dir:
vids       = struct2cell(dir);
vids       = vids(1,:)';
notVids    = ismember(vids, '.') + ismember(vids, '..');
vids       = vids(not(notVids));
uniqVids   = unique(trainTable.videoID);
uniqVids   = cellfun(@(X) [X, '.mp4'], uniqVids, 'UniformOutput', false);
memberVid  = uniqVids(ismember(uniqVids, vids));
% memberStr  = uniqStr(ismember(uniqVids, vids));
mkdir('../prunedVids'); %% places the segments in a directory right beside the whole videos.
existPruned  = struct2cell(dir('../prunedVids'));
existPruned  = existPruned(1,:)';
%% extracting vids
% for ii = 1: length(memberVid)
parfor ii = 1 : length(memberVid)  % just so I won't overlap!
    vidName  = memberVid{ii};
    if ismember([vidName, '_15Min.mp4'], existPruned)
        continue
    end
    startT   = 15*60; % 15 mins
    stopT    = 30*60; % 40 mins
    VR = VideoReader(vidName);
    VR.CurrentTime = startT;
    N = ceil(15*60 * VR.FrameRate);
%     VP = vision.VideoPlayer;
    FileName = ['../prunedVids/', memberVid{ii}, '_15Min'];
    writeVid = VideoWriter(FileName, 'MPEG-4');
    writeVid.FrameRate = VR.FrameRate;
    open(writeVid);
    n = 1;
    while VR.CurrentTime < stopT + 1
        currFrame = readFrame(VR);
        writeVideo(writeVid,currFrame)
    end
%     release(VP);
    close(writeVid);
end