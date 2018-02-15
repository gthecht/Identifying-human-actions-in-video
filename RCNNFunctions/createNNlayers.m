function [layers] = createNNlayers(labels)
% currently we'll use alexnet and just change the output:
alex = alexnet; 
% Review Network Architecture 
layers = alex.Layers
% Modify Pre-trained Network 
% AlexNet was trained to recognize 1000 classes, we need to modify it to
% recognize n classes.
layers(23) = fullyConnectedLayer(length(labels) + 1); % change this based on # of classes + background
layers(25) = classificationLayer()
end

