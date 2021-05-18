
% before analyzing a batch, check out the data and see what kind of
% processing parameters make sense

%% first, load the sample data
% i usually segment a cell or two by hand in ImageJ

homedir = '/Users/asakalish/Desktop/';
imgname = 'pex3camera_example.tif';

load = tiffread2([homedir, imgname]);
NumZ = length(load);
% read
orgs = [];
for i=1:NumZ
    orgs(:,:,i) = double(load(i).data);
end

%% look at image
figure();
for i=1:NumZ
    subplot(6,6,i);   % might have to tweak this to fit img dimensions
    imshow(orgs(:,:,i),[]);
    title(['Z=',num2str(i)]);
end

%% check it out with bar3c
% i think it's helpful to look at the images with this lil function
Z = 10;
figure(); bar3c(orgs(:,:,Z)); title(['Z=',num2str(Z)]);

%% now filter the image
% choose a sigma (strength of Gaussian blurring)
SIGMA = 1;
filter = mylaplace(orgs, SIGMA);

%% now lets look at what happens as we vary threshold
% i use this step to select sensible threshold and Zrange to include
VizOrgs(filter,0.5,size(filter,1),size(filter,2),7,20);

% unfortunately, i couldnt figure out how to print the value of that
% sliding button. i think it has something to do with the fact that the
% plotting function 'VoxelPlotter.m' is a patch object, whereas the
% interactive UI wants a handle object

%% use threshold to binarize image
Threshold = 0.25;  % this is a typical value. don't want to include 
                   % too much bkgd while avoiding deleting real pixels
Zrange = [7 20];

bw = [];  % image processing people call binary images bw a lot (black/white)
for i=Zrange(1):Zrange(2)
    bw(:,:,i-Zrange(1)+1) = filter(:,:,i) > Threshold;
end

% count voxels
cc = bwconncomp(bw,6);
organelle_sizes = [];
for n=1:cc.NumObjects
    organelle_sizes(n) = length(cc.PixelIdxList{n});
end

% this is a good time to check what sensible bounds for organelle size
% might be, and characterize sources that might interfere with good size
% measurement

function filter = mylaplace(img,SIGMA)
% can accept stack or slice 
% first, blur the image. in general, applying mathematical operations to
% imaging data goes better when the pixels are smoother (ie derivatives are
% more continuous) 
    slice = imgaussfilt(double(img),SIGMA);

    [Lx, Ly] = gradient(slice);
	[Lxx, ~] = gradient(Lx);
	[~, Lyy] = gradient(Ly);

% this is the Laplacian of the image (picking out curvature)
    L_norm = (Lxx+Lyy);
    L_norm(L_norm>0) = 0;
 
    temp=abs(L_norm); 
    maxCurv = max(temp(:));
% peaks are negative and valleys are positive. we define foreground to be 
% peaks (ie organelles) thus we take the negative of the Laplacian. 
% then we normalize for math convenience
    L_norm = -L_norm/maxCurv;
end