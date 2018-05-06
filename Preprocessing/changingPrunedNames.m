names = dir('D:\Projects\Project2_AVA\prunedVids');
cd 'D:\Projects\Project2_AVA\prunedVids'
names = {names(~[names.isdir]).name}';
for ii = 1:length(names)
    strName = strsplit(names{ii}, '.');
    newName = [strName{1}, '_15Min.mp4'];
    movefile(names{ii}, newName);
end