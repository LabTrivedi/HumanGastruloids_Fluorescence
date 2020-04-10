function [] = PlotIntensityProfiles(figure1, figure2, NDistinctStages, nstages, end_row, start_row, Intensityrange_lengthwise_m,Positivepixels_lengthwise_m,m,cc_channels,Chlabels,figurewidthinches,figureheightinches,IntensityNormalizationfactor)


GastruloidLength = end_row-start_row+1;





figure(figure1)
set(gcf,'Units','inches')
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 1.5*figurewidthinches 1.5*figureheightinches])



subplot(3,3,m-1)
plot(0:(end_row-start_row),Intensityrange_lengthwise_m(start_row:end_row),'Color',cc_channels(m,:)), hold on, grid on,
axis square, %axis equal,%axis([0 1 0 1])
xlabel('Length (pixels)','FontSize',6), ylabel(strcat('Total Intensity',Chlabels{m}),'FontSize',6)


figure(figure1)
subplot(3,3,m+2)
plot(0:(end_row-start_row),Intensityrange_lengthwise_m(start_row:end_row)./Positivepixels_lengthwise_m(start_row:end_row),'Color',cc_channels(m,:)), hold on, grid on,
axis square,% axis equal,%axis([0 1 0 1])
xlabel('Length (pixels)','FontSize',6), ylabel(strcat('Normalized Intensity',Chlabels{m}),'FontSize',6)
%                 set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1])
%                 set(gca,'XTickLabel',{'0','','','','','1'})
%                 set(gca,'FontSize',6);
%                 set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1])
%                 set(gca,'YTickLabel',{'0','','','','','1'})
%                 set(gca,'FontSize',6);



figure(figure1)
subplot(3,3,m+5)
plot((0:(GastruloidLength-1))/GastruloidLength, Intensityrange_lengthwise_m(start_row:end_row),'Color',cc_channels(m,:)), hold on, grid on,
axis square, %axis equal,%axis([0 1 0 1])
xlabel('Normalized Length','FontSize',6), ylabel(strcat('Total Intensity',Chlabels{m}),'FontSize',6)
set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1])
set(gca,'XTickLabel',{'0','','','','','1'})
set(gca,'FontSize',6);
%                 set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1])
%                 set(gca,'YTickLabel',{'0','','','','','1'})
%                 set(gca,'FontSize',6);

figure(figure2)
set(gcf,'Units','inches')
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 1.5*figurewidthinches 1.5*figureheightinches])

subplot(NDistinctStages,3,3*(nstages-1) + m-1)
p1 = plot((0:(GastruloidLength-1))/GastruloidLength,(Intensityrange_lengthwise_m(start_row:end_row)/IntensityNormalizationfactor(m))./Positivepixels_lengthwise_m(start_row:end_row),'Color',cc_channels(m,:)); hold on, grid on,
p1.Color(4) = 0.25;
axis square,% axis equal,%axis([0 1 0 1])
xlabel('Normalized Length','FontSize',6), ylabel(strcat('Normalized Intensity',Chlabels{m}),'FontSize',6)
set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1])
set(gca,'XTickLabel',{'0','','','','','1'})
set(gca,'FontSize',6);
%                 set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1])
%                 set(gca,'YTickLabel',{'0','','','','','1'})
%                 set(gca,'FontSize',6);



end

