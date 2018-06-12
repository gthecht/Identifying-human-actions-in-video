%% Gilad & Ronen 4 June 2018
% Extract images in boxes from middle-frames, and resize to fit neural
% networks (227x227):
clear; clc;
%% Get labels and create directories
load('labels_table.mat');
% change '/' to '-' so as not to create havoc with directories:
labelsTable.name = strrep(labelsTable.name, '/', '-');
% pick a directory for the image-data-stores and create dirs there:
dataDir    = CreateDataDir(labelsTable);
%% get training and validation csv's, and middle-frame data-store:
[trainingTable,testingTable] = getTrainandTestTables();
FrameData  = createFrameData(); % Creates the frameData - an image datastore with the middle frames in it.
trainLen   = length(trainingTable.videoID);
testLen    = length(testingTable.videoID);
%% Extract boxes
% For both the training set and the test-set, we will go row by row on the
% csv tables. We'll read each image, (if we already read it before, we
% won't read it again), and take the box, resize the image to [227x227x3],
% and save it in the directory for the label of the current row of the
% table.
%% training set:
<<<<<<< HEAD
trainReadSuccess = zeros(trainLen,1);
for ii = 1:trainLen
=======
previi = 71408;
trainReadSuccess = zeros(trainLen,1);
for ii = previi:trainLen
>>>>>>> oneDrive fixing smartgit
    % if we stayed on the same image (same ID and timestamp), we don't want
    % to change:
    if ii == 1
        imName = [trainingTable.videoID{ii}, '_t=', ...
                num2str(trainingTable.middleFrameTimeStamp(ii)), '.jpg'];
        % we'll try and read the image:
        FDInd  = find(contains(FrameData.Files,imName)); % index of frame in FrameData
        % If the frame doesn't exist in the FrameData datastore, then
        % we will skip this iteration
        if isempty(FDInd)
            trainReadSuccess(ii) = 0;
            continue
        end
        currIm = readimage(FrameData, FDInd); %current frame
    else
        if trainingTable.middleFrameTimeStamp(ii) == trainingTable.middleFrameTimeStamp(ii - 1)
            % if the previous read succeeded then this will as well, otherwise 
            % no:
            trainReadSuccess(ii) = trainReadSuccess(ii - 1);
            if ~trainReadSuccess
                continue
            end
        else % we have a new image, and therefore we should update the image-name:
            imName = [trainingTable.videoID{ii}, '_t=', num2str(trainingTable.middleFrameTimeStamp(ii)), '.jpg'];
            % we'll try and read the image:
            FDInd  = find(contains(FrameData.Files,imName)); % index of frame in FrameData
            % If the frame doesn't exist in the FrameData datastore, then
            % we will skip this iteration
            if isempty(FDInd)
                trainReadSuccess(ii) = 0;
                continue
            end
            currIm = readimage(FrameData, FDInd); %current frame
            trainReadSuccess(ii) = 1;
        end
    end
    % now that we have the image, we need to read the current box, and save
    % it in the correct directory:
    %% Current box:
    imsize  = size(currIm);
    imsize  = imsize(1:2); % we don't need the 3 of the rgb at the end
    boxRat  = trainingTable{ii, 3:6}; % ratio of the box compared to image.
    % note that this is: [xTopLeft, yTopLeft, xBotRight, yBotRight]
    % Multiply by the image-size to get the real box:
    boxPix  = floor([boxRat(2) * imsize(1), boxRat(4) * imsize(1), ...
                        boxRat(1) * imsize(2), boxRat(3) * imsize(2)]);
	boxPix(boxPix == 0) = 1; % fixes places where the index is equal to 0
	% note that this is: [yT, yB, xL, xR];
	boxIm   = currIm(boxPix(1):boxPix(2), boxPix(3):boxPix(4),:); % this is the image inside the box
    % We need to resize the image for the network - same size as imagenet:
    newIm   = imresize(boxIm, [227,227]);
    %% Save in directory:
    boxLab  = trainingTable.actionLabel(ii);
    % The path to the labelled directory:
    boxPath = [dataDir, '\trainSet\', labelsTable.type{boxLab}, '\', labelsTable.name{boxLab}];
    imwrite(newIm, [boxPath,'\train_', num2str(ii),'.jpg']);
end
%% Test set:
<<<<<<< HEAD
=======
testReadSuccess = zeros(trainLen,1);
for ii = 1:testLen
    % if we stayed on the same image (same ID and timestamp), we don't want
    % to change:
    if ii == 1
        imName = [testingTable.videoID{ii}, '_t=', ...
                num2str(testingTable.middleFrameTimeStamp(ii)), '.jpg'];
        % we'll try and read the image:
        FDInd  = find(contains(FrameData.Files,imName)); % index of frame in FrameData
        % If the frame doesn't exist in the FrameData datastore, then
        % we will skip this iteration
        if isempty(FDInd)
            testReadSuccess(ii) = 0;
            continue
        end
        currIm = readimage(FrameData, FDInd); %current frame
    else
        if testingTable.middleFrameTimeStamp(ii) == testingTable.middleFrameTimeStamp(ii - 1)
            % if the previous read succeeded then this will as well, otherwise 
            % no:
            testReadSuccess(ii) = testReadSuccess(ii - 1);
            if ~testReadSuccess
                continue
            end
        else % we have a new image, and therefore we should update the image-name:
            imName = [testingTable.videoID{ii}, '_t=', num2str(testingTable.middleFrameTimeStamp(ii)), '.jpg'];
            % we'll try and read the image:
            FDInd  = find(contains(FrameData.Files,imName)); % index of frame in FrameData
            % If the frame doesn't exist in the FrameData datastore, then
            % we will skip this iteration
            if isempty(FDInd)
                trainReadSuccess(ii) = 0;
                continue
            end
            currIm = readimage(FrameData, FDInd); %current frame
            testReadSuccess(ii) = 1;
        end
    end
    % now that we have the image, we need to read the current box, and save
    % it in the correct directory:
    %% Current box:
    imsize  = size(currIm);
    imsize  = imsize(1:2); % we don't need the 3 of the rgb at the end
    boxRat  = testingTable{ii, 3:6}; % ratio of the box compared to image.
    % note that this is: [xTopLeft, yTopLeft, xBotRight, yBotRight]
    % Multiply by the image-size to get the real box:
    boxPix  = floor([boxRat(2) * imsize(1), boxRat(4) * imsize(1), ...
                        boxRat(1) * imsize(2), boxRat(3) * imsize(2)]);
	boxPix(boxPix == 0) = 1; % fixes places where the index is equal to 0
	% note that this is: [yT, yB, xL, xR];
	boxIm   = currIm(boxPix(1):boxPix(2), boxPix(3):boxPix(4),:); % this is the image inside the box
    % We need to resize the image for the network - same size as imagenet:
    newIm   = imresize(boxIm, [227,227]);
    %% Save in directory:
    boxLab  = testingTable.actionLabel(ii);
    % The path to the labelled directory:
    boxPath = [dataDir, '\testSet\', labelsTable.type{boxLab}, '\', labelsTable.name{boxLab}];
    imwrite(newIm, [boxPath,'\test_', num2str(ii),'.jpg']);
end
>>>>>>> oneDrive fixing smartgit
