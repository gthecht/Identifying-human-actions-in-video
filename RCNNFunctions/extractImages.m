function [isMemberTable,imNames, uniqNames] = extractImages(labels, trainTable)
% This function finds the images for which there are people with the
% labels, and also lists each image only once.
% isMemberTable = the rows in the trainTable are labeled according to input
% 'labels'
% uniqNames = the names of the images that are in 'isMemberTable'. Unique
% vector
isMemberTable = trainTable(find(ismember(trainTable.actionLabel, labels)),:);
imNames = cell(length(isMemberTable.videoID), 1);
for ii = 1:length(isMemberTable.videoID)
    imNames{ii} = [isMemberTable.videoID{ii}, '_t=', ... % the names of the images in 'isMemberTable'
        num2str(isMemberTable.middleFrameTimeStamp(ii)), '.jpg'];
end
uniqNames = unique(imNames, 'stable');
% these are the names of the images that have at least one of the labels, with no duplicates of the name.
end

