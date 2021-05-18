

% typical script I'd use to analyze a set of data
% in this case, Golgi labeled via Arf1tdTomato and imaged with widefield
% camera

clear; clc;
%% image paths

p = '/Volumes/Archive/Rebuttal/Rebuttal_CameraData/Golgi/Arf1tdTomato/';

name = {'Orgs_deconv_batch1/Arf1tdTomato_100XCamera-orgs.tif_deconv.tif',...
    'Orgs_deconv_batch1/Arf1tdTomato_100XCamera001-orgs.tif_deconv.tif'};

namer = {'Orgs/Arf1tdTomato_100XCamera-orgs.tif',...
    'Orgs/Arf1tdTomato_100XCamera001-orgs.tif'};

cellsname = {'CellMasks/z22- Arf1tdTomato_100XCamera.tif',...
    'CellMasks/z21- Arf1tdTomato_100XCamera001.tif'};

%%
tic;
for i=1:2
    data(i) = dataclass([p,name{i}]);
    data(i) = data(i).loadOrgImage();
    data(i).CellPath = [p,cellsname{i}];
    data(i) = data(i).loadCellImage();
    data(i).AuxPath = [p,namer{i}];
    data(i) = data(i).loadAuxImage();
end
toc
 %% params 

SIGMA = 1;
STREL = 3;
THRESHOLD = 0.09;
MINSIZE = 100; MAXSIZE = 2000;
MININT = 100;
MINCELLSIZE = 1000;

%% analyze
tic;
for i=1:2
    statistics(i) = analyze(data(i).OrgImage,data(i).AuxImage,data(i).CellImage,...
        SIGMA,THRESHOLD,MINSIZE,MAXSIZE,MININT,MINCELLSIZE);
end
toc

% concatenate into data
statistics_merged = CatStructFields(statistics(1),statistics(2),1);
for i=2:2
    statistics_merged = CatStructFields(statistics_merged,statistics(i),1);
end

sn(statistics_merged.volumes);


%% function
function data = analyze(orgs,orgs_raw,cells,SIGMA,THRESHOLD,MINSIZE,MAXSIZE,MININT,MINCELLSIZE)

    numz = size(orgs,3);

    %% binarize cells
    bw = cells > 0;

    %% segment cells
    cell_bounds = bwboundaries(bw,4,'noholes'); % why 4? chosen from experience (ie staring at images)
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

        if min(cell_coords{c}(:)) < 1 || max(cell_coords{c}(:)) > size(bw,1)   % image borders are unreliable
            cell_sizes(c) = NaN;
            continue
        else
            this_c = bw(ymin:ymax,xmin:xmax,:);
            if sum(this_c(:)) < MINCELLSIZE
                cell_sizes(c) = NaN;
                continue
            else
                cell_sizes(c) = sum(this_c(:));
            end
        end
    end

    %% partition cells into blocks
    seg_orgs = cell([NUM_CELLS,1]);
    seg_raw_orgs = cell([NUM_CELLS,1]);
    for c=1:NUM_CELLS
        if isnan(cell_sizes(c))
            continue
        else
            xmin = cell_coords{c}(1,1); xmax = cell_coords{c}(1,2);
            ymin = cell_coords{c}(2,1); ymax = cell_coords{c}(2,2);

            if xmax - xmin < 2 || ymax - ymin < 2
                continue
            else
                seg_orgs{c}(:,:,:) = orgs(ymin:ymax,xmin:xmax,:);
                seg_raw_orgs{c}(:,:,:) = orgs_raw(ymin:ymax,xmin:xmax,:);
            end
        end
    end

    %% now go back and measure their sizes
    seg_binary_orgs = cell([NUM_CELLS,1]);
    org_volumes = {};
    org_ints = {};
    for c=1:NUM_CELLS
        if isempty(seg_orgs{c})
            org_volumes{c,1} = NaN;
            org_ints{c,1} = NaN;
            continue
        else
            this_cell = seg_orgs{c};
            int_mask = this_cell > MININT;
            this_raw_cell = seg_raw_orgs{c};
            this_bw = zeros(size(this_cell));
            pixels = ones([numz, 1]);
            pixelstds = ones([numz,1]);
            for z=1:numz
                x = this_cell(:,:,z);
                this_max = max(x(:));
                pixelstds(z) = std(x(:));
                if this_max < MININT
                    pixels(z) = 0;
                end
            end

            this_bw = (mylaplace(this_cell,SIGMA) > THRESHOLD) .* int_mask;
            for z=1:size(this_bw,3)
                if pixels(z) == 0
                    this_bw(:,:,z) = 0;
                end
            end
            
           seg_binary_orgs{c} = bwareaopen(this_bw,MINSIZE);
           
            this_cc = bwconncomp(this_bw,6);
            for n=1:this_cc.NumObjects
                % grab an organelle from this cell:
                this_org = length(this_cc.PixelIdxList{n});
                % enforce size range on organelle  
                if this_org > MINSIZE && this_org < MAXSIZE
                    org_volumes{c,n} = this_org;
                    org_ints{c,n} = sum(this_raw_cell(this_cc.PixelIdxList{n}));
                else
                    org_volumes{c,n} = NaN;
                    org_ints{c,n} = NaN;
                end
            end
        end
    end
    %% clean & save
    [rows,cols] = size(org_volumes);
    for i=1:rows
        for j=1:cols
            if isempty(org_volumes{i,j})
                org_volumes{i,j} = NaN;
                org_ints{i,j}=NaN;
            elseif org_volumes{i,j} < MINSIZE
                org_volumes{i,j} = NaN;
                org_ints{i,j} = NaN;
            end
        end
    end
    volumes = cell2mat(org_volumes); [M,N] = size(volumes);
    [~,col1] = sort(~isnan(volumes),2,'descend'); row1 = repmat(1:M,N,1)';
    restructured_indices = sub2ind(size(volumes),row1(:),col1(:));
    volumes = reshape(volumes(restructured_indices),M,N);
    volumes(:,all(isnan(volumes),1)) = [];
    
    ints = cell2mat(org_ints); [M,N] = size(ints);
    [~,col1] = sort(~isnan(ints),2,'descend'); row1 = repmat(1:M,N,1)';
    restructured_indices = sub2ind(size(ints),row1(:),col1(:));
    ints = reshape(ints(restructured_indices),M,N);
    ints(:,all(isnan(ints),1)) = [];
    
    data.volumes = volumes;
    data.ints = ints;
    data.cell_sizes = cell_sizes;
    PARAMS.THRESHOLD = THRESHOLD;
    PARAMS.SIGMA = SIGMA;
    PARAMS.MINSIZE = MINSIZE;
    PARAMS.MININT = MININT;
    data.seg_orgs = seg_orgs;
    data.seg_binary_orgs = seg_binary_orgs;
    data.THRESHOLD = THRESHOLD;
    data.SIGMA = SIGMA;
    data.PARAMS = PARAMS;
    data.bw = bw;
    out = volumes(any(~isnan(volumes),2),:); 
    PARAMS.N = size(out,1);

end
