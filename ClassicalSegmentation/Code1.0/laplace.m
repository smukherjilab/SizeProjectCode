% Simple function that applies Laplacian operator to input image.
% This function removes all positive curvature (ie, dark boundaries) and normalizes curvature to 1.

% INPUT: some image in which you want edge detection (assuming edges of interest are bright)
% OUTPUT: Image where pixel values are normalized to [0, 1]

% NOTE: Laplacian is a 2nd derivative, so it is very sensitive to local noise fluctuations. 
% Recommended to blur input image before passing thru this function
function [L_norm,maxCurv] = laplace(image)

    ninputs = numel(varargin);
   
    slice = double(image);
    
    [Lx, Ly] = gradient(slice);
    [Lxx, ~] = gradient(Lx);
    [~, Lyy] = gradient(Ly);
    
    L_norm = (Lxx+Lyy);
    
    L_norm(L_norm>0) = 0;
    
    temp=abs(L_norm); 
    maxCurv = max(temp(:));
   
    L_norm = -L_norm/maxCurv;
    
end
