


p = '/Volumes/Archive/Rebuttal/Rebuttal_confocaldata/Confocal_Single_Organelle_Zoom/Erg6Mko2_2x_Zoom/';
name = 'Erg6Mko2-AtpFRET-2XZoom-sample.tif';

%% load
load = bfopen([p,name]);

%%

orgs = zeros([size(load{1,1}{1,1}), length(load{1,1})/2]);
cells = zeros([size(load{1,1}{1,1}), length(load{1,1})/2]);
for z=2:2:length(load{1,1})
    orgs(:,:,z/2) = double(load{1,1}{z,1});
end
for z=1:2:length(load{1,1})
    cells(:,:,(z+1)/2) = double(load{1,1}{z,1});
end
%% filt cell

for i=1:37
    cell_filt(:,:,i) = mylaplace(orgs(:,:,i),1);
end

%% check

figure, imagesc(cell_filt(:,:,4))

%% bw
for i=1:37
    x = cell_filt(:,:,i);
    bw(:,:,i) = x>0.2;
end

figure(); imshow(bw(:,:,32))
%% now get cells segmented
load = tiffread2([p,'ChannelEmpty_Seq0031.nd2 - SRRF-masked-lines.tif']);
%% 
pixelsum = [];
for i=1:37
    slice = orgs(:,:,i);
    pixelsum(i) = std(slice(:));
end

