function [dataDir] = CreateDataDir(labelsTable)
% given the labels, asks for a location, and creates a directory for each
% label - so that we can easily use the image datastore object.
dataDir = uigetdir('..', 'choose directory for box-images');
cd(dataDir);
% training set and test set:
mkdir(dataDir, 'trainSet');
mkdir(dataDir, 'testSet');
% Now for each one we'll make a dir for every label:
for ii = 1:length(labelsTable.name)
    currDirName = [labelsTable.type{ii}, '\', labelsTable.name{ii}];
    mkdir([dataDir, '\trainSet'], currDirName);
    mkdir([dataDir, '\testSet'], currDirName);
end
end

