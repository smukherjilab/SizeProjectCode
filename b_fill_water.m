%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% READ ME
%
% - input: raw field of view of cells
% - output: binary field of view ready for segmentation
%
%  You'll notice a bunch of "bw = I > something" in there. Basically, many
% fields of views have different pixel values/noise frequencies, so I've
% been adjusting this parameter by eye. I'll leave in the ones I used so 
% you have an idea of what's reasonable. However, I'm using camera images,
% so yours might be very different
%
% Most of the code in this file is necessary because of the craters in the
% cells. Since we're using YFP to label cells, the cells themselves aren't
% homogeneous, so I had to throw in some stuff to get deal with that. 
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bw4 = b_fill_water(raw_image)   
    
    filt = laplace(raw_image);
    I = imfill(filt,26,'holes');
    
    I = imgaussfilt(I,2.5, 'FilterSize',[5 5]);
    %bw = I > 0.013; for golgi
%     bw = I > 0.0138; % for perox 61-62,72

%     bw = I > 0.023; % for perox 69
    bw = I > 0.04;
    
%     bw = raw_image > 1250;
    bw = imfill(bw,26,'holes');
% %     
    bw = ~bwareaopen(~bw,20);
    D = -bwdist(~bw);
    mask=imextendedmin(D,2);
    D2 = imimposemin(D,mask);
    Ld2 = watershed(D2);
    bw2 = bw;
    bw2(Ld2 ==0) = 0;
    
%     se = strel('disk',7); for golgi
%     se = strel('disk',5);
    
%     bw3 = imclose(bw2,se);

%     bw3 = imclose(bw2,strel('disk',5));
    bw3 = imfill(bw2,'holes');
%     
    bw3 = ~bwareaopen(~bw3,20);
    D3 = -bwdist(~bw3);
    mask3=imextendedmin(D3,2);
    D4 = imimposemin(D,mask3);
    Ld3 = watershed(D4);
    bw4 = bw3;
    bw4(Ld3 ==0) = 0;
    
%     
%   % old way: 
%   figure,imshow(bw2)
  
  %raw_image(raw_image < noise_level) = 0; % mito: 30
  %T = adaptthresh(raw_image, 'NeighborhoodSize', [11 11]);  
  % bw = imfill(imbinarize(raw_image, T), 'holes');
end