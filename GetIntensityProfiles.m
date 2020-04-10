function [Intensityrange_lengthwise,Positivepixels_lengthwise, start_row,end_row, Length_MajorAxis, Length_MinorAxis,rotatedCh_merge, rotatedBinary] = GetIntensityProfiles(filename_final,Chindices,minvalueChs,Mchannels,DiskSmooth_radius,Channelofchoice)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Obtaining the mask of original image


A=char(filename_final);
info = imfinfo(A);

I_BF = imread(A, Chindices(1), 'Info', info); %Image in channel m
sigma = 2;

I = imgaussfilt(I_BF,sigma); % Smooth the image
[BWoutline,BWfinal] = GetBWSegmentation(I,DiskSmooth_radius); % First segmentation approach

BWfinal = ~BWfinal; % Changing the gastruloid into binary image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Obtaining the stats on tehe original image

stats_all = regionprops(BWfinal,'MajorAxisLength','MinorAxisLength','Orientation');

if (numel(stats_all)<1)
    start_row = 0;
    end_row = 0;
    Length_MajorAxis = 0;
    Length_MinorAxis = 0;
    rotatedCh_merge = zeros(size(I_BF));
    rotatedBinary = zeros(size(I_BF));
    Intensityrange_lengthwise = zeros(Mchannels,size(I_BF,1));
    Positivepixels_lengthwise= zeros(Mchannels,size(I_BF,1)); 
    return
else
    stats = stats_all(1);
end

    
    

% Calculate the major and minor axis ratio
Length_MajorAxis = stats.MajorAxisLength;
Length_MinorAxis = stats.MinorAxisLength;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Obtaining the mask of a preliminary rotated image
% Rotate Image: To have them all vertically aligned
angle = 90 - stats.Orientation;
rotatedBinary = imrotate(BWfinal, angle);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Use a fluorescent channel to correct orientation

[x, y] = find(rotatedBinary);
start_row = min(x);
end_row = max(x); % This is equivalent to the Major Axis Length

I_Choice = imread(A, Chindices(Channelofchoice), 'Info', info); %Image in channel m
rotatedChoice = imrotate(I_Choice, angle);
rotatedChoice = rotatedChoice - minvalueChs(Channelofchoice); % Remove background
rotatedChoice(rotatedChoice <0) = 0; % Change negative pixels to 0

rotatedMaskedChoice = uint16(rotatedBinary).*rotatedChoice;
NormIntensityrange_lengthwise_temp = sum(rotatedMaskedChoice,2)./sum(rotatedBinary,2);
MaximaIndex = find(NormIntensityrange_lengthwise_temp==max(NormIntensityrange_lengthwise_temp));
Centroidoflength = (start_row + end_row)/2;
if (Centroidoflength < MaximaIndex) % i.e. COM of gastruloid is above the pole i.e. in the top is Anterior and bottom posterior
    Reorientationfactor = 0;
else
    Reorientationfactor = 180;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Finally rotate the image correctly

angle = 90 - stats.Orientation + Reorientationfactor;
rotatedBinary = imrotate(BWfinal, angle);

rotatedOriginal = imrotate(I_BF, angle);
%stats_rotated_all =  regionprops(rotatedBinary,'Centroid','Orientation','MajorAxisLength','MinorAxisLength');
Ch_merge = GettingMergedImage(filename_final,Chindices, Mchannels);


rotatedCh_merge = imrotate(Ch_merge, angle);
rotatedBWoutline = imrotate(BWoutline, angle);
%     figure(100), subplot(2,2,1), imshow(BWfinal,[])
%     figure(100), subplot(2,2,2), imshow(BWoutline,[])
%     figure(100), subplot(2,2,3), imshow(rotatedBinary,[])
%     figure(100), subplot(2,2,4), imshow(rotatedOriginal,[])

%stats_rotated = stats_rotated_all(1);
[x, y] = find(rotatedBinary);
start_row = min(x);
end_row = max(x); % This is equivalent to the Major Axis Length

Intensityrange_lengthwise = zeros(Mchannels,size(rotatedOriginal,1));
Positivepixels_lengthwise= zeros(Mchannels,size(rotatedOriginal,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Transfer the mask to other channels to get statistics
for m = 2:Mchannels
    
    I_Ch = imread(A, Chindices(m), 'Info', info); %Image in channel m
    rotatedCh = imrotate(I_Ch, angle);
    rotatedCh = rotatedCh - minvalueChs(m); % Remove background
    rotatedCh(rotatedCh <0) = 0; % Change negative pixels to 0
    rotatedMaskedCh = uint16(rotatedBinary).*rotatedCh;
    Intensityrange_lengthwise(m,:) = sum(rotatedMaskedCh,2);
    Positivepixels_lengthwise(m,:)= sum(rotatedBinary,2);
    
end

end

