
if ~(struct.special)
    vline(struct.segLen / 4, 'r')
    vline(struct.segLen / 4 * 3, 'r')
    b = ylim;
    text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
    text(struct.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  direction{1} ' Motion' ])
    text(struct.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
    text(struct.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  direction{2} ' Motion' ])
    
else
    % Temp for 'M114_R2_S3'
    b = ylim;
    text(0, ((b(2)-b(1)) * .05) + b(1), '* R Motion')
    vline(struct.segLen / 6, 'r')
    text(struct.segLen / 6, ((b(2)-b(1)) * .05) + b(1), '* Center')
    vline(struct.segLen / 6 * 2, 'r')
    text(struct.segLen / 6 * 2, ((b(2)-b(1)) * .05) + b(1), '* Stop')
    vline(struct.segLen / 6 * 3, 'r')
    text(struct.segLen / 6 * 3, ((b(2)-b(1)) * .05) + b(1), '* L Motion')
    vline(struct.segLen / 6 * 4, 'r')
    text(struct.segLen / 6 * 4, ((b(2)-b(1)) * .05) + b(1), '* Center')
    vline(struct.segLen / 6 * 5, 'r')
    text(struct.segLen / 6 * 5, ((b(2)-b(1)) * .05) + b(1), '* Stop')
    
    % Temp for 'M115_R1_S8'
    b = ylim;
    text(0, ((b(2)-b(1)) * .05) + b(1), '* R Motion')
    vline(struct.segLen / 4, 'r')
    text(struct.segLen / 4, ((b(2)-b(1)) * .05) + b(1), '* Stop')
    vline(struct.segLen / 8, 'r')
    text(struct.segLen / 8, ((b(2)-b(1)) * .05) + b(1), '* Center')
    vline(struct.segLen / 4 * 2, 'r')
    text(struct.segLen / 4 * 2, ((b(2)-b(1)) * .05) + b(1), '* L Motion')
    vline(struct.segLen / 8 * 5, 'r')
    text(struct.segLen / 8 * 5, ((b(2)-b(1)) * .05) + b(1), '* Center')
    vline(struct.segLen / 4 * 3, 'r')
    text(struct.segLen / 4 * 3, ((b(2)-b(1)) * .05) + b(1), '* Stop')
    
    
    % Temp for unique
    b = ylim;
    text(0, ((b(2)-b(1)) * .05) + b(1), ['* ' direction ' Motion'])
    vline(800, 'r')
    text(800, ((b(2)-b(1)) * .05) + b(1), '* Stop')
    
end
