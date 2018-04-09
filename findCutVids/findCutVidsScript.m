% Gilad Hecht and Ronen Rahamim 09.04.18
% Find cut scenes in order to remove them from the database.
% In this script we will create a table in which the first column will have
% the names of the segments, and in the second columns we will put '1'
% when the segment has a "cut" frame, or '0' when it hasn't such a frame.

prompt = 'Choose the directory from which you want to check it''s videos';
title = 'Input';
answer = inputdlg(prompt,title);
% cd(answer)
list = dir(answer{1});
T = struct2table(list);
T(T.isdir==1, :) = [];
T = table(T.name, T.isdir, 'VariableNames', {'videoName','iscut'});
edges = 5;
countCut = 0;
gradSum = [];
med = [];
for ii = 1:length(T)
    h = [];
    gradN = [];
    v = VideoReader(T.videoName{ii});
    sz = v.Width * v.Height;
    while hasFrame(v)
    video = rgb2gray(readFrame(v));
    N = histcounts(video, edges) / sz;
    h = [h; N];
    end
    for jj = 1:edges
        gradN = [gradN, gradient(h(:,jj))];
    end
    currgradSum = sum(abs(gradN'));
    gradSum = [gradSum; currgradSum];
    med = [med, median(gradSum)];
    if(max(currgradSum) > 5*med)
        T.iscut(ii) = 1;
        countCut = countCut + 1;
    end
end
