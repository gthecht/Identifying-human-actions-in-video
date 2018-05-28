function [kTable] = updatekTable(ii,inkTable, VR, vidTable)
% Gets VideoReader, and reads new frame, and updates the boxes and surf
% features in the table.
kTable = inkTable;
kTable.frame{ii + 1} = VR.readFrame(); % the 
    kTable.boxes{ii + 1}  = vidTable.boxes{1}{ii};
    % We want the surf features of the images within the boxes:
    currboxSurf     = cell(size(kTable.boxes{ii + 1}, 1),1);
    currFeatures    = cell(size(kTable.boxes{ii + 1}, 1),1);
    for jj = 1 : size(kTable.boxes{ii + 1}, 1) % changing # of boxes from frame to frame
        currboxSurf{jj}  = detectSURFFeatures(rgb2gray(kTable.frame{ii + 1}), 'ROI', kTable.boxes{ii+1}(jj,:));
        currFeatures{jj} = extractFeatures(rgb2gray(kTable.frame{ii + 1}), currboxSurf{jj});
    end
    kTable.surf{ii + 1} = currboxSurf;
    kTable.features{ii + 1} = currFeatures;
end

