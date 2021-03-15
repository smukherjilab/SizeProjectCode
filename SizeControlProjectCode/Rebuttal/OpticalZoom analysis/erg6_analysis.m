

% script to check out this confocal data for rebuttal 
% out = volumes(any(~isnan(volumes),2),:);   %for rows
clear; clc;
%% image paths

home = '/Volumes/Archive/Rebuttal/Rebuttal_confocaldata/Confocal_Single_Organelle_Zoom/Erg6Mko2_2x_Zoom/';
p = 'Erg6Mko2-AtpFRET-2XZoom.nd2';

path_cells = 'mask.mat';
% path_orgs = 'ZStack0000 (5).nd2 - SRRF-orgs.tif';

 %% params for sweeping

Z = [7 35];% 7: [17 37]; %6: [6 31]; %5: [8 34]; %4: [4 28]; %3:[3 33]; % 2: [10 36];   % 0: [7 35]

SIGMA = 1.25;
THRESHOLD = 0.25;
MINSIZE = 14;
%% load 
load = bfopen([home,p]);

orgs = zeros([size(load{1,1}{1,1}), length(load{1,1})/2]);
cells = zeros([size(load{1,1}{1,1}), length(load{1,1})/2]);
for z=2:2:length(load{1,1})
    orgs(:,:,z/2) = double(load{1,1}{z,1});
end
for z=1:2:length(load{1,1})
    cells(:,:,(z+1)/2) = double(load{1,1}{z,1});
end
%% binarize cells
bw = sum(cells,3) > 500;
bw = imfill(bw,26,'holes');
bw = ~bwareaopen(~bw,20);
D = -bwdist(~bw);
mask=imextendedmin(D,2);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw2 = bw;
bw2(Ld2 ==0) = 0;
[bw_zproj,bw_cells] = confocal_cellseg(cells(:,:,Z(1):Z(2)),.75);
%% segment cells
cell_bounds = bwboundaries(bw2,4,'noholes'); % why 4? chosen from experience (ie staring at images)
NUM_CELLS = length(cell_bounds);   % number of cells in population; includes cells that may later be filtered out

cell_sizes = zeros([length(cell_bounds),1]);  % we hold our cell sizes here
cell_coords = cell([length(cell_bounds),1]);   % we hold our cell boundary coords here (rectangle)

% iter thru cells 
for c=1:NUM_CELLS
    % grab cell boundary coordinates:
    these_bounds = cell_bounds{c};
    % draw rectangle around cell:
    xmin = min(these_bounds(:,2))-1; xmax = max(these_bounds(:,2))+1;
    ymin = min(these_bounds(:,1))-1; ymax = max(these_bounds(:,1))+1;
    % store rectangle:
    cell_coords{c} = [xmin xmax; ymin ymax];

    if min(cell_coords{c}(:)) < 10 || max(cell_coords{c}(:)) > size(bw2,1)-10   % image borders are unreliable
        cell_sizes(c) = NaN;
        continue
    else
        this_c = bw_cells(ymin:ymax,xmin:xmax,:);
        if sum(this_c(:)) < 100
            cell_sizes(c) = NaN;
            continue
        else
            cell_sizes(c) = sum(this_c(:));
        end
    end
end

%% partition cells into blocks
tic;
seg_raw_orgs = cell([NUM_CELLS,1]);
for c=1:NUM_CELLS
    if min(cell_coords{c}(:)) < 1 || max(cell_coords{c}(:)) > max(size(bw2))
        continue
    else
        xmin = cell_coords{c}(1,1); xmax = cell_coords{c}(1,2);
        ymin = cell_coords{c}(2,1); ymax = cell_coords{c}(2,2);

        if xmax - xmin < 10 || ymax - ymin < 10
            continue
        else
            seg_raw_orgs{c}(:,:,:) = orgs(ymin:ymax,xmin:xmax,:);
        end
    end
end
toc

%% now go back and measure their sizes
tic;

seg_binary_orgs = cell([NUM_CELLS,1]);
org_volumes = {};
for c=1:NUM_CELLS
    if isempty(seg_raw_orgs{c})
        continue
    else
        this_cell = seg_raw_orgs{c};
        seg_binary_orgs{c} = zeros(size(this_cell));
        pixelsum = zeros([37,1]);
        for z=1:37
            x = this_cell(:,:,z);
            pixelsum(z) = sum(x(:));
        end
        
        for z=Z(1):Z(2)
            if pixelsum(z) < mean(pixelsum) - .5*std(pixelsum)
                continue
            else
                this_slice = this_cell(:,:,z);
                seg_binary_orgs{c}(:,:,z-Z(1)+1) = mylaplace(this_slice,SIGMA) > THRESHOLD;
            end
        end
        
        this_bw = seg_binary_orgs{c};
        this_cc = bwconncomp(this_bw);
        for n=1:this_cc.NumObjects
            % grab an organelle from this cell:
            this_org = length(this_cc.PixelIdxList{n});
            % enforce size range on organelle  
            if this_org > MINSIZE && this_org < 750
                org_volumes{c,n} = this_org;
            else
                org_volumes{c,n} = NaN;
            end
        end
    end
end
%% clean
[rows,cols] = size(org_volumes);
for i=1:rows
    for j=1:cols
        if isempty(org_volumes{i,j})
            org_volumes{i,j} = NaN;
        elseif org_volumes{i,j} < 10
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

%% 
sn(volumes);
t = rm(volumes,8);
sc(t); ylim([0 3]); title(['sigma=',num2str(SIGMA),' t=',num2str(THRESHOLD),' m=',num2str(MINSIZE)]);