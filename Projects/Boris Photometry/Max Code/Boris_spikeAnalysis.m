function Boris_spikeAnalysis(ephysdata, struct, thresh)

%temp
%thresh = 120;

% Prep & params
window = [20 40];

% manual spike time extraction
putitive_spikes = ephysdata > thresh;
rc = size(putitive_spikes);
RC = rc(1) * rc(2);
spikeVec = reshape(putitive_spikes', 1,RC);

% % create spike window
% for j = 1:length(spikeVec)
%     if spikeVec(j) == 1
%         % block out the rest of spike. Only keep initial detection point
%         spikeVec(j+1:j+window(2)-1) = 0;
%     end
% end

putitive_spikes_mat = vec2mat(spikeVec, struct.segLen);

% x1 bins (raw)
putitive_spikes_mat_x1 = sum(putitive_spikes_mat);
% x2 bins
putitive_spikes_mat_x2 = putitive_spikes_mat_x1(1:2:end) + putitive_spikes_mat_x1(2:2:end);
% x4 bins
putitive_spikes_mat_x4 = putitive_spikes_mat_x2(1:2:end) + putitive_spikes_mat_x2(2:2:end);
% x8 bins
putitive_spikes_mat_x8 = putitive_spikes_mat_x4(1:2:end) + putitive_spikes_mat_x4(2:2:end);


%% plotting
figure()
% subplot(2,1,1)
bar([1:4:struct.segLen]./100, putitive_spikes_mat_x4); hold on
xlim([0 struct.segLen]./100)
% subplot(2,1,2)
%plot(ephysdata'); hold on
% plot(nanmean(ephysdata), 'k');
%hline(thresh, ':k')
xlabel('Seconds')
Boris_figureCosmetics



end
