function [L_norm,maxCurv] = laplace(image,varargin)
    ninputs = numel(varargin);
    
    slice = double(image);
    
    [Lx, Ly] = gradient(slice);
	[Lxx, ~] = gradient(Lx);
	[~, Lyy] = gradient(Ly);
    
    L_norm = (Lxx+Lyy);
    
    L_norm(L_norm>0) = 0;
    
    temp=abs(L_norm); 
    maxCurv = max(temp(:));
    
%     
    L_norm = -L_norm/maxCurv;
    
%   
%     I = imfill(L_norm,26);
%     I = imgaussfilt(I,1.75,'FilterSize',[11 11]);
%     bw = I > 0.015; 
%     
%     bw2 = imfill(bw,26,'holes');
%     figure, imshow(bw2)
% bw2 = L_norm;
end