function [resized] = ExtractMiddleFrame(vidName, size)
% extracts the frame after 1.5 seconds from the segments, and resizes
% according to size = [a,b]

VR = VideoReader([vidName,'.mp4']);
VR.CurrentTime = 1.5;
FileName = ['../MiddleFrames/', vidName,'_MiddleFrame.jpg'];
midFrame = readFrame(VR);
resized = imresize(midFrame, size);
imwrite(resized, FileName);