function [writeVid, fps] = extract1secSegments(memberVid, midT, src_dir)

existPruned  = struct2cell(dir('../prunedVids'));
existPruned  = existPruned(1,:)';

for ii = 1 : length(memberVid)
    
    c = 1;
    cd(src_dir)
    vidName  = memberVid{ii};
    splitvidName  = strsplit(vidName, '.');
    justvidName  = splitvidName{1};
    if ismember([justvidName, '_t=', num2str(midT), '_1sec.mp4'], existPruned)
        writeVid = [];
        continue
    end

    VR = VideoReader(vidName);
    fps = VR.FrameRate;
    VR.CurrentTime = midT - floor(0.5*fps)/fps;

    cd('..\prunedVids')
    FileName = [justvidName, '_t=', num2str(midT), '_1sec.mp4'];
    writeVid = VideoWriter(FileName, 'MPEG-4');
    writeVid.FrameRate = VR.FrameRate;
    open(writeVid);

    while (and(VR.CurrentTime <= midT + floor(0.5*fps)/fps, c <= fps))
        currFrame = readFrame(VR);
        writeVideo(writeVid,currFrame)
        c = c + 1;
    end
    close(writeVid);
    
end


















end

