function [FrameData] = createFrameData()
%Creates the frameData - an image dataframe with the middle frames in it.
frameDir = getFrameDir();
cd(frameDir);
FrameDatasetPath = fullfile(cd);
FrameData = imageDatastore(FrameDatasetPath,...
            'IncludeSubfolders',true,'LabelSource','foldernames');
end

