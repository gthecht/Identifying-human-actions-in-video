function [dataTable, countCut] = FindCutVid(threshpatch, thresh,...
                                            edges, patchSize)

% This function intends to detect either in some video there is some cut
% scene or not. if it does, we take only the part before the cut if it
% happened after the middle frame, and the second part if it happened
% before that frame.
% At the end of this function the output will be as the following table:
% | vidName | Folder | isCut | Lentgh (num of    | First frame   | New GT  
% |         |        |       | frames in         | (usually 1)   | position
% |         |        |       | original video)   |               |         
% -------------------------------------------------------------------------
% |         |        |       |                   |               |     
% |         |        |       |                   |               |        
% |         |        |       |                   |               |        
% This is  the output dataTable. the output countCut counts the number of
% cuts we detected.
% thresh indicates how we definr a cut scene (x-med)/std>thresh.
% edges indicates the number of bins in the hisogram.

prompt = 'Choose the directory from which you want to check it''s videos';
Qtitle = 'Input';
answer = inputdlg(prompt,Qtitle);
addpath(answer{1});

% taking all the videos and creating a table from them
list = dir(answer{1});
T = struct2table(list);
T(T.isdir==1, :) = [];
n = length(T.isdir);    % Number of videos.

% Create the data table
dataTable = table(T.name, T.folder, zeros(n,1), zeros(n,1), zeros(n,1),...
    zeros(n,1),'VariableNames', {'vidName','Folder','isCut','Length',...
    'NewFirstFrame','GTFrameNum'});

countCut = 0;   % Counts the number of cut videos
fun = @(X) histcounts(X.data, edges);

for ii = 1:n
    h = [];
    histGrad = [];
    cutVec = [];
    
    % Reading a video and extracting some properties
    v = VideoReader(dataTable.vidName{ii});
    W = v.Width;
    H = v.Height;
    Wsplit = floor(W/patchSize);
    Hsplit = floor(H/patchSize);
    sz = patchSize^2;    % size of the patch in the frame
    
    % Reading frame by frame and calculating histogram per patch
    while hasFrame(v)
    video = rgb2gray(readFrame(v));
    N = blockproc(video, [patchSize, patchSize], fun) / sz;
    N = N(1:Hsplit, 1:(Wsplit*edges));
    N = N';
    h = [h; N(:)']; % concatenate the histogram bins one under the other.
    end
    
    histGrad = h(2:end, :) - h(1:end-1, :);
    
    for jj=1:Hsplit*Wsplit
        currhistGrad = histGrad(:, (1+edges*(jj-1)):edges*jj);
        med = median(currhistGrad);
        stanDev = std(currhistGrad);
        val = (currhistGrad - med) ./ stanDev;
        cutted = (abs(val) > threshpatch);
        cuttedSum = sum(cutted, 2);
        iscutted = (cuttedSum >= edges/2);
        iscuttedSum = sum(iscutted);
        cutVec = [cutVec, iscuttedSum>0];
    end
    
    if (sum(cutVec)/length(cutVec) > thresh)
        dataTable.isCut(ii) = 1;
        countCut = countCut + 1;
    end
end


end

