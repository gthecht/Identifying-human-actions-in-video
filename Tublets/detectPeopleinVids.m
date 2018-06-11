%% Ronen and Gilad 31.05.18
% Create box tables for videos with people detector.
clear; clc;
<<<<<<< HEAD
%% Choose RCNNModl:
=======
myGPU = gpuDevice;
% Choose RCNNModl:
>>>>>>> Fixing smartgit on Gloria
[detectorN, detectorP] = uigetfile('*.mat', 'Choose people detector RCNN model');
load([detectorP,'\',detectorN]);
peopleDetector = RCNNModl;
vidDir         = uigetdir('..','Find directory with videos');
% Get the video names from the dir:
cd(vidDir);
dirCell = struct2cell(dir(vidDir))';
% we need to get rid of the dots:
vidNames = dirCell(:,1);
vidNames(find(strcmp(vidNames, '.'))) = [];
vidNames(find(strcmp(vidNames, '..'))) = [];
%% Find a dir in which to write the boxTables for the videos:
tablesdir      = uigetdir('..','Find directory for boxTables');
% now we want to identify what videos we already have:
dirCell    = struct2cell(dir(vidDir))';
tableNames = dirCell(:,1);
tableNames(find(strcmp(tableNames, '.'))) = [];
tableNames(find(strcmp(tableNames, '..'))) = [];
% find what tables already exist in the boxTable directory:
dirBoxCell = struct2cell(dir(tablesdir))';
existBoxes = dirBoxCell(:,1);
%% Read videos and find boxes:
% Now that we have the names and path, we can start reading each video, 
% creating a table for each, and saving it in the tablesdir.
problem = zeros(length(vidNames));
<<<<<<< HEAD
parpool(2)
=======
% parpool(2)
>>>>>>> Fixing smartgit on Gloria
parfor ii = 1 : length(vidNames)
% for ii = 1 : length(vidNames)
    try
        splitName = strsplit(vidNames{ii}, '.');
        boxTableName = [splitName{1},'_boxTable'];
        if ismember([boxTableName,'.mat'], existBoxes) % check if already exists in tablesdir
            continue
        end
        ind = 0;
        bbox = cell(2,1);
        score = cell(2,1);
        VR = VideoReader([vidDir,'\',vidNames{ii}]);
        while hasFrame(VR)
            ind = ind+1;
            vidFrame = readFrame(VR);
            [currBbox, currScore, currLabel] = detect(peopleDetector, vidFrame);
            bbox{ind}  = currBbox;
            score{ind} = currScore;
            % Show output on figure:
%         if ~isempty(bbox{ind})
%             detectedImg = insertShape(vidFrame, 'rectangle', bbox{ind});
%         else
%             detectedImg = vidFrame;
%         end
%         figure(ii); imshow(detectedImg);
%         title(['frame no. ', num2str(ind)]);
        end
        %% Create boxTable:
        boxTable = table(bbox, score, 'VariableNames', {'bbox', 'score'});
        % save table to tablesdir:
        parsaveBoxTable(tablesdir, boxTable,boxTableName)
    catch ME
        problem(ii) = 1;
    end
<<<<<<< HEAD
=======
    [msgstr, msgid] = lastwarn;
    % If the last warning contains a CUDA_ERROR, than we want to pause a
    % moment.
    if contains(msgid, 'CUDA_ERROR') % Warning: An unexpected error occurred during CUDA execution. The CUDA error was: CUDA_ERROR_LAUNCH_FAILED
        disp('    -- need a 2-minute breather! ''cause of CUDA...');
        pause(120);
        reset(myGPU);
        lastwarn('');
    end
>>>>>>> Fixing smartgit on Gloria
end