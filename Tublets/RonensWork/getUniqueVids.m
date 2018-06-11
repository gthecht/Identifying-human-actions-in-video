function [memberVid, existPruned, src_dir] = getUniqueVids(myTable)

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
memberVid  = uniqVids(ismember(uniqVids, vids));
% memberStr  = uniqStr(ismember(uniqVids, vids));
mkdir('../prunedVids'); %% places the segments in a directory right beside the whole videos.
existPruned  = struct2cell(dir('../prunedVids'));
existPruned  = existPruned(1,:)';

end

