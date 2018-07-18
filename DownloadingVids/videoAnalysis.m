% video analysis:
vids = struct2cell(dir(pwd))';
vidNames = vids(:,1);
vidNames(find(strcmp(vidNames, '.'))) = [];
vidNames(find(strcmp(vidNames, '..'))) = [];
vidNum = length(vidNames);
resolution = zeros(vidNum, 2);
FrameRate  = zeros(vidNum, 1);
for ii = 1 : vidNum
    vr = VideoReader(vidNames{ii});
    resolution(ii,1) = vr.Height;
    resolution(ii,2) = vr.Width;
    FrameRate(ii)    = vr.FrameRate;
end
%% means:
meanRes = mean(resolution, 1);
meanFR  = mean(FrameRate);
