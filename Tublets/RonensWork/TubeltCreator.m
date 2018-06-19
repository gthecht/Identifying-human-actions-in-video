%% Irrelevant
% clear; clc;
% %%
% myTable = ExtractTableFromCSV();
% [memberVid, existPruned, src_dir] = getUniqueVids(myTable);
% %%
% t = strsplit(memberVid{1}, '.');
% t = t{1};
% relTable = myTable(ismember(myTable.videoID, t), :);
% %%
% midT = relTable.middleFrameTimeStamp(1000);
% [writeVid, fps] = extract1secSegments(memberVid, midT, src_dir);

%%
clear; clc;

%% Add folders' path and getting the train table according to version 2.0

addpath(pwd)    % the folder of the script

% Getting the table from the csv file. in this case we will choose the
% train table of version 2.0
myTable = ExtractTableFromCSV();

% Loading VGG16 CNN
net = vgg16();
sz = net.Layers(1, 1).InputSize(1:2);
disp('Finished loaded VGG16!')

% Create a unique table according to the middle frame time stamps
labelsNum = 1:14;   % the poses numbers
[memberVid, existPruned, src_dir] = getUniqueVids(myTable);
tubletLabelsTable = createLabelsTableforTublets(labelsNum, myTable, memberVid);

prompt = 'Enter 15 min boxTables directory';
boxes_dir = uigetdir(pwd, prompt);
addpath(boxes_dir);

%% Creating the tublets and the deature vectors by VGG16

layer = 'fc8';
% layer = 'prob';
n = length(memberVid);
Tublets = cell(n, 1);
labels = cell(n, 1);
Times = cell(n, 1);
vidNames = cell(n, 1);
featureMat = cell(n, 1);

tic
for ii = 1:n
    
    vidName = strsplit(memberVid{ii}, '.');
    vidName = vidName{1};
    vidNames{ii} = vidName;
    disp(['Creating tubelets and feature vectors for video ', vidName])
    
    % Loading the full video
    v = VideoReader([vidName, '.mp4']);
    fps = v.FrameRate;
    
    % Loading the 15 minutes box table
    load([vidName, '_15Min_boxTable.mat']);
    
    % Extracting the table which is relevant for the current video
    currVidTable = tubletLabelsTable(ismember(tubletLabelsTable.videoID, vidName), :);
    maxBoxTable = maxScoreFromboxTable(boxTable);
    disp('maxBoxTable has been created')
    
    % Working over each segment individually in the next function, means 
    % for each TimeStamp
    [Tublets{ii}, labels{ii}, Times{ii}] = segTubeletCreator(boxTable,...
                                        maxBoxTable, currVidTable, v, sz);
    disp(['Finished creating tubelets for video ', num2str(ii), ' out of ', num2str(n)])
    
    % Extract feature vector for each time stamp
    featureMat{ii} = getFeaturesFromNet(net, layer, Tublets{ii});
    disp('Feature matrices have been created')
    
    
end

disp('Finished! :)')
toc















