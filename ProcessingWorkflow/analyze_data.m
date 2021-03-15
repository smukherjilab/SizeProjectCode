

% basic script to analyze a single channel Zstack of fluorescently labeled
% organelles
% i tried to be modular (pushing on redundant) to make it easy to move
% stuff around/add/subtract/etc

% important outputs: 
%       - volumes: each row is a cell, each entry is an organelle and its
%                  size
%       - cell_sizes:  vector containing size of each cell. is aligned with
%                      volumes so ith row of volumes has cell size =
%                      cell_sizes(i)
%       - seg_raw: each entry of seg_raw_orgs contains a zstack that
%       has been cropped out from file 'imgname'. if an entry is empty, it
%       was weeded out (too small, bad segmentation, etc). i kept the
%       empties to make it easier to track cells through the various
%       variables
%       - seg_bw: same as seg_raw but binary (organelles = white, bkgd =
%       black)
clear; clc;
%% image paths

homedir = '/Users/asakalish/Desktop/';
imgname = 'Pex3mKO2_YFPfromATPFRET065-orgs.tif_deconv.tif';
cellsname = 'Pex3mKO2_YFPfromATPFRET065-cells.tif';

%% parameters 
Zrange = [1 31];            % which z's to consider
SIGMA = 1.5;                % strength of Gaussian blurring
Threshold = 0.3;            % threshold on scale [0,1]
Cells_Threshold = 0.06;     % gotta find the right value by hand but usually ~ 0.06
R = 5;                      % size of structuring element of bkgd subtraction

MINSIZE = 25;               % minimum size of organelles (to avoid speckles)
MAXSIZE = 10000;            % maximum size of organelles (set high to avoid enforcing this)
MINAREA = 10;               % Each organelle is required to have this minimum area in every Z 
                            % in which it appears. Set to 0 to avoid
                            % enforcing this

MININT = 300;               % Minimum intensity of organelles. 
                            % I find this useful for some noisy datasets.
                            % Set to 0 if you don't want to use it
MINCELLSIZE = 500;          % minimum cell size (avoid bad segmentation)
method = '3d';            % processing method

%% load organelles and cells
% get organelles first
loadorgs = tiffread2([homedir,imgname]);
NumZ = length(loadorgs);
for z=1:NumZ
    orgs(:,:,z) = double(loadorgs(z).data);
end

% load and binarize cells
loadcells = tiffread2([homedir,cellsname]);
cells = double(loadcells.data); % assumes cells tif is 2D
cells_bw = label_cells(cells, Cells_Threshold);

%% segment cells
cell_bounds = bwboundaries(cells_bw,4,'noholes'); % why 4? chosen from experience (ie staring at images)
NUM_CELLS = length(cell_bounds);   % number of cells in population; includes cells that may later be filtered out

cell_sizes = zeros([length(cell_bounds),1]);  % we hold our cell sizes here
cell_coords = cell([length(cell_bounds),1]);   % we hold our cell boundary coords here (rectangle)

% iter thru cells and get their sizes
for c=1:NUM_CELLS
    % grab cell boundary coordinates:
    these_bounds = cell_bounds{c};
    % draw rectangle around cell:
    xmin = min(these_bounds(:,2)); xmax = max(these_bounds(:,2));
    ymin = min(these_bounds(:,1)); ymax = max(these_bounds(:,1));
    % store rectangle:
    cell_coords{c} = [xmin xmax; ymin ymax];

    if min(cell_coords{c}(:)) < 5 || max(cell_coords{c}(:)) > size(cells_bw,1)-5   % image borders are unreliable
        cell_sizes(c) = NaN;
        continue
    else
        this_c = cells_bw(ymin:ymax,xmin:xmax,:);
        if sum(this_c(:)) < MINCELLSIZE
            cell_sizes(c) = NaN;
            continue
        else
            cell_sizes(c) = sum(this_c(:));
        end
    end
end

%% partition cells into blocks
tic;
seg_raw = cell([NUM_CELLS,1]);
for c=1:NUM_CELLS
    if min(cell_coords{c}(:)) < 1 || max(cell_coords{c}(:)) > min(size(cells_bw))
        continue
    else
        xmin = cell_coords{c}(1,1); xmax = cell_coords{c}(1,2);
        ymin = cell_coords{c}(2,1); ymax = cell_coords{c}(2,2);

        if xmax - xmin < 5 || ymax - ymin < 5
            continue
        else
            seg_raw{c}(:,:,:) = orgs(ymin:ymax,xmin:xmax,:);
        end
    end
end
toc

%% now go back and measure their sizes
tic;

seg_bw = cell([NUM_CELLS,1]);
org_volumes = {};
for c=1:NUM_CELLS
    if isempty(seg_raw{c})
        continue
    else
        this_cell = seg_raw{c};  % grab the cropped stack for this cell
        seg_bw{c} = zeros(size(this_cell)); % initialize binary stack
        pixels = zeros([NumZ,1]);  % i use this distribution to avoid empty frames (which can give false positives)
        for z=1:NumZ
            x = this_cell(:,:,z);
            pixels(z) = max(x(:));
        end
        
        if contains(method,'both')
            for z=Zrange(1):Zrange(2)
                if pixels(z) < mean(pixels) - .5*std(pixels)    % mess with this coefficient on the std to control skipping of frames
                    continue
                else     % choose processing procedure and apply it to label pixels as organelle vs background
                    this_slice = imtophat(this_cell(:,:,z),strel('disk',R));                
                    seg_bw{c}(:,:,z-Zrange(1)+1) = ...
                        bwareaopen(mylaplace(this_slice,SIGMA) > Threshold,MINAREA);
                end
            end
            
        elseif contains(method,'edge')
            for z=Zrange(1):Zrange(2)
                if pixels(z) < mean(pixels) - .5*std(pixels)    % mess with this coefficient on the std to control skipping of frames
                    continue
                else     % choose processing procedure and apply it to label pixels as organelle vs background
                    this_slice = this_cell(:,:,z);
                    seg_bw{c}(:,:,z-Zrange(1)+1) = ...
                        bwareaopen(mylaplace(this_slice,SIGMA) > Threshold,MINAREA);
                end
            end
            
        elseif contains(method,'bkgd')
            for z=Zrange(1):Zrange(2)
                if pixels(z) < mean(pixels) - .5*std(pixels)    % mess with this coefficient on the std to control skipping of frames
                    continue
                else     % choose processing procedure and apply it to label pixels as organelle vs background
                    this_slice = this_cell(:,:,z);
                    seg_bw{c}(:,:,z-Zrange(1)+1) = ...
                        bwareaopen(imtophat(this_cell(:,:,z),strel('disk',R)) > Threshold,MINAREA);
                end
            end
            
        elseif contains(method,'3d')
            seg_bw{c} = mylaplace(this_cell,SIGMA) > Threshold;
        end
            
        
        
        this_bw = seg_bw{c};
        for z=1:NumZ
            if pixels(z) < MININT
                this_bw(:,:,z) = 0;
            end
        end
        seg_bw{c} = this_bw;
        this_cc = bwconncomp(this_bw);
        for n=1:this_cc.NumObjects
            % grab an organelle from this cell:
            this_org = length(this_cc.PixelIdxList{n});
            % enforce size range on organelle  
            if this_org > MINSIZE && this_org < MAXSIZE
                org_volumes{c,n} = this_org;
            else
                org_volumes{c,n} = NaN;
            end
        end
    end
end
% clean
[rows,cols] = size(org_volumes);
for i=1:rows
    for j=1:cols
        if isempty(org_volumes{i,j})
            org_volumes{i,j} = NaN;
        elseif org_volumes{i,j} < MINSIZE
            org_volumes{i,j} = NaN;
        end
    end
end
volumes = cell2mat(org_volumes); [M,N] = size(volumes);
[~,col1] = sort(~isnan(volumes),2,'descend'); row1 = repmat(1:M,N,1)';
restructured_indices = sub2ind(size(volumes),row1(:),col1(:));
volumes = reshape(volumes(restructured_indices),M,N);
volumes(:,all(isnan(volumes),1)) = [];
toc

% out = volumes(any(~isnan(volumes),2),:);   % use this to clear out all NaN rows 

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
    filter = -L_norm/maxCurv;
end