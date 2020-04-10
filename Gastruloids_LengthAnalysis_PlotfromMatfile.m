%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The purspose of this code is to                                     %%%
%%%     (1) Read a .mat file containing normalized intensities from a
%%%         multi-channel image of a gastruloid and replot it
%%%                                                                     %%%
%%%                                                                     %%%
%%% This code is written by                                             %%%
%%% Vikas Trivedi, PhD                                                  %%%
%%% European Molecular Biology Laboratory (EMBL)                        %%%
%%% PRBB, Dr. Aiguader, 88, 08003 Barcelona, Spain                      %%%
%%% Phone: +34 (0) 93 628 2708                                          %%%
%%% E-Mail: trivedi@embl.es                                             %%%
%%% Webpage: embl.org/trivedi                                           %%%
%%%                                                                     %%%
%%% Please feel free to contact me if you have any questions            %%%
%%%                                                                     %%%
%%% Copyright (c)2020, Vikas Trivedi                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Revision history:
%%% 2018/09/24 VT Created the document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



clc
clf
clear all
close all


display('******************************************')
display('Script Gastruloids_LengthAnalysis_PlotfromMatfile.m is running')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Script setup (Taking inputs about the image to be read)
matfilename = '/Users/vikastrivedi/Desktop/for_vikas/2018-08-30_RUES2_TR_CorrectedResampledNormalizedProfiles_AllStages.mat';
pathnameforoutput = '/Users/vikastrivedi/Desktop/for_vikas/Kerim_LengthAnalysis_Output/';
filename_coreforoutput = '2018-08-01_RUES2';


cc_channels = jet(10); % this is assuming that someone will generate a 10 colored image
cc_channels(1,:) = [0 0 0]; % This is BF in black
cc_channels(2,:) = [0.1 0.9 0.05]; % This is sox2 in green
cc_channels(3,:) = [1 0 0]; % This is sox17 in red
cc_channels(4,:) = [0 0.9 0.9]; % This is T/Bra in cyan
cc_channels(5,:) = [255 215 0]/255; %Yellow
cc_channels(6,:) = [1 0 1]; %magenta
cc_channels(7,:) = [0 0 1]; %blue

StageNames = [24,48,72];
Chlabels = {'BF','Sox2','Sox17','Bra'};




load(matfilename);

Stats_dim = size(NormalizedIntensityrange_lengthwise_resampled_all);

NDistinctStages = Stats_dim(1,1);
NDistinctsamples = Stats_dim(1,2);
Mchannels = Stats_dim(1,3);
ResamplingVectorLength = Stats_dim(1,4);

for nstages = 1:NDistinctStages;
    DeletableIndices = [];
    
    SampleIndices = 1:NDistinctsamples;
    
    for nsamples = 1:NDistinctsamples
        
        if (sum(sum(NormalizedIntensityrange_lengthwise_resampled_all(nstages,nsamples,:,:)))==0)
            DeletableIndices = [DeletableIndices nsamples];
        end
        
    end
    
    if ~isempty(DeletableIndices)
        SampleIndices(DeletableIndices) =[]; % Deleting unwanted sample indices
    end
    
    TotalNonzeroSamples = length(SampleIndices);
    
    
    for nsamples_count = 1:length(SampleIndices);
        
        nsamples = SampleIndices(nsamples_count);
        
        
        for m = 2:Mchannels
            
            
            
            NormalizedIntensityrange_lengthwise_m_temp = NormalizedIntensityrange_lengthwise_resampled_all(nstages,nsamples,m,:);
            
            NormalizedIntensityrange_lengthwise_resampled_m = reshape(NormalizedIntensityrange_lengthwise_m_temp,[1,length(NormalizedIntensityrange_lengthwise_m_temp)]);
            
            clear NormalizedIntensityrange_lengthwise_m_temp
            
            figure(4000)
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
        
        figure(4000)
        subplot(NDistinctStages,3,3*(nstages-1) + m-1)
        plot(0:(1/(ResamplingVectorLength-1)):1,MeanIntensity_resampled_m,'Color',cc_channels(m,:),'linewidth',2); hold on, grid on,
        clear MeanIntensity_resampled_m_temp
        clear MeanIntensity_resampled_m
        
    end
    
end


filename_output = strcat(pathnameforoutput, filename_coreforoutput, '_CorrectedResampledNormalizedProfiles_AllStages');
figure(4000)
saveas(gcf,strcat(filename_output,'.pdf'))
saveas(gcf,strcat(filename_output,'.fig'))


