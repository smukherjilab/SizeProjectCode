

% I call this function "b_fill_water" because I use it to binarize, fill holes, and watershed. 
% This is how I usually binarize images of cells for segmentation (I use these binary images to cut out the organelles)

% NOTES: 
% You'll notice a bunch of "bw = I > something" in there. Basically, many
% fields of views have different pixel values/noise frequencies, so I've
% been adjusting this parameter by eye. I'll leave in the ones I used so 
% you have an idea of what's reasonable. However, I'm using camera images,
% so yours might be very different
%
% Most of the code in this file is necessary because of the craters in the
% cells. Since we're using YFP to label cells, the cells themselves aren't
% homogeneous, so I tried to throw in some stuff to get deal with that. 
%


% This code is super ad hoc and I always have to tweak it to work with images that come from different 
% imaging conditions. I'm currently working on training some CNN's to do segmentation for us, but in the meanwhile
% our segmentation is very hands-on

function bw4 = b_fill_water(raw_image)   
    
    % Are you confused that I applied a 2nd derivative (which are very sensitive to noise) before blurring the image?
    % I am too, but it seems to work better
    filt = laplace(raw_image);
    % nuclei etc often block out YFP signal --> cell images have craters in them. "imfill" tries to deal with that
    I = imfill(filt,26,'holes');
    
    % mess with the sigma and filterSize if your binary cells are coming out weird; these are some generally
    % reasonable parameters
    sigma = 6;
    filterSize = [15 15];
    I = imgaussfilt(I,sigma, 'FilterSize',filterSize);

    % you'll have to change this threshold number too
    bw = I > 0.017;
    
    % try to fill the holes AGAIN
    
    bw = imfill(bw,26,'holes');
    bw = ~bwareaopen(~bw,20);
    D = -bwdist(~bw);
    % bwdist of complement of bw effectively segments the cells; the cells are
    % all 0's in ~bw, so the cell pixels are hot, background pixels are cold
    
    % imextendedmin computes the "extended-minima transform," the "regional 
    % minima of the H-minima transform." 
    % ie, it finds all connected components of pixels w/ constant intensity AND whose boundary pixels all have a
    % higher intensity value. this is why we find imextendmin of the negative
    % of D. This effectively gives us the local regions of minima within cells
    mask=imextendedmin(D,2);
    D2 = imimposemin(D,mask);
    Ld2 = watershed(D2);
    bw2 = bw;
    bw2(Ld2 ==0) = 0;
    
    bw3 = imfill(bw2,'holes');
%     
    bw3 = ~bwareaopen(~bw3,10);
    D3 = -bwdist(~bw3);
    mask3=imextendedmin(D3,2);
    D4 = imimposemin(D,mask3);
    Ld3 = watershed(D4);  % flood image & partition catchments/lines

    bw4 = bw3;
    bw4(Ld3 ==0) = 0;
    
    % I basically did the same thing twice up there (watershed twice). Usually the 2nd time through helps a 
    % trivial amount, but every once in a while it can make a big difference. 
end
