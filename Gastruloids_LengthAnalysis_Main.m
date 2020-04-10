
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The purspose of this code is to                                     %%%
%%%     (1) Read a tif file containing multi-channel image from a       %%%
%%%         gastruloid and quantify its intesnity profile               %%%
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
%%% 2018/08/01 VT Created the document
%%% 2018/08/18 VT edited the document to incorporate finalplotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



clc
clf
clear all
close all


display('******************************************')
display('Script Gastruloids_LengthAnalysis.m is running')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Script setup (Taking inputs about the image to be read)

filenameforSIBACK = '/Users/vikastrivedi/Desktop/for_vikas/4_72h.tif';
pathnameforoutput = '/Users/vikastrivedi/Desktop/for_vikas/Kerim_LengthAnalysis_Output/';
filename_coreforoutput = '2018-08-01_RUES2';

prompt={'Brightest multi- channel Image file (.tif) name','Number of analysis channels to be used for read-out/read-in','Index for each analysis channel','Label for each analysis channel','Number of distinct samples', 'Number of stages','Bin Size','Stage Labels','Disk (smoothing) radius','Channel to be used for alignment'};
prompt_title = 'Inputs to the code';
defaultans = {filenameforSIBACK,'4','[1,2,3,4]','BF,Sox2,Sox17,Bra','3','1','[3 3]','[24,48,72]','25','3'};
num_lines = 1;
options.Interpreter = 'tex';
answer1 = inputdlg(prompt,prompt_title,num_lines,defaultans,options);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Storing the inputs
Mchannels = str2num(answer1{2}); % Specify the number of analysis channels to be used for read-out/read-in: must be less than or equal to the number of channels in the image file
Chindices = str2num(answer1{3});

NDistinctsamples = str2num(answer1{5});
NDistinctStages = str2num(answer1{6});

BinSize_xy = str2num(answer1{7});
Voxelsize = 1/BinSize_xy(1); % Where imresize(A, Voxelsize) returns image B that is Voxelsize times the size of A

StageNames = str2num(answer1{8});
DiskSmooth_radius = str2num(answer1{9});

Channelofchoice = str2num(answer1{10}); % This is the channel for reorientation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Specifying figure layout and color schemes

figurewidthinches = 6;
figureheightinches = 6;

cc_channels = jet(10); % this is assuming that someone will generate a 10 colored image
cc_channels(1,:) = [0 0 0]; % This is BF in black
cc_channels(2,:) = [0.1 0.9 0.05]; % This is sox2 in green
cc_channels(3,:) = [1 0 0]; % This is sox17 in red
cc_channels(4,:) = [0 0.9 0.9]; % This is T/Bra in cyan
cc_channels(5,:) = [255 215 0]/255; %Yellow
cc_channels(6,:) = [1 0 1]; %magenta
cc_channels(7,:) = [0 0 1]; %blue



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculating the background values and the maxima for each channel

display('***')
display('Step: Chosing the backgrounds .... Started')

%%% Choice 1: USE a GUI to select values 
 [Chlabels,maxvalueChs,minvalueChs] = GetBackground(answer1{1},str2num(answer1{2}),str2num(answer1{3}),answer1{4},str2num(answer1{7}),figurewidthinches,figureheightinches,cc_channels);


%%% Choice 2: fix teh values manually
% Chlabels = {'BF','Sox2','Sox17','Bra'};
% maxvalueChs = [1627 4527 3312 1347];
% minvalueChs = [1405 3290 1267 472];




IntensityNormalizationfactor = maxvalueChs- minvalueChs;



display('***')
display('Step: Chosing the backgrounds .... Completed')





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculating the details for each image from the total of NDistinctsamples for each of the NDistinctStages


display('***')
display('Step: Plotting Line profiles for each image .... Started')


MinorAxis_all = zeros(NDistinctStages,NDistinctsamples);
MajorAxis_all = zeros(NDistinctStages,NDistinctsamples);
Ellipticity_all = zeros(NDistinctStages,NDistinctsamples);


NormalizedIntensityrange_lengthwise_all = zeros(NDistinctStages,NDistinctsamples,Mchannels,1448); % 1024*sqrt(2) is the maximum frame size.
%Positivepixels_lengthwise_all = zeros(NDistinctStages,NDistinctsamples,Mchannels,1448); % 1024*sqrt(2) is the maximum frame size.
 StartEndRowindex_all = zeros(NDistinctStages,NDistinctsamples,2); % 1= start_row index ; 2= end_row index

for nstages = 1:NDistinctStages;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Defining stage specific suffixes and prefixes for file names
    if (nstages ==1)
        filename_prefix ='/Users/vikastrivedi/Desktop/for_vikas/';
        filename_suffix = '_24h.tif';
    elseif (nstages ==2)
        filename_prefix ='/Users/vikastrivedi/Desktop/for_vikas/';
        filename_suffix = '_48h.tif';
    else
        filename_prefix ='/Users/vikastrivedi/Desktop/for_vikas/';
        filename_suffix = '_72h.tif';
    end
    
    
    
    for nsamples = 1:NDistinctsamples;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Defining file name
        filename_final = strcat(filename_prefix,num2str(nsamples),filename_suffix);
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Obtaining line profiles for each channel
        [Intensityrange_lengthwise,Positivepixels_lengthwise, start_row,end_row, Length_MajorAxis, Length_MinorAxis,rotatedCh_merge,rotatedBinary] = GetIntensityProfiles(filename_final,Chindices,minvalueChs,Mchannels,DiskSmooth_radius,Channelofchoice);
        if ((end_row-start_row)>0)
        
        MinorAxis_all(nstages,nsamples) = Length_MinorAxis;
        MajorAxis_all(nstages,nsamples) = Length_MajorAxis;
        Ellipticity_all(nstages,nsamples) = Length_MajorAxis/Length_MinorAxis;
        
        StartEndRowindex_all(nstages,nsamples,1) = start_row;
        StartEndRowindex_all(nstages,nsamples,2) = end_row;
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Plotting rotated images
        
        %          rotatedBWoutline_merge= cat(3,uint8(255*rotatedBWoutline),uint8(255*rotatedBWoutline),uint8(255*rotatedBWoutline));
        %          %I_together = cat(2,rotatedCh_merge,rotatedBWoutline_merge);
        %         I_together = imfuse(rotatedCh_merge,rotatedBWoutline_merge);
        %
        
        if (nsamples < 21)
            figurenumberforimages = 100*nstages+11;
            subplotindexminus = 0;
        elseif (nsamples < 41)
            figurenumberforimages = 100*nstages+12;
            subplotindexminus = 20;
        elseif (nsamples < 61)
            figurenumberforimages = 100*nstages+13;
            subplotindexminus = 40;
        elseif (nsamples < 81)
            figurenumberforimages = 100*nstages+14; 
            subplotindexminus = 60;
        else
            figurenumberforimages = 100*nstages+15;
            subplotindexminus = 80;
        end
        
        
        
        
        
        figure(figurenumberforimages)
        set(gcf,'Units','inches')
        pos = get(gcf,'pos');
        set(gcf,'pos',[pos(1) pos(2) 3*figurewidthinches 2*figureheightinches])
        
        subplot(4,5,nsamples-subplotindexminus)
        imshow(rotatedCh_merge,[],'Border', 'tight'), hold on
        
        
        
        figure(figurenumberforimages+5)
        set(gcf,'Units','inches')
        pos = get(gcf,'pos');
        set(gcf,'pos',[pos(1) pos(2) 3*figurewidthinches 2*figureheightinches])
        
        subplot(4,5,nsamples-subplotindexminus)
        imshow(rotatedBinary,[],'Border', 'tight'), hold on

        clear rotatedCh_merge, clear rotatedBWoutline
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Plotting line profiles for each channel
        
        for m = 2:Mchannels
            Intensityrange_lengthwise_m = Intensityrange_lengthwise(m,:);
            Positivepixels_lengthwise_m = Positivepixels_lengthwise(m,:);
            
            %Ndatapoints_lengthwise = length(Intensityrange_lengthwise_m);
            
            %Intensityrange_lengthwise_all(nstages,nsamples,m,start_row:end_row) = Intensityrange_lengthwise_m;
            %Positivepixels_lengthwise_all(nstages,nsamples,m,1:Ndatapoints_lengthwise) = Positivepixels_lengthwise_m;

            NormalizedIntensityrange_lengthwise_all(nstages,nsamples,m,start_row:end_row) = (Intensityrange_lengthwise_m(start_row:end_row)/IntensityNormalizationfactor(m))./Positivepixels_lengthwise_m(start_row:end_row);
            
            PlotIntensityProfiles(100*nstages+3, 1000, NDistinctStages, nstages, end_row, start_row, Intensityrange_lengthwise_m,Positivepixels_lengthwise_m,m,cc_channels,Chlabels,figurewidthinches,figureheightinches,IntensityNormalizationfactor)
       
        end   
        end
        
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Saving the figures
    
    
    for g = 1:figurenumberforimages-(100*nstages)-10 % this is to store all the figures with images
        
        filename_output1 = strcat(pathnameforoutput, filename_coreforoutput, '_RotatedImages_',num2str(StageNames(nstages)),'h_',num2str(g));
        filename_output2 = strcat(pathnameforoutput, filename_coreforoutput, '_RotatedMasks_',num2str(StageNames(nstages)),'h_',num2str(g));
        
        
        figure(100*nstages+10+g)
        saveas(gcf,strcat(filename_output1,'.pdf'))
        saveas(gcf,strcat(filename_output1,'.fig'))
        
        figure(100*nstages+10+g+5)
        saveas(gcf,strcat(filename_output2,'.pdf'))
        saveas(gcf,strcat(filename_output2,'.fig'))
        
    end
    
    
    filename_output3 = strcat(pathnameforoutput, filename_coreforoutput, '_Rawprofiles_',num2str(StageNames(nstages)),'h');
    
    figure(100*nstages+3)
    saveas(gcf,strcat(filename_output3,'.pdf'))
    saveas(gcf,strcat(filename_output3,'.fig'))
    
    
end


filename_output4 = strcat(pathnameforoutput, filename_coreforoutput, '_NormalizedProfiles_AllStages');
figure(1000)
saveas(gcf,strcat(filename_output4,'.pdf'))
saveas(gcf,strcat(filename_output4,'.fig'))    
    
display('***')
display('Step: Plotting Line profiles for each image .... Completed')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prompting teh window to learn about action at each stage

[SamplestoIgnore, SamplestoFlip] = SpecifySampleAction(StageNames,NDistinctStages);
 
[NormalizedIntensityrange_lengthwise_resampled_all] = PlotFinalIntensityProfiles(3000, 4000, 2000, NDistinctStages, NDistinctsamples, Mchannels, MajorAxis_all,MinorAxis_all,NormalizedIntensityrange_lengthwise_all, StartEndRowindex_all, SamplestoIgnore, SamplestoFlip, cc_channels,Chlabels,figurewidthinches,figureheightinches);


filename_output5 = strcat(pathnameforoutput, filename_coreforoutput, '_AxesMeasurements');
figure(2000)
saveas(gcf,strcat(filename_output5,'.pdf'))
saveas(gcf,strcat(filename_output5,'.fig'))


filename_output6 = strcat(pathnameforoutput, filename_coreforoutput, '_CorrectedNormalizedProfiles_AllStages');
figure(3000)
saveas(gcf,strcat(filename_output6,'.pdf'))
saveas(gcf,strcat(filename_output6,'.fig'))

filename_output7 = strcat(pathnameforoutput, filename_coreforoutput, '_CorrectedResampledNormalizedProfiles_AllStages');
figure(4000)
saveas(gcf,strcat(filename_output6,'.pdf'))
saveas(gcf,strcat(filename_output6,'.fig'))

filename_output8 = strcat(pathnameforoutput, filename_coreforoutput, '_CorrectedResampledNormalizedProfiles_AllStages.mat');
save(filename_output8, 'NormalizedIntensityrange_lengthwise_resampled_all')

display('******************************************')
display('Script Gastruloids_LengthAnalysis.m is Completed')


