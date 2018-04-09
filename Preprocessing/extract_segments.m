%% Gilad 17.11.17
% trying to extract the segments from the videos for training:
clear; clc;
%% reading csv file into trainTable:
% goin to directory:
prompt={'Enter data directory'};
dir_title  = 'data';
src_cell   = inputdlg(prompt,dir_title);
dat_dir    = src_cell{1};
cd(dat_dir);
% make sure you are in the directory with the csv file.
csvID = fopen('ava_test_v1.0.csv');
avaTrain = textscan(csvID,'%s %f %f %f %f %f %f', 'Delimiter', ',');
fclose(csvID);
trainTable = table(avaTrain{1}, avaTrain{2}, avaTrain{3}, avaTrain{4}, ...
    avaTrain{5}, avaTrain{6}, avaTrain{7}, ...
    'VariableName', {'videoID', 'middleFrameTimeStamp', 'topLeft_x',...
    'topLeft_y', 'bottomRight_x', 'bottomRight_y', 'actionLabel'});
%% getting to unique times of segments:
len = length(trainTable.videoID);
segCell = cell(len,1);
SegStr  = cell(len,1);
for ii = 1 : len
    times = trainTable.middleFrameTimeStamp(ii) + [-1.5, 1.5];
    segCell{ii} = {trainTable.videoID{ii}, times(1), times(2)};
    SegStr{ii} = [segCell{ii}{1},'_t=', num2str(trainTable.middleFrameTimeStamp(ii))];
end
% Create unique:
[~, uniqIndx, ~] = unique(SegStr);
uniqIndx = sort(uniqIndx);
uniqStr = SegStr(uniqIndx);
uniqSegs = segCell(uniqIndx);

%% videoFileReader:
%% entering the 'edited_EEG_data' directory
% example in Gilad's:   E:\Project2\videos
% Gilad's onedrive:     C:\Users\User\OneDrive - Technion\Courses\Project2\vidDatabase\videos
prompt={'Enter video directory'};
dir_title  = 'data';
src_cell   = inputdlg(prompt,dir_title);
src_dir    = src_cell{1};
cd(src_dir);
% find which videos are in src_dir:
vids       = struct2cell(dir);
vids       = vids(1,:)';
uniqIDs    = cellfun(@(X) [X{1},'.mp4'], uniqSegs, 'UniformOutput', false);
memberSeg  = uniqSegs(ismember(uniqIDs, vids));
memberStr  = uniqStr(ismember(uniqIDs, vids));
mkdir('../segmentsDatabase'); %% places the segments in a directory right beside the whole videos.
existsegs  = struct2cell(dir('../segmentsDatabase'));
existsegs  = existsegs(1,:)';
%% extracting vids
for ii = 1: length(memberSeg)
% parfor ii = prev_ii: length(memberSeg)  % just so I won't overlap!
    if ismember([memberStr{ii}, '.mp4'], existsegs)
        continue
    end
    vidName  = [memberSeg{ii}{1}, '.mp4'];
    startT   = memberSeg{ii}{2};
    stopT    = memberSeg{ii}{3};
    VR = VideoReader(vidName);
    VR.CurrentTime = startT;
    N = ceil(3 * VR.FrameRate);
%     VP = vision.VideoPlayer;
    FileName = ['../segmentsDatabase/', memberStr{ii}, '.mp4'];
    writeVid = VideoWriter(FileName, 'MPEG-4');
    open(writeVid);
    n = 1;
    for n = 1:N
        currFrame = readFrame(VR);
        writeVideo(writeVid,currFrame)
    end
%     release(VP);
    close(writeVid);
end