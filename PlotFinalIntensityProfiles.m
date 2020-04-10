function [NormalizedIntensityrange_lengthwise_resampled_all] = PlotFinalIntensityProfiles(figure2, figure3, figure1, NDistinctStages, NDistinctsamples, Mchannels, MajorAxis_all,MinorAxis_all,NormalizedIntensityrange_lengthwise_all, StartEndRowindex_all, SamplestoIgnore, SamplestoFlip, cc_channels,Chlabels,figurewidthinches,figureheightinches)

ResamplingVectorLength = 201;

NormalizedIntensityrange_lengthwise_resampled_all = zeros(NDistinctStages, NDistinctsamples, Mchannels, ResamplingVectorLength);

figure(figure2)
set(gcf,'Units','inches')
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 1.5*figurewidthinches 1.5*figureheightinches])

figure(figure3)
set(gcf,'Units','inches')
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 1.5*figurewidthinches 1.5*figureheightinches])

for nstages = 1:NDistinctStages;
    DeletableIndices = [];
    SampleIndices = 1:NDistinctsamples;
    
    if sum(SamplestoFlip(nstages,:)>0)>0 %This is to check if the matrix is empty
        FlipSamples = SamplestoFlip(nstages,SamplestoFlip(nstages,:)>0);
        
        for i = 1:length(FlipSamples)
            for m = 1:Mchannels
                A = NormalizedIntensityrange_lengthwise_all(nstages,FlipSamples(i),m,:);
                B = reshape(A,[1,length(A)]);
                NormalizedIntensityrange_lengthwise_all(nstages,FlipSamples(i),m,:) = fliplr(B);
                clear A
                clear B
            end
            
            start_row = StartEndRowindex_all(nstages,FlipSamples(i),1);
            end_row = StartEndRowindex_all(nstages,FlipSamples(i),2);
            StartEndRowindex_all(nstages,FlipSamples(i),1) = 1448 - end_row + 1;
            StartEndRowindex_all(nstages,FlipSamples(i),2) = 1448 - start_row + 1;
            
            clear start_row, clear end_row
        end
    end
    
    
    
    EmptySamples = find(MajorAxis_all(nstages,:)==0); % Finding empty frames
    if ~isempty(EmptySamples)
        DeletableIndices = [DeletableIndices EmptySamples];
    end
    
    if sum(SamplestoIgnore(nstages,:)>0)>0 %This is to check if the matrix is empty
        IgnoreSamples = SamplestoIgnore(nstages,SamplestoIgnore(nstages,:)>0);
        DeletableIndices = [DeletableIndices IgnoreSamples];
    end
    
    if ~isempty(DeletableIndices)
        SampleIndices(DeletableIndices) =[]; % Deleting unwanted sample indices
    end
    
    TotalNonzeroSamples = length(SampleIndices);
    
    
    for nsamples_count = 1:length(SampleIndices);
        
        nsamples = SampleIndices(nsamples_count);
        start_row = StartEndRowindex_all(nstages,nsamples,1);
        end_row = StartEndRowindex_all(nstages,nsamples,2);
        GastruloidLength = end_row-start_row+1;
        
        for m = 2:Mchannels
            
            NormalizedIntensityrange_lengthwise_m_temp = NormalizedIntensityrange_lengthwise_all(nstages,nsamples,m,start_row:end_row);
            
            NormalizedIntensityrange_lengthwise_m = reshape(NormalizedIntensityrange_lengthwise_m_temp,[1,length(NormalizedIntensityrange_lengthwise_m_temp)]);
            
            NormalizedIntensityrange_lengthwise_resampled_m = resample(NormalizedIntensityrange_lengthwise_m,(0:(GastruloidLength-1))/GastruloidLength,ResamplingVectorLength);
            
            NormalizedIntensityrange_lengthwise_resampled_all(nstages,nsamples,m,:) = NormalizedIntensityrange_lengthwise_resampled_m;
            
            
            figure(figure2)
            subplot(NDistinctStages,3,3*(nstages-1) + m-1)
            p1 = plot((0:(GastruloidLength-1))/GastruloidLength,NormalizedIntensityrange_lengthwise_m,'Color',cc_channels(m,:)); hold on, grid on,
            p1.Color(4) = 0.3;
            axis square,% axis equal,%axis([0 1 0 1])
            xlabel('Normalized Length','FontSize',6), ylabel(strcat('Normalized Intensity',Chlabels{m}),'FontSize',6)
            set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1])
            set(gca,'XTickLabel',{'0','','','','','1'})
            set(gca,'FontSize',6);
            
            figure(figure3)
            subplot(NDistinctStages,3,3*(nstages-1) + m-1)
            p1 = plot(0:(1/(ResamplingVectorLength-1)):1,NormalizedIntensityrange_lengthwise_resampled_m,'Color',cc_channels(m,:)); hold on, grid on,
            p1.Color(4) = 0.3;
            axis square,% axis equal,%axis([0 1 0 1])
            xlabel('Normalized Length','FontSize',6), ylabel(strcat('Normalized Intensity',Chlabels{m}),'FontSize',6)
            set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1])
            set(gca,'XTickLabel',{'0','','','','','1'})
            set(gca,'FontSize',6);
 
        end
        
    end
    
    
    for m = 2:Mchannels
        
        %MeanIntensity_resampled_m_temp = mean(NormalizedIntensityrange_lengthwise_resampled_all(nstages,:,m,:),2);
        MeanIntensity_resampled_m_temp = (sum(NormalizedIntensityrange_lengthwise_resampled_all(nstages,:,m,:),2))/TotalNonzeroSamples;
        
        MeanIntensity_resampled_m = reshape(MeanIntensity_resampled_m_temp,[1,length(MeanIntensity_resampled_m_temp)]);
        
        figure(figure3)
        subplot(NDistinctStages,3,3*(nstages-1) + m-1)
        plot(0:(1/(ResamplingVectorLength-1)):1,MeanIntensity_resampled_m,'Color',cc_channels(m,:),'linewidth',2); hold on, grid on,
        clear MeanIntensity_resampled_m_temp
        clear MeanIntensity_resampled_m

    end
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Plotting axes lengths and their ratios
    figure(figure1)
    
    set(gcf,'Units','inches')
    pos = get(gcf,'pos');
    set(gcf,'pos',[pos(1) pos(2) figurewidthinches 0.5*figureheightinches])
    
    xvalueforbar = 2*nstages - 1;
    
    
    
     MinorAxis_all_toplot = MinorAxis_all(nstages,:);
     MajorAxis_all_toplot = MajorAxis_all(nstages,:);
     
     
     if ~isempty(DeletableIndices)
        MinorAxis_all_toplot(DeletableIndices) =[]; % Deleting unwanted sample indices
        MajorAxis_all_toplot(DeletableIndices) =[]; % Deleting unwanted sample indices
     end
     
     NDistinctsamples_new = length(MinorAxis_all_toplot);
     
     
    %%% Plotting statistics for minor axis
    subplot(1,2,1)
    
    bar(xvalueforbar-0.25,mean(MinorAxis_all_toplot),0.45,'FaceColor',[0.75 0.75 0.75],'EdgeColor',[0.4 0.4 0.4]); %Plot the mean bar 
    hold on
    errorbar(xvalueforbar-0.25,mean(MinorAxis_all_toplot),std(MinorAxis_all_toplot)) %Plot the error bar 
    plot((xvalueforbar-0.25)*ones(NDistinctsamples_new,1),MinorAxis_all_toplot,'ko');% Plot the raw data points
    axis square
    xlim([0 2*NDistinctStages])
    
    %%% Plotting statistics for major axis
    subplot(1,2,1)
    bar(xvalueforbar+0.25,mean(MajorAxis_all_toplot),0.45,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.4 0.4 0.4]); %Plot the mean bar 
    hold on
    errorbar(xvalueforbar+0.25,mean(MajorAxis_all_toplot),std(MajorAxis_all_toplot)) %Plot the error bar 
    plot((xvalueforbar+0.25)*ones(NDistinctsamples_new,1),MajorAxis_all_toplot,'ko');% Plot the raw data points
    axis square
    xlim([0 2*NDistinctStages])
    
    %%% Plotting statistics for ellipticity
    
    mean_Ellipticity_all = mean(MajorAxis_all_toplot)/mean(MinorAxis_all_toplot);
    std_Ellipticity_all = mean_Ellipticity_all*sqrt((std(MajorAxis_all_toplot)/mean(MajorAxis_all_toplot))^2 + (std(MinorAxis_all_toplot)/mean(MinorAxis_all_toplot))^2);
    
    subplot(1,2,2)
    bar(nstages,mean_Ellipticity_all,'FaceColor',[0.75 0.75 0.75],'EdgeColor',[0.4 0.4 0.4]); %Plot the mean bar 
    hold on
    errorbar(nstages,mean_Ellipticity_all,std_Ellipticity_all) %Plot the error bar 
    plot(nstages*ones(NDistinctsamples_new,1),MajorAxis_all_toplot./MinorAxis_all_toplot,'ko');% Plot the raw data points
    axis square
    xlim([0.5 NDistinctStages+ 0.5])
    
    
    
%     %%% Plotting statistics for minor axis
%     subplot(1,2,1)
%     
%     bar(xvalueforbar-0.25,mean(MinorAxis_all(nstages,:)),0.45,'FaceColor',[0.75 0.75 0.75],'EdgeColor',[0.4 0.4 0.4]); %Plot the mean bar 
%     hold on
%     errorbar(xvalueforbar-0.25,mean(MinorAxis_all(nstages,:)),std(MinorAxis_all(nstages,:))) %Plot the error bar 
%     plot((xvalueforbar-0.25)*ones(NDistinctsamples,1),MinorAxis_all(nstages,:),'ko');% Plot the raw data points
%     axis square
%     xlim([0 2*NDistinctStages])
%     
%     %%% Plotting statistics for major axis
%     subplot(1,2,1)
%     bar(xvalueforbar+0.25,mean(MajorAxis_all(nstages,:)),0.45,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.4 0.4 0.4]); %Plot the mean bar 
%     hold on
%     errorbar(xvalueforbar+0.25,mean(MajorAxis_all(nstages,:)),std(MajorAxis_all(nstages,:))) %Plot the error bar 
%     plot((xvalueforbar+0.25)*ones(NDistinctsamples,1),MajorAxis_all(nstages,:),'ko');% Plot the raw data points
%     axis square
%     xlim([0 2*NDistinctStages])
%     
%     %%% Plotting statistics for ellipticity
%     
%     mean_Ellipticity_all = mean(MajorAxis_all(nstages,:))/mean(MinorAxis_all(nstages,:));
%     std_Ellipticity_all = mean_Ellipticity_all*sqrt((std(MajorAxis_all(nstages,:))/mean(MajorAxis_all(nstages,:)))^2 + (std(MinorAxis_all(nstages,:))/mean(MinorAxis_all(nstages,:)))^2);
%     
%     subplot(1,2,2)
%     bar(nstages,mean_Ellipticity_all,'FaceColor',[0.75 0.75 0.75],'EdgeColor',[0.4 0.4 0.4]); %Plot the mean bar 
%     hold on
%     errorbar(nstages,mean_Ellipticity_all,std_Ellipticity_all) %Plot the error bar 
%     plot(nstages*ones(NDistinctsamples,1),Ellipticity_all(nstages,:),'ko');% Plot the raw data points
%     axis square
%     xlim([0.5 NDistinctStages+ 0.5])
    
end
    
    
    
    
    
    
end

