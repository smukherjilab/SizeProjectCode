
%
% this script processes images & returns binary images & size measurements
%
%% INPUTS:
%{
- PATH_ORGS: a path to the image(s) of organelles to be analyzed
            eg: PATH_ORGS = '/Users/asakalish/Desktop/OrganelleStack.tif'

- PATH_CELLS: a path to the image(s) of cells corresp. to organelles
            eg: PATH_CELLS = '/Users/asakalish/Desktop/CellsStack.tif'
             or PATH_CELLS = '/Users/asakalish/Desktop/CellsStack.mat'
Note: this code assumes that the cells have aready been binarized; accepts
either .mat or .tif

- Z: desired range of Z-slices
     eg: Z = [10 25], where the stack spans from 1-31
      or Z = [1 31], etc

- THRESHOLD: threshold to generate binary image of organelles; btwn [0,1];
    eg: THRESHOLD = 0.1 is typically a low threshold;
        THRESHOLD = 0.3 is typically a high threshold
    (mathematically, threshold is cutoff value for curvature in 2nd
    derivative of image)
Note: threshold is applied separately for each 2D slice of each cell, 
(if input is stack, these 2D slices are stitched together to 3D cell)

- SIGMA: strength of Gaussian blur filter, applied before edge detection &
thresholding
    eg: SIGMA = 0.5 is a relatively weak blur;
        SIGMA = 2 is a relatively strong blur

- CC: connected-components requirement for clustering pixels into
organelles
    eg: CC = 6 typically gives reasonable outputs
    CC can be 4, 6, 8, 18, or 26

- MIN_ORG_SIZE: minimum organelle size. used to filter out specks of noise
that may be picked up in processing. 
    eg: MIN_ORG_SIZE = 20 (units = voxels)
Note: Look at your images in matlab/imagej to ballpark the best
MIN_ORG_SIZE; this value can really impact statistical distributions

- varargin (optional inputs)
    - 'min_cell_size' default = 1000
    - 'max_org_size' default = 10000;
    - 'sweep' default = FALSE
(turning on 'sweep' will replace "PATH_ORGS" with the image itself)

Again, these shoud be based on your data

Example of using varargin:

data = process(PATH_ORGS, PATH_CELLS, Z, THRESHOLD, SIGMA, CC,...
MIN_ORG_SIZE, 'min_cell_size', 500, 'max_org_size', 5000); 

arguments in '' are case-SENSITIVE
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT 
%{
- data: a struct holding the image data, the statistics, and the parameters

Most important values: 
    - volumes: each row is a cell, each entry is an organelle & its size
    - cell_sizes: each entry is a cell & its size; corresponds row-to-row
                   w/ volumes
    - seg_raw_orgs: raw images of organelles, segmented by cells
    - seg_edge_orgs: filtered images of organelles, segmented by cells
    - seg_binary_orgs: binary images of organelles, segmented by cells
    - PARAMS: image processing parameters

to access a variable within data:

cell_sizes = data.cell_sizes
etc

Note: 0's or NaN's will appear when a cell/organelle is filtered out by
some error-catching mechanism (eg flecks of noise, false-positive cells,
etc). I kept them there to make sure I could remember who they were (and to
make consistent indexing easier)



example use: 
PATH_ORGS = '/Users/asakalish/Desktop/OrgsStack.tif';
PATH_CELLS ='/Users/asakaish/Desktop/CellsStack.tif';
Z = [5 24];
THRESHOLD = 0.2;
SIGMA = 1;
CC = 6;
MIN_ORG_SIZE = 20;

data = process(PATH_ORGS, PATH_CELLS, Z, THRESHOLD, SIGMA, CC,
MIN_ORG_SIZE);

perhaps you notice an outlier and want to impose max organelle size:
data = process(PATH_ORGS, PATH_CELLS, Z, THRESHOLD, SIGMA, CC,
MIN_ORG_SIZE, 'max_org_size', 500);

%}

%% 
function data = process(PATH_ORGS, PATH_CELLS, Z,...
    THRESHOLD, SIGMA, CC, MIN_ORG_SIZE, varargin)
    
    %% first check optional arguments
    p = inputParser;
    addParameter(p,'min_cell_size',1000);
    addParameter(p,'max_org_size',10000);
    addParameter(p,'sweep','false');
    
    if size(varargin{1},2) == 2 || size(varargin{1},2) == 4 || size(varargin{1},2) == 6
        parse(p, varargin{1}{:}); % we are being sweeped
    else
        parse(p, varargin{:});
    end
    MIN_CELL_SIZE = p.Results.min_cell_size;
    MAX_ORG_SIZE = p.Results.max_org_size;
    sweep = p.Results.sweep;
    
    %% archive parameters
    PARAMS.MIN_CELL_SIZE = MIN_CELL_SIZE; PARAMS.MIN_ORG_SIZE = MIN_ORG_SIZE;
    PARAMS.MAX_ORG_SIZE = MAX_ORG_SIZE; PARAMS.Z = Z; PARAMS.SIGMA = SIGMA;
    PARAMS.THRESHOLD = THRESHOLD; PARAMS.CC = CC; PARAMS.PATH_ORGS = PATH_ORGS;
    PARAMS.PATH_CELLS = PATH_CELLS;

    %% first, we have to read the images
    
    % images of organelles might be path to image or image itself
    if contains(sweep,'false')
        load_orgs = bfopen(PATH_ORGS); % bfopen can also handle nd2s
        orgs = zeros([size(load_orgs{1,1}{1,1}), length(load_orgs{1,1})]);  % array to hold our input organelle images
        for z=1:length(load_orgs{1,1})
            orgs(:,:,z) = double(load_orgs{1,1}{z,1});
        end
    elseif contains(sweep,'true')
        orgs = PATH_ORGS;
    end
    
    % image of cells might be tif or mat
    [~, ~, ext] = fileparts(PATH_CELLS);
    if contains(ext,'mat')
        load_cells = load(PATH_CELLS);
        name = fieldnames(load_cells); % when you save a variable to a mat, we access by its name
        cells = load_cells.(name{1});
    elseif contains(ext,'tif')
        load_cells = tiffread2(PATH_CELLS);
        cells = double(load_cells(1).data);  
    else
        error('PATH_CELLS points to an invalid file type; must be .tif or .mat');
    end

    clear load_orgs load_cells name ext 

    disp('-------- READ --------')

    
    %% now let's segment cells
    cell_bounds = bwboundaries(cells,4,'noholes');
    NUM_CELLS = length(cell_bounds);   % number of cells in population; includes cells that may later be filtered out

    cell_sizes = zeros([length(cell_bounds), 1]);  % we hold our cell sizes here
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

        if min(cell_coords{c}(:)) < 30 || max(cell_coords{c}(:)) > size(orgs,1)-30   % image borders are unreliable
            cell_sizes(c) = NaN;
            continue
        else
            this_c = cells(ymin:ymax,xmin:xmax);
            if sum(this_c(:)) > MIN_CELL_SIZE
               cell_sizes(c) = sum(this_c(:));
            end
        end
    end

    clear these_bounds this_c xmin xmax ymin ymax

    disp('-------- SEGMENTED --------')

    %% now let's process the organelles
    orgs_bw = zeros([size(orgs,1), size(orgs,2), Z(2)-Z(1)+1]);  % hold binary organelles (full fields)
    orgs_edge = zeros([size(orgs,1), size(orgs,2), Z(2)-Z(1)+1]);  % hold filtered organelles (full fields)
    org_volumes = {};   % data initially stored in this cell array, for indexing convenience
    seg_raw_orgs = cell([NUM_CELLS, 1]);       % raw organelles, segmented
    seg_binary_orgs = cell([NUM_CELLS,1]);     % binary organelles, segmented
    seg_edge_orgs = cell([NUM_CELLS,1]);       % filtered organelles, segmented
    centroids = cell([NUM_CELLS, 1]);          % centroids of organelles
    conncomp = cell([NUM_CELLS, 1]);           % connected components (clustering for size/# measurements)
    for c=1:NUM_CELLS    % iter thru cells

        if isnan(cell_sizes(c))  
            org_volumes{c,1} = NaN;
        else
            for z=Z(1):Z(2)    % iter thru Z's of this cell
                % grab the organelles in this cell:
                these_orgs = orgs(cell_coords{c}(2,1):cell_coords{c}(2,2),...
                    cell_coords{c}(1,1):cell_coords{c}(1,2),z);
                % blur the organelles so pixel dist is less jumpy:
                these_orgs_filt = imgaussfilt(these_orgs, SIGMA);
                % apply edge detection: 
                these_orgs_edge = laplace(these_orgs_filt);
                % binarize organelles:
                these_orgs_bw = these_orgs_edge > THRESHOLD;
                
                % stich together the binary field of organelles
                orgs_bw(cell_coords{c}(2,1):cell_coords{c}(2,2),...
                    cell_coords{c}(1,1):cell_coords{c}(1,2),z-Z(1)+1)...
                    = these_orgs_bw;
                % stitch together the filtered field of organelles
                orgs_edge(cell_coords{c}(2,1):cell_coords{c}(2,2),...
                    cell_coords{c}(1,1):cell_coords{c}(1,2),z-Z(1)+1)...
                    = these_orgs_edge;
            end
           
            % cluster the pixels - ie, label organelles for size/#
            % measurements:
            these_cc = bwconncomp(orgs_bw(cell_coords{c}(2,1):cell_coords{c}(2,2),...
                    cell_coords{c}(1,1):cell_coords{c}(1,2),:), CC);
            % store centroids for these organelles
            centroids{c} = regionprops(these_cc, 'Centroid');
            
            % now let's collect sizes from our labeling
            % iter thru objects labeled by algorithm, in this cell
            for n=1:these_cc.NumObjects
                % grab an organelle from this cell:
                this_org = length(these_cc.PixelIdxList{n});
                % enforce size range on organelle  
                if this_org > MIN_ORG_SIZE && this_org < MAX_ORG_SIZE
                    org_volumes{c,n} = this_org;
                else
                    org_volumes{c,n} = NaN;
                end
            end

            % archive
            seg_raw_orgs{c} = orgs(cell_coords{c}(2,1):cell_coords{c}(2,2),...
                     cell_coords{c}(1,1):cell_coords{c}(1,2),Z(1):Z(2));
            seg_binary_orgs{c} = orgs_bw(cell_coords{c}(2,1):cell_coords{c}(2,2),...
                     cell_coords{c}(1,1):cell_coords{c}(1,2),:);
            seg_edge_orgs{c} = orgs_edge(cell_coords{c}(2,1):cell_coords{c}(2,2),...
                     cell_coords{c}(1,1):cell_coords{c}(1,2),:);
            conncomp{c} = these_cc;
        end
    end

    clear these_orgs these_orgs_filt these_orgs_edge these_cc this_org these_centroids
    clear c n z 
    disp('-------- PROCESSED --------')


    %% organize data

    % figure out max # orgs in population
    [rows,cols] = size(org_volumes);
    for i=1:rows
        for j=1:cols
            if isempty(org_volumes{i,j})
                org_volumes{i,j} = NaN;
            end
        end
    end

    volumes = cell2mat(org_volumes); [M,N] = size(volumes);
    [~,col1] = sort(~isnan(volumes),2,'descend'); row1 = repmat(1:M,N,1)';
    restructured_indices = sub2ind(size(volumes),row1(:),col1(:));
    volumes = reshape(volumes(restructured_indices),M,N);
    volumes(:,all(isnan(volumes),1)) = [];
    % archive
    data.volumes = volumes;
    data.cell_sizes = cell_sizes;

    data.PARAMS = PARAMS;

    data.seg_raw_orgs = seg_raw_orgs;
    data.seg_binary_orgs = seg_binary_orgs;
    data.seg_edge_orgs = seg_edge_orgs;
    data.org_volumes = org_volumes;
    data.centroids = centroids;
    data.conncomp = conncomp;

end

function [L_norm, maxCurv] = laplace(image)
    
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




