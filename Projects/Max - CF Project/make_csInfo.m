function csInfo = make_csInfo(segData, z)


for f = 1:length(segData(9).data)
    
    csInfo(f).timeAbs_sec = segData(9).data(f);
    csInfo(f).timeAbs_e = round(csInfo(f).timeAbs_sec * z.sr_e);
    csInfo(f).timeAbs_b = round(csInfo(f).timeAbs_sec * z.sr_b);
    
    csInfo(f).timeRel2Mat_sec = segData(9).data(f) - (z.startpt_e/z.sr_e);
    csInfo(f).timeRel2Mat_e = round(csInfo(f).timeRel2Mat_sec * z.sr_e);
    csInfo(f).timeRel2Mat_b = round(csInfo(f).timeRel2Mat_sec * z.sr_b);
    
    csInfo(f).timeRel2Cycle_sec = mod(csInfo(f).timeRel2Mat_sec, z.cycleLen_sec);
    csInfo(f).timeRel2Cycle_e = round(csInfo(f).timeRel2Cycle_sec * z.sr_e);
    csInfo(f).timeRel2Cycle_b = round(csInfo(f).timeRel2Cycle_sec * z.sr_b);

    csInfo(f).cycleNum = ceil(csInfo(f).timeRel2Mat_sec / z.cycleLen_sec);
    
    % remove CS that are before the start of cycle 1
    if csInfo(f).cycleNum < 1
        csInfo(f).cycleNum = nan;
        csInfo(f).usable = 0;
        
    % remove CS that are in last cycle or later
    elseif csInfo(f).cycleNum == size(z.cycleMat_ss,1)
        csInfo(f).usable = 0;
    elseif csInfo(f).cycleNum > size(z.cycleMat_ss,1)
        csInfo(f).cycleNum = nan;
        csInfo(f).usable = 0;
    else
        csInfo(f).usable = 1;
    end
    
    % remove CS that occur after the end of the ephtys (very rare)
    if csInfo(f).timeAbs_sec > z.segLen_s
        csInfo(f).usable = 0;
    end

end

