%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%% This code is a modification of the original code written by         %%%
%%% Arianne Bercowsky Rama                                              %%%
%%%                                                                     %%%
%%% Copyright (c)2020, Vikas Trivedi (trivedi@embl.es)                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




function [loc] = get_image_point (I, Real_Image)
figure('name','Doubleclick to set location');imshow(imfuse(I, Real_Image,'montage'));
[c r] = getpts(1);
loc = int32([c r]);
if size(loc)>1
    loc = [loc(1,1) loc(1,2)];
end
close all;
end
