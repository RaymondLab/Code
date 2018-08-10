% maximize current figure
function maximize(hf)

if ~exist('hf','var')
    hf = gcf;
end
set(hf,'Units','normalized','outerposition',[0 0 1 1])
drawnow;