function [labelsTable] = createDataTable(imNames, uniqNames, labels, labelsName, isMemberTable)
% In order to create the dataTable, we need to create a table with the
% images of 'uniqNames', and then to creat the boxes for each label - this
% is for the RCNN function.
% The problem is that this takes a very long time, so we would rather save
% it, and only create it from scratch when we have to. In order to do this,
% we'll ask the user if he wants to load a table, and if so we'll open the
% tables directory. If not, we'll run the whol function.
choice = questdlg('Would you like to load a labelsTable?', 'labelsTable', ...
    'Yes', 'No', 'Yes');
switch choice
    case 'Yes'
        [FileName,PathName] = uigetfile('*.mat','Select your labelsTable');
        load([PathName,FileName]); % don't know what the warning here might be about.
    case 'No'
        emptyCell = cell(length(uniqNames),length(labelsName));
        labelsTable = table(uniqNames);
        labelsTable = [labelsTable, emptyCell];
        % labelsTable = table([uniqNames,emptyCell]);
        labelsTable.Properties.VariableNames = {'names', labelsName{:}}; % the variable names are the labels - for the RCNN
        % for every image in uniqNames, we find all the boxes in
        % isMemberTable:
        for ii = 1:length(uniqNames) 
            currName = uniqNames{ii};
            segIndx  = find(ismember(imNames, currName));
            currBox  = isMemberTable(segIndx, 3:6);
            currLab  = isMemberTable(segIndx, 7);
            % fixing the boxes [[x1,y1,width,height];...] remember that
            % these are still between 0 and 1:
            for jj = 1:length(labels)
                Label   = find(ismember(currLab.actionLabel, labels(jj)));
                if ~isempty(Label)
                    x1 = currBox.topLeft_x(Label);
                    y1 = currBox.topLeft_y(Label);
                    x2 = currBox.bottomRight_x(Label);
                    y2 = currBox.bottomRight_y(Label);
                    BBox = [x1, y1, (x2 - x1), (y2 - y1)];
                    labelsTable{ii,1+jj}   = {BBox};
                end
            end
        end
        % lastly we want to ask if we should save this:
        savechoice = questdlgtimeout(60, 'Would you like to save this labelsTable?',...
            'saving labelsTable', 'Yes', 'No', 'Yes');
        switch savechoice
            case 'Yes'
                uisave('labelsTable', 'labelsTable');
            case 'No'
        end
end
% labelsTable holds the table with the images and the boxes in them as
% suits the RCNN algorithm. The only problem is that the boxes' values are
% in [0,1], and not according to the image size.
end

