% Gilad Hecht and Ronen Rahamim 09.04.18
% Find cut scenes in order to remove them from the database.
% In this script we will create a table in which the first column will have
% the names of the segments, and in the second columns we will put '1'
% when the segment has a "cut" frame, or '0' when it hasn't such a frame.

prompt = 'Choose the directory from which you want to check it''s videos';
title = 'Input';

v = VideoReader('7YpF6DntOYw_t=1039.mp4');
h = [];
sz = v.Width * v.Height;
edges = 5;
while hasFrame(v)
video = rgb2gray(readFrame(v));
N = histcounts(video, edges) / sz;
h = [h; N];
end
gradN = [];
for jj = 1:edges
gradN = [gradN, gradient(h(:,jj))];
end

aa=sum(abs(gradN));
med = meadian(aa);
if(max(aa) > 10*med)
    
    
    
end