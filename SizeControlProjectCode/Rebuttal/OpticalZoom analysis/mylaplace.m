% edge detector (2nd derivative)
function [L_norm] = mylaplace(img,SIGMA)
    
    slice = imgaussfilt(double(img),SIGMA);

    [Lx, Ly] = gradient(slice);
	[Lxx, ~] = gradient(Lx);
	[~, Lyy] = gradient(Ly);
    
    L_norm = (Lxx+Lyy);
    L_norm(L_norm>0) = 0;
    
    temp=abs(L_norm); 
    maxCurv = max(temp(:));
 
    L_norm = -L_norm/maxCurv;

end