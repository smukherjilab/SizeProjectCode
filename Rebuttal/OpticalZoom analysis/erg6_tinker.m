

%% this image is a sample that i segmented out of the field to test processing
p = '/Volumes/Archive/Rebuttal/Rebuttal_confocaldata/Confocal_Single_Organelle_Zoom/Erg6Mko2_2x_Zoom/';
name = 'Erg6Mko2-AtpFRET-2XZoom-sample.tif';

%% load
load = bfopen([p,name]);

%% allocate data
orgs = zeros([size(load{1,1}{1,1}), length(load{1,1})/2]);
cells = zeros([size(load{1,1}{1,1}), length(load{1,1})/2]);
for z=2:2:length(load{1,1})
    orgs(:,:,z/2) = double(load{1,1}{z,1});
end
for z=1:2:length(load{1,1})
    cells(:,:,(z+1)/2) = double(load{1,1}{z,1});
end

%% filter the images
for i=1:37
    cell_filt(:,:,i) = mylaplace(orgs(:,:,i),1);
end

%% look at filtering
figure, imagesc(cell_filt(:,:,4))

%% binarize images
for i=1:37
    x = cell_filt(:,:,i);
    bw(:,:,i) = x>0.2;
end

%% check binary img
figure(); imshow(bw(:,:,32))

%% now get cells segmented
load = tiffread2([p,'ChannelEmpty_Seq0031.nd2 - SRRF-masked-lines.tif']);

%% i use 'pixelsum' to determine which zslices to skip... 
pixelsum = [];
for i=1:37
    slice = orgs(:,:,i);
    pixelsum(i) = sum(slice(:));
end

figure(); hold on;
plot(1:37, pixelsum); 
yline(mean(pixelsum))

% so in this case, mean of pixelsum would be threshold for deciding if we analyze this z slice or not. 
% ie if pixelsum(z) < mean(pixelsum) then we skip z 
% (I'll often modulate this threshold, eg mean(pixelsum) - std(pixelsum), to get best results. 
% I find this step worthwhile because it helps avoid lots of empty zslices that might confuse processing)

