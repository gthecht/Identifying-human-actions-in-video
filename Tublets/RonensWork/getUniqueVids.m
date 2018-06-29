function [memberVid, src_dir] = getUniqueVids(myTable)
% finds the videos in te table that exist in the directory we choose for
% the vids.
prompt     = 'Enter video directory';
src_dir    = uigetdir(pwd, prompt);
cd(src_dir);
addpath(src_dir);
% find which videos are in src_dir:
vids       = struct2cell(dir);
vids       = vids(1,:)';
notVids    = ismember(vids, '.') + ismember(vids, '..');
vids       = vids(not(notVids));
uniqVids   = unique(myTable.videoID);
uniqVids   = cellfun(@(X) [X, '.mp4'], uniqVids, 'UniformOutput', false);
uniqIDs    = strsplit([uniqVids{:}], '.mp4')';
memberVid  = vids(contains(vids, uniqVids));
end

