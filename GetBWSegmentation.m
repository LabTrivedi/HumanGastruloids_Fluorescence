%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%% This code is a modification of the original code written by         %%%
%%% Arianne Bercowsky Rama                                              %%%
%%%                                                                     %%%
%%% Copyright (c)2020, Vikas Trivedi (trivedi@embl.es)                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




function [BWoutline,BWfinal] = GetBWSegmentation(I,val)
    
    
    % Mark the Foreground Objects
    se = strel('disk', val);

    % Erosion: 
    Ie = imerode(I, se);
    Iobr = imreconstruct(Ie, I); % Opening by reconstruction

    % Dilation: 
    Iobrd = imdilate(Iobr, se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);

    % Thresholded opening-closing by reconstruction:
    bw = imbinarize(Iobrcbr);
    
    % Erosion:
    seD = strel('diamond',2);
    BWfinal = imerode(bw,seD);
    BWfinal = imerode(BWfinal,seD);

    BWoutline = bwperim(BWfinal);
 
    
end
