function [Chlabels,maxvalueChs,minvalueChs] = GetBackground(filename_bright,Mchannels,Chindices,Chlabels_temp,BinSize_xy,figurewidthinches,figureheightinches,cc_channels)


Voxelsize = 1/BinSize_xy(1); % Where imresize(A, Voxelsize) returns image B that is Voxelsize times the size of A



%********************************************************
%% Finding individual channel labels from the concatenated string Chlabels_temp
CommaIndices = find(Chlabels_temp==',');
indexstart = 1;
Chlabels = {};
for m  = 1:Mchannels-1
    name = Chlabels_temp(indexstart:CommaIndices(m)-1);
    Chlabels{m} = name;
    indexstart = CommaIndices(m)+1;
end

Chlabels{Mchannels} = Chlabels_temp(indexstart:length(Chlabels_temp));

clear Chlabels_temp, clear indexstart , clear CommaIndices



%%********************************************************
%% Select the number of anatomical regions of interest

Nboxes = 2; % Number of ROIs (boxes) that you will draw in the image
w= 200; % Width in pixels of your ROIs
h= 200;% heigh in pixels for your ROIs


cc_boxes = jet(Nboxes); %% Color code for showing scatter points from different boxes
cc_boxes(1,:) = [1 1 1]; % White for background
cc_boxes(2,:) = [1 0 0]; % Red for Signal


maxvalueChs = zeros(Mchannels,1);% This stores the maximum values
minvalueChs = zeros(Mchannels,1);% This stores the minimum values
%%********************************************************
%% Showing all images together
A=char(filename_bright);
info = imfinfo(A);
Ch1 = imread(A, Chindices(1), 'Info', info);%Image in channel 1 (preferably BF)
%ChA_normalized = zeros(size(Ch1,1),size(Ch1,2),Mchannels); % This stores the normalized channel voxel values for all teh selected ROIs (boxes)

% % Showing all the channels
% for m = 1:Mchannels
%
%     ImageA = imread(A, Chindices(m), 'Info', info);
%
%     ImageAv = imresize(double(ImageA),Voxelsize); % Resizing the Channel m box depending upon the voxel size chosen
%
%     figure(1) % raw image. Depicts signal + background for pixels in each analysis channel plus a merge of all analysis channels
%     set(gcf,'Units','inches')
%     pos = get(gcf,'pos');
%     set(gcf,'pos',[pos(1) pos(2) figurewidthinches 5])
%     subplot(1,Mchannels+1,m), imshow(ImageAv,[],'Border', 'tight'), hold on, title(strcat('Ch',num2str(m),':',Chlabels{m}),'color',cc_channels(m,:))
%
% end

[Ch_merge] = GettingMergedImage(filename_bright,Chindices, Mchannels);

% figure(1)
% subplot(1,Mchannels+1,Mchannels+1), imshow(Ch_merge,[],'Border', 'tight'), hold on, title ('Merge')


%********************************************************
%% Select the anatomical regions of interest by drawing boxes




for i=1:Nboxes;
    
    figure(1)
    set(gcf,'Units','inches')
    pos = get(gcf,'pos');
    set(gcf,'pos',[pos(1) pos(2) figurewidthinches figureheightinches])
    imshow(Ch_merge,[],'Border', 'tight'), hold on
    
        curr_fig = imgcf; % Place the Topleft corner of the box
        h1 = imrect;
        h1Details = round(h1.getPosition);
        x = h1Details(1);
        y = h1Details(2);
        w = h1Details(3);
        h = h1Details(4);
    
    for m = 1:Mchannels
        Chm = imread(A, Chindices(m), 'Info', info); %Image in channel m
         ChmSIGG= Chm(y:y+(h-1),x:x+(w-1)); % Extracting the box from channel 1
         ChmA = imresize(double(ChmSIGG),Voxelsize); % Resizing the Channel m box depending upon the voxel size chosen
         if (i ==1)
          minvalueChs(m) = mean(ChmA(:)); % Store the raw channel values
         else
          maxvalueChs(m) = max(max(ChmA)); % Store the raw channel values
         end

         clear Chm, clear ChmSIGG, clear ChmA, clear ChmSIG % Clearing temporary variable for reading another channel on next iteration of m
        
        %     x=round(x); % Rounding off the x coordinate to get an integer value that will correspond to a pixel
        %     y=round(y); % Rounding off the y coordinate to get an integer value that will correspond to a pixel
        
    end
    clear h1
    
end





% for i=1:Nboxes;
%
%     figure(1)
%     curr_fig = imgcf; % Place the Topleft corner of the box
%     [x,y] = getpts(curr_fig); % Recording the x,y coordinates of the top left corner of the box
%     rectangle('Position',[x,y,w,h], 'LineWidth', 2, 'EdgeColor',cc_boxes(i,:)) % Showing the box
%     if (i==1)
%     text(x,y-10,'BACK Region','color',cc_boxes(i,:));
%     else
%         text(x,y-10,'SIG Region ','color',cc_boxes(i,:));
%     end
%
%     x=round(x); % Rounding off the x coordinate to get an integer value that will correspond to a pixel
%     y=round(y); % Rounding off the y coordinate to get an integer value that will correspond to a pixel
%
%
%
%     %%%%%%%
%     % Showing overlayed boxes in figure 2 and storing raw and normalized
%     % voxel values for each channel in each ROI (box)
%     for m = 1:Mchannels
%         Chm = imread(A, Chindices(m), 'Info', info); %Image in channel m
%         ChmSIGG= Chm(y:y+(h-1),x:x+(w-1)); % Extracting the box from channel 1
%         ChmA = imresize(double(ChmSIGG),Voxelsize); % Resizing the Channel m box depending upon the voxel size chosen
%         if (i ==1)
%          minvalueChs(m) = mean(ChmA(:)); % Store the raw channel values
%         else
%          maxvalueChs(m) = max(max(ChmA)); % Store the raw channel values
%         end
%
%         clear Chm, clear ChmSIGG, clear ChmA, clear ChmSIG % Clearing temporary variable for reading another channel on next iteration of m
%     end
%
%
%
% end



close(gcf)

end

