%% Ronen & Gilad, extracting tublets from boxTables, and passing them through vgg16 to get vectors.
clear; clc;

%% Add folders' path and getting the train table according to version 2.0

addpath(pwd)    % the folder of the script

% Getting the table from the csv file. in this case we will choose the
% train table of version 2.0
myTable = ExtractTableFromCSV();

% Loading VGG16 CNN
net = vgg16();
sz = net.Layers(1, 1).InputSize(1:2);
% disp('    --Finished loading VGG16!')

% Create a unique table according to the middle frame time stamps
labelsNum = 1:14;   % the poses numbers
[memberVid, src_dir] = getUniqueVids(myTable);
tubletLabelsTable = createLabelsTableforTublets(labelsNum, myTable, memberVid);
% [fileN, fileP] = uigetfile('*.mat', 'get tubletLabelsTable from tublets directory');
% load([fileP, '\', fileN]);

prompt = 'Enter 15 min boxTables directory';
boxes_dir = uigetdir(pwd, prompt);
addpath(boxes_dir);
% adding directory in which to save the output
saveDir = uigetdir(pwd, 'choose directory to save FC tables');
addpath(saveDir);
dirSaved     = struct2cell(dir(saveDir))';
savedTables  = dirSaved(:,1);
%% Creating the tublets and the feature vectors by VGG16

layer = 'fc8';
% layer = 'prob';
n = length(memberVid);
% Tublets = cell(n, 1);
% labels = cell(n, 1);
% Times = cell(n, 1);
% vidNames = cell(n, 1);
% featureMat = cell(n, 1);
problem = zeros(n,1);
% wb = waitbar(0 / n, ['video #', 0, ' out of ', num2str(n)]);
tic
% parpool(2);
parfor ii = 1:n
    try
    %     waitbar((ii-1) / n, wb, ['video #', num2str(ii), ' out of ', num2str(n)]);
        vidName = strsplit(memberVid{ii}, '.');
        vidName = vidName{1};
        if ismember([vidName, '_FCTable.mat'], savedTables)
            % already exists in saved, so we continue:
            continue
        end
    %     vidNames{ii} = vidName;
%         disp(['    --Creating tubelets and feature vectors for video ', vidName])

        % Loading the full video:
        v = VideoReader([vidName, '.mp4']);
        fps = round(v.FrameRate);

        % Loading the 15 minutes box table
        boxTLoad = load([boxes_dir, '\', vidName, '_15Min_boxTable.mat']);
        boxTable = boxTLoad.boxTable;
        % Extracting the table which is relevant for the current video
        currVidTable = tubletLabelsTable(ismember(tubletLabelsTable.videoID, vidName), :);
        if isempty(currVidTable)
            disp(['    --', vidName, ' is not on current csv file']);
            continue;
        end
        maxBoxTable = maxScoreFromboxTable(boxTable);
%         disp('    --maxBoxTable has been created')

        % Working over each segment individually in the next function, means 
        % for each TimeStamp
        [Tublets, labels, Times] = segTubeletCreator(boxTable,...
                                            maxBoxTable, currVidTable, v, sz);
%         disp(['    --Finished creating tubelets for video ', num2str(ii), ' out of ', num2str(n)])
        % Extract feature vector for each time stamp
        featureMat = getFeaturesFromNet(net, layer, Tublets);
        % extract 5x1000 matrix for FC training and save.
        FCfeatureCell = cellfun(@(X) extractFCTrainingMat(X, fps), featureMat, 'UniformOutput', false);
        saveFCFeature(FCfeatureCell, Times, labels, vidName, saveDir);
%         disp('    --Feature matrices have been created')
    catch ME
        % had problem with this video:
        errID = ME.identifier;
        switch errID
            case 'MATLAB:load:couldNotReadFile'
                disp(['    --', vidName, '_15Min_boxTable.mat cannot be found']);
                problem(ii) = 1;
            otherwise
                problem(ii) = 1;
                disp(['    --unidentified error in video ', vidName]);
                disp(['    -- error is: ', errID]);
        end
    end
end
% output is featureMat, which is a cell of cells
disp('    --Finished! :)')
toc