function [frame_dir] = getFrameDir()
% We want to know where the data is. Currently it is either on Gilad's
% desktop, or in the disk-on-key:
hostName = getComputerName();
switch hostName 
    case 'desktop-gloria' % Gilad's desktop
        frame_dir = 'D:\Projects\Project2_AVA\MiddleFrames\';
    otherwise % Not finding any known name, we'll revert to the dok location
        frame_dir = 'Z:\MiddleFrames\';
end
end

