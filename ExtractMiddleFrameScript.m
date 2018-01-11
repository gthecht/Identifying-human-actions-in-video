% extracts middle frames from segments
clear; clc;
%%
prompt={'Enter segments directory'};
dir_title  = 'data';
src_cell   = inputdlg(prompt,dir_title);
src_dir    = src_cell{1};
cd(src_dir);
%% Extracting names
segments = struct2cell(dir);
segments = segments(1,:)';
dots     = find(ismember(segments, {'.'; '..'; 'Thumbs.db'}));
segments(dots) = [];
segNames = cellfun(@(X) strsplit(X,'.'), segments, 'UniformOutput', false);
segPerm = segNames(randperm(length(segNames)));
segPerm = segNames;
%% now running over the files:
mkdir('../MiddleFrames');
existNames = struct2cell(dir('../MiddleFrames'));
existNames = existNames(1,:)';
size = [227,227];
for ii = 1 : length(segNames)
    currName = [segPerm{ii}{1},'_MiddleFrame.jpg'];
    if ismember(currName, existNames)
        continue;
    end
    ExtractMiddleFrame(segPerm{ii}{1}, size);
end