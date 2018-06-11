%% Ronen & Gilad 13 May 2018
% Create tublets from video using optimal IOU:

% we take the video and the boxes therein, and then find the boxes in the
% neighboring frames with the largest IOU for every frame. Not that
% neighbors can be of first second or third degree.
% Next we need to smoothen the tublets, and also decide which are the best
% ones.
clear; clc;
%% Load vidTable - of boxes in frames:
% The following table holds the boxes found with peopleDetector in each
% frame of a given video-segment:
boxTable = uigetfile('*.m', 'video boxes table');
len      = length(boxTable);
tubes = IOUTubletor(boxTable, kNeighbor);
