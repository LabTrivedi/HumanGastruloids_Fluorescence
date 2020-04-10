function [Ch_merge] = GettingMergedImage(filename,Chindices, Mchannels)
%%********************************************************
%% Showing all images together
A=char(filename);
info = imfinfo(A);
Ch1 = imread(A, Chindices(1), 'Info', info);%Image in channel 1 (preferably BF)
%ChA_normalized = zeros(size(Ch1,1),size(Ch1,2),Mchannels); % This stores the normalized channel voxel values for all teh selected ROIs (boxes)


ChA_RGB1 = zeros(size(Ch1,1),size(Ch1,2)); % This stores the Red channel in the RGB image for showing overlayed image
ChA_RGB2 = zeros(size(Ch1,1),size(Ch1,2)); % This stores the Green channel in the RGB image for showing overlayed image
ChA_RGB3 = zeros(size(Ch1,1),size(Ch1,2)); % This stores the Blue  channel in the RGB image for showing overlayed image

for m = 2:Mchannels
    ImageA = double(imread(A, Chindices(m), 'Info', info));
    
    if (m ==2)
        ChA_RGB2 = ChA_RGB2 + ImageA;
    elseif (m == 3)
        ChA_RGB1 = ChA_RGB1 + ImageA;
    elseif (m == 4)
        ChA_RGB2 = ChA_RGB2 + ImageA;
        ChA_RGB3 = ChA_RGB3 + ImageA;
%         ChA_RGB3 = ChA_RGB3 + ImageA;
%     elseif (m==4)
%          ChA_RGB1 = ChA_RGB1 + ImageA;
%          ChA_RGB2 = ChA_RGB2 + (215/255)*ImageA;


    end
    
end

if (numel(find(ChA_RGB1)>0)>0)
    ChA_RGB1 = ChA_RGB1/(max(ChA_RGB1(:)));
end

if (numel(find(ChA_RGB2)>0)>0)
    ChA_RGB2 = ChA_RGB2/(max(ChA_RGB2(:)));
end

if (numel(find(ChA_RGB3)>0)>0)
    ChA_RGB3 = ChA_RGB3/(max(ChA_RGB3(:)));
end

Ch_merge = cat(3, ChA_RGB1, ChA_RGB2, ChA_RGB3);

clear ChA_RGB1, clear ChA_RGB2, clear ChA_RGB3

%%%%%%%% 



end

