% Gilad Hecht and Ronen Rahamim 09.04.18
% Find cut scenes in order to remove them from the database.
% In this script we will create a table in which the first column will have
% the names of the segments, and in the second columns we will put '1'
% when the segment has a "cut" frame, or '0' when it hasn't such a frame.

clear;
clc;

prompt = 'Choose the directory from which you want to check it''s videos';
title = 'Input';
answer = inputdlg(prompt,title);
% cd(answer)
list = dir(answer{1});
T = struct2table(list);
T(T.isdir==1, :) = [];
T = table(T.name, T.isdir, 'VariableNames', {'videoName','iscut'});
edges = 8; % tried 5, 10, 256 before
countCut = 0;
gradSum = [];
med = [];
for ii = 1:length(T.iscut)
    h = [];
    gradN = [];
    v = VideoReader(T.videoName{ii});
    frameNum = ceil(v.Duration * v.FrameRate);
    sz = v.Width * v.Height;    % size of the frames in the a video
    while hasFrame(v)   % For a single video
    video = rgb2gray(readFrame(v));
    N = histcounts(video, edges) / sz;
    h = [h; N];
    end
    for jj = 1:edges
        gradN = [gradN, gradient(h(:,jj))]; % SHOULD BE GRADIENT ON N?, 
        % MAYBE WE NEED TO SAVE THE CURRGRADIENT FROM LATER CALCULATIONS
    end
    currgradSum = sum(abs(gradN(:,ii)'));
    gradSum = [gradSum; currgradSum];
    currmed = median(currgradSum);
    med = [med, currmed];
    if(max(currgradSum) > 5*med)
        T.iscut(ii) = 1;
        countCut = countCut + 1;
    end
end
