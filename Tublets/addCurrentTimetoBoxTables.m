%% Get videoBoxTable and add currentTime to each frame
% we'll take all the video-box-tables in boxTableDir, and find the
% corresponding videos in vidDir, and then for each frame, get the
% currrentTime, and add it to the table and resave it in newBoxTableDir.
clear; clc;
%% Get boxTable dir:
boxTableDir = uigetdir('..', 'get videoBoxTables directory');
% get files in dir:
dirCell     = struct2cell(dir(boxTableDir))';
% we need to get rid of the dots:
boxTables   = dirCell(:,1);
boxTables(find(strcmp(boxTables, '.'))) = [];
boxTables(find(strcmp(boxTables, '..'))) = [];
vidIDs      = cellfun(@(X) X(1:11), boxTables, 'UniformOutput', false);
vidNames    = cellfun(@(X) [X, '_15Min.mp4'], vidIDs, 'UniformOutput', false);
%% get vidDir:
vidDir      = uigetdir('..', 'get video directory with pruned vids');
% And choose dir for final tables:
saveDir     = uigetdir('..', 'choose directory for final tables');
saveCell    = struct2cell(dir(saveDir))';
existSaved  = saveCell(:,1);
%% Run through videos and read current times:

for ii = 1 : length(vidNames)
    if sum(contains(existSaved, vidNames{ii}(1:11)))
        continue
    end
    load([boxTableDir,'\', boxTables{ii}]); % called boxTable
    % Add currentTime variable:
    boxTable.currentTime = zeros(height(boxTable),1);
    VR = VideoReader([vidDir, '\', vidNames{ii}]);
    ind = 0;
    while hasFrame(VR)
        ind = ind + 1;
            vidFrame = readFrame(VR);
            boxTable.currentTime(ind) = VR.CurrentTime;
    end
    % save new boxTable in saveDir:
    boxTableName = boxTables{ii};
    parsaveBoxTable(saveDir, boxTable,boxTableName);
end
beep; disp('    --Finished');









