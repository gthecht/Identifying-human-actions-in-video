function [layers] = createNNlayers(labels)
% currently we'll use alexnet and just change the output:
alex = alexnet; 
vgg  = vgg16;
% Review Network Architecture 
% layers = alex.Layers
layers = vgg.Layers
% Modify Pre-trained Network 
% AlexNet and vgg16 were trained to recognize 1000 classes, we need to modify them to
% recognize n classes.
layers(end - 2) = fullyConnectedLayer(length(labels) + 1); % change this based on # of classes + background
layers(end) = classificationLayer()
end

