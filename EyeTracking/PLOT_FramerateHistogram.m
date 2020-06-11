function vars = PLOT_FramerateHistogram(app, vars)

difft1 = diff(vars.vidResults.time1);
difft2 = diff(vars.vidResults.time2);
frametimes = 1./[difft1; difft2];

%% Plot in app
histogram(app.UIAxes4_5, frametimes, 200);
vline(30)
title(app.UIAxes4_5, 'Framerate Histogram (Both Cameras)')
ylabel(app.UIAxes4_5, 'Frame Amount')
xlabel(app.UIAxes4_5, 'Framerate')

%% Plot in figure
hFig = figure('Visible', 'off'); 
set(hFig, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
histogram(frametimes, 200);
vline(30)
title('Framerate Histogram (Both Cameras)')
ylabel('Frame Amount')
xlabel('Framerate')

% Save Figure
set(hFig,'Units','Inches');
pos = get(hFig ,'Position');
set(hFig ,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(hFig, fullfile(cd, 'Summary_CameraFrameRate.pdf'),'-dpdf');
savefig('Summary_CameraFrameRate.fig')