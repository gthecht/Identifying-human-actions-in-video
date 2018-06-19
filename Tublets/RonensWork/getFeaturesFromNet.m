function [featureMat] = getFeaturesFromNet(net, layer, Tublets)

% This function gets some net and tublets of a video and create a feature
% matrix for each segment in the video which is included in tubelets.

n = size(Tublets, 1);
fps =  size(Tublets{1}, 1);
featureMat = cell(n, 1);

% % layersNames = {net.Layers.Name};
% % ind = find(strcmp(layersNames, layer));
% % sz = net.Layers(ind).OutputSize;
sz = net.Layers(end).OutputSize;    % 'prob' layer doesnt have OutputSize.
junkBox = [0 0 1 1];

for ii = 1:n
    currMat = zeros(fps, sz);
%     disp(['Segment Number ', num2str(ii),' out of ', num2str(n)])
    for jj = 1:fps
        currIm = Tublets{ii}{jj};
        if (size(currIm, 3) == 1)
            currFeatureVec = zeros(1, sz);  % This will represent a junkBox
        else
            currFeatureVec = activations(net, currIm, layer, 'OutputAs', 'rows');
        end
        currMat(jj, :) = currFeatureVec;
    end
    featureMat{ii} = currMat;
end


end

