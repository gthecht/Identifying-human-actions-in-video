% clear; clc;
% %%
% myTable = ExtractTableFromCSV();
% [memberVid, existPruned, src_dir] = getUniqueVids(myTable);
% %%
% t = strsplit(memberVid{1}, '.');
% t = t{1};
% relTable = myTable(ismember(myTable.videoID, t), :);
% %%
% midT = relTable.middleFrameTimeStamp(1000);
% [writeVid, fps] = extract1secSegments(memberVid, midT, src_dir);
%%
clear; clc;
%%
addpath(pwd)    % the folder of the script
myTable = ExtractTableFromCSV();
labelsNum = 1:14;
tubletLabelsTable = createLabelsTableforTublets(labelsNum, myTable);
[memberVid, existPruned, src_dir] = getUniqueVids(myTable);
tmpSplit = strsplit(src_dir, '\');
tmpSplit{end} = 'prunedVids';
prunedVids = strjoin(tmpSplit, '\');
addpath(prunedVids)
prompt = 'Enter 15 min boxTables directory';
box_dir = uigetdir(pwd, prompt);
addpath(box_dir);
%%
for ii = 1:length(memberVid)
    
    t = strsplit(memberVid{ii}, '.');
    t = t{1};
    
    % Loading the full video
    v = VideoReader([t, '.mp4']);
    fps = v.FrameRate;
    
    % Loading the 15 minutes box table
    load([t, '_15Min_boxTable.mat']);
    
    % Extracting the table which is relevant for the current video
    currVidTable = tubletLabelsTable(ismember(tubletLabelsTable.videoID, t), :);
    maxBoxTable = maxScoreFromboxTable(currVidTable);
    n = size(tubletLabelsTable.middleFrameTimeStamp, 1);
    
    % Working over each segment individually, means for each TimeStamp
    for jj = 1:n
        
        
    end
    
    
end


















