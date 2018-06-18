function [featVec] = tublet2featVec(tubletTable, videoFile, CNN, startTime)
% This function recieves a tublet, and and the videoFile to which it
% belongs. It then runs every the tublet through CNN - a neural network - for every frame,
% the image bounded within the tublet box is resized and passed through
% vgg.
% The output is a vector of size 1024x1, that is the feature vector of the
% image. We will run this later through the FC network.
%% Preliminary variables:
len = length(tubletTable(:,1));
featVec = zeros(len, 4096);
VR = VideoReader(videoFile); % read the video file
VR.CurrentTime = startTime;
%% Run through loop:
for ii = 1 : len
    currFrame = VR.readFrame;
    if tubletBox(ii) == [0,0,1,1]
        continue
    end
    currBox   = 
    currbox   = imresize(currBox, [224,224]);
    feats(ii,:) = activations(CNN, currBox, 36);
end

