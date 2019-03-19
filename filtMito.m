function binarySlice = filtMito(rawImage) 
% 
% rawImage = double(rawImage);
% filt1 = imgaussfilt(rawImage,2);
% lap1 = laplace(filt1);
% 
% fiber1 = fibermetric(lap1,6);
% 
% finalFilter = imgaussfilt(fiber1,1.5);
% 
% finalFilter = finalFilter/max(finalFilter(:));
% binarySlice = finalFilter > 0.15;

frangi1 = FrangiFilter2D(double(rawImage));

% smooth1 = imgaussfilt(frangi1,2);
% 
% fiber1 = fibermetric(smooth1, 10);
% 
% smooth2 = imgaussfilt(fiber1, 2);
% 
% smooth2 = smooth2/max(smooth2(:));
frangi1 = frangi1/max(frangi1(:));
binarySlice = frangi1 > 0.4;
end