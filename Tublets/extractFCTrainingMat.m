function [FCfeatureVec] = extractFCTrainingMat(featMat, fps)
% recieves a feature matrix of some size and extracts a smaller - K*1000
% matrix for the training of the FC.
% The downsizing is done with 
K = 5;
w = 15;
GW = gausswin(w);
convOut = conv2(featMat, GW);
FCfeatureVec = zeros(K, size(featMat, 2));
for kk = 1 : K
    % find closest frame to center of current gaussian:
    t_mu = kk / (K+1);
    fNum = round(t_mu * fps);
    % Now we need to choose the convOut that is in fNum+(w-1)/2:
    FCfeatureVec(kk,:) = convOut(fNum + (w - 1)/2, :);
end
end
