function [existTable] = createExistTablePeople(imNames, uniqNames, labels, isMemberTable, FrameData)
% ExistTable is the table which holds the table of the images that have
% labels as suits 'labels' (according to labelsName) and are also found in
% the frame directory, and has the boxes in pixels according to the image
% sizes. For this we first need labelsTable, which has the data for the
% training table, the only problem is that the boxes aren't yet in pixels,
% but relative.
%% load existTable
choice = questdlg('Would you like to load an existTable? (did you change the data in the directory?)',...
    	'existTable', 'Yes', 'No', 'Yes');
switch choice
    case 'Yes'
        [FileName,PathName] = uigetfile('*.mat','Select your existTable');
        cd(PathName);
        load([PathName,FileName]); % don't know what the warning here might be about.
    case 'No'
        % Now we need to get LabelsTable and fix the sizes. 
        disp('    --This will take some time!')
        tic
        labelsTable = createDataTablePeople(imNames, uniqNames, labels, isMemberTable);
        % labelsTable holds the table with the images and the boxes in them as
        % suits the RCNN algorithm. The only problem is that the boxes' values are
        % in [0,1], and not according to the image size.
        %% Now we want to find the ones we have in the MiddleFrames dataset:
        frameDir = getFrameDir();
        cd(frameDir);
        frames = struct2cell(dir);
        frames = frames(1,:)';
        existIndx  = find(ismember(uniqNames, frames)); % which frames from uniqFrames is in our data-directory
        existTable = labelsTable(existIndx,:); % The table for the existing data.

        %% Now We need to adjust the names so that they hold the path to the files:
        for ii = 1:length(existTable.names)
            existTable.names{ii} = [frameDir, existTable.names{ii}];
        end
        % existTable is the table of the dataset that we have in our data-directory
        %% Get image sizes:
        % According to existIndices, we need to find the sizes of the images. Then
        % we'll plug this into the boxes of existTable.
        FrameLen = length(FrameData.Files);
        % If ImageSize already exists, we only want to load it and see that it is
        % of the same length as the number of frames - to make sure it is updated.
        load([frameDir,'ImgSize.mat']);
        if length(ImgSize) ~= FrameLen
            disp 'Need to update image sizes...'
            ImgSize = zeros(FrameLen,2);
            parfor ii = 1:FrameLen
                currImg  = readimage(FrameData, ii);
                currSize = size(currImg);
                ImgSize(ii,:) = currSize(1:2);
            end
                savechoice = questdlg('Would you like to save this imageSizes?',...
                'saving ImageSizes', 'Yes', 'No', 'Yes');
            switch savechoice
                case 'Yes'
                    uisave('ImgSize', 'ImgSize');
                case 'No'
            end
        end
        % Now for updating the table:
        % We'll run a loop through the all the files, and multiply each box by
        % [sizeX, sizeY, sizeX, sizeY]:
        for ii = 1:length(existIndx) % Might be able to change this to a parfor
            indx = find(ismember(FrameData.Files, existTable.names{ii}));
            pixFrame = [ImgSize(indx,2), ImgSize(indx,1), ImgSize(indx,2), ...
                            ImgSize(indx,1)]; % = [sizeX, sizeY, sizeX, sizeY]
            % if the cell in the table is empty, it won't allow to multiply.
             if ~isempty(existTable{ii,2}{:})
                existTable{ii,2}{:} = round(existTable{ii,2}{:}.*pixFrame);
             end
        end
        toc
        % lastly we want to ask if we should save this:
        savechoice = questdlg('Would you like to save this existTable?',...
            'saving existTable', 'Yes', 'No', 'Yes');
        switch savechoice
            case 'Yes'
                uisave('existTable', 'existTable');
            case 'No'
        end
end
end

