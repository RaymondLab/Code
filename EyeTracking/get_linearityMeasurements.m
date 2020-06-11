function [mag1, mag2] = get_linearityMeasurements(mag1, mag2)

% Sac Start and End Times
sacEndPoints = diff(~mag1.saccades_all);
goodStarts = find(sacEndPoints == 1);
goodStarts = goodStarts + 1;
goodStops = find(sacEndPoints == -1);

if goodStarts(1) > goodStops(1)
    goodStarts = [0; goodStarts];
elseif goodStarts(end) > goodStops(end)
    goodStops = [goodStops; length(~mag1.saccades_all)];
elseif isempty(goodStarts) && isempty(goodStops)
    disp('No saccades: Cannot calculate piecewise linearity')
    return
end

% Whole segments
mag1.pos_data_all = measureLinearity(mag1.pos_data_aligned_scaledInVel(~mag1.saccades_all), vid.pos_data_upsampled_aligned(~mag1.saccades_all), ~mag1.saccades_all);
mag1.vel_data_all = measureLinearity(mag1.vel_data_aligned_scaledInVel(~mag1.saccades_all), vid.vel_data_upsampled_aligned(~mag1.saccades_all), ~mag1.saccades_all);
mag2.pos_data_all = measureLinearity(mag2.pos_data_aligned_scaledInVel(~mag1.saccades_all), vid.pos_data_upsampled_aligned(~mag1.saccades_all), ~mag1.saccades_all);
mag2.vel_data_all = measureLinearity(mag2.vel_data_aligned_scaledInVel(~mag1.saccades_all), vid.vel_data_upsampled_aligned(~mag1.saccades_all), ~mag1.saccades_all);

% non-saccades, split up into chunks
for i = 1:length(goodStarts)
    chunk = goodStarts(i):goodStops(i);
    mag1.pos_data_chunks(i) = measureLinearity(mag1.pos_data_aligned_scaledInVel(chunk), vid.pos_data_upsampled_aligned(chunk));
    mag1.vel_data_chunks(i) = measureLinearity(mag1.vel_data_aligned_scaledInVel(chunk), vid.vel_data_upsampled_aligned(chunk));
    mag2.pos_data_chunks(i) = measureLinearity(mag2.pos_data_aligned_scaledInVel(chunk), vid.pos_data_upsampled_aligned(chunk));
    mag2.vel_data_chunks(i) = measureLinearity(mag2.vel_data_aligned_scaledInVel(chunk), vid.vel_data_upsampled_aligned(chunk));
end