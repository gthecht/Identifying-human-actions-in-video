function [balancedTable, balancedNumsTable] = balanceDataSet(dataTable, labelsName)
% Balances the training set such that there are approximately an equal
% number of boxes for each label.

% The idea is to find the label with the minimal number of boxes, and then
% make sure that the others have no more than 10% more boxes. (Might change
% the percentage).

% Note that we didn't make sure to take from different movies. Hopefully
% the randomness will be unbiased.
% We'll define the upper boundary (percentage):
upperBound = 1.1;
imNum = size(dataTable, 1);
%% Find label with minimal # of boxes:
labelBoxMat  = cellfun(@(X) size(X,1), dataTable{:,2:end}); % A matrix with numbers of boxes per label in each column, for each image (rows)
labelBoxNums = sum(labelBoxMat);
[sortAmount, sortIndex] = sort(labelBoxNums); % The minimum value and index
sortLabels   = labelsName(sortIndex); % This we don't really need.
minAmount    = sortAmount(1);
%% Now comes the optimization part:
% We need to pick a number of images so that the numbers of boxes are
% approximately equal. In order to do this, we'll first take all the images
% with at least one box of said label. Then we'll count the number of
% images with the second least amount, and if need be, we add images that
% contain that label (maximal number perhaps?).
% We'll proceed up the label amounts. The way we add images is by
% approximating the number of boxes of the specific label, per image (for
% those with boxes of the specific label), and then add a random number of 
% images equal to the difference in the number of boxes, divided by the 
% mean of the number of boxes per image.
% Right now, we assume that the boxes of the more common labels, won't go
% up too high, but that isn't proven or taken care of. If this gets
% problematic, we will have to decide on a better way of adding images.
% Perhaps with upper and lower bounds and randomly adding and taking away
% images until all labels have boxes within the specified range. Sounds
% very problematic theoretically, but not necissarrily so in the real
% world.
balancedSet     = zeros(imNum,1); % Flags of images going into 'balancedTable'.
balancedBoxNums = zeros(size(labelBoxNums)); % Sum up number of boxes per label included in balanced set.
balancedSet(find(labelBoxMat(:,sortIndex(1)))) = 1; %Add the pictures with labels of minimum
balancedBoxNums = sum(labelBoxMat(find(balancedSet),:));
% Now we need to add images with boxes of the labels without enough boxes.
% We'll run a loop:
for ii = sortIndex(2:end)
    while balancedBoxNums(ii) < minAmount
        % We want to add approximately diff = (minAmount-balancedBoxNums)
        % boxes. Therefore we'll find the mean of the number of boxes per image in
        % an image that does have boxes of this label, and add mean*diff
        % images.
        diff = (minAmount-balancedBoxNums(ii)); % The number of boxes we need to add
        iiBoxes = find(labelBoxMat(:,ii)); % indices of images with boxes of specific label
        iiBoxes = iiBoxes(find(~ismember(iiBoxes, find(balancedSet)))); % all images with specific label, NOT already in balancedSet.
        meanBoxNums = mean(labelBoxMat(iiBoxes, ii)); % mean of number of boxes per image for this label (not icluding images without label)
        pickedBoxes = iiBoxes(randperm(length(iiBoxes), ceil(diff / meanBoxNums))); % Boxes picked to add
        balancedSet(pickedBoxes) = 1;
        balancedBoxNums = sum(labelBoxMat(find(balancedSet),:));
    end
end
balancedTable = dataTable(find(balancedSet),:);
balancedNumsTable = array2table(balancedBoxNums, 'VariableNames', labelsName);
end
