% videoBoxMaker:
v = VideoReader('D:\Projects\Project2_AVA\segmentsDatabase\tghXjom3120_t=1324.mp4');
% load people detector model:
peopleDetector = RCNNModl;
ind = 0;
bbox = cell(2,1);
score = cell(2,1);
while hasFrame(v)
    ind = ind+1;
    vidFrame = readFrame(v);
    [currBbox, currScore, currLabel] = detect(RCNNModl, vidFrame);
    bbox{ind}  = currBbox;
	score{ind} = currScore;
    if ~isempty(bbox{ind})
        detectedImg = insertShape(vidFrame, 'rectangle', bbox{ind});
    else
        detectedImg = vidFrame;
    end
    figure(1); imshow(detectedImg);
    title(['frame no. ', num2str(ind)]);
end
