
% This is a Matlab script for single-cell measurements of size & number. 
% NOTE: This version assumes you want 3D size and that your input is 1 stack of a field of organelles,
% and 1 slice of a field their cells
        

%%%%IMPORTANT PARAMETERS

% which frames of organelle stack do we care about? 
% skipping some of the first and last slices can help the code avoid noise 
framerange = [1 32]; 

% decide if you want cells to be lightly deconvolved
deconv = True; % or False
% psfpath = '/Users/asakalish/Desktop/psf.tif'  % uncomment this line if deconv=True


% these parameters can help us avoid noise (eg minCellSize reduces error in cell segmentation)
% these parameters are highly dependent on imaging conditions
minCellSize = 1000; 
minObjInt = 50;
minOrgSize = 20;
maxOrgSize = 2000;

% after processing images, all pixels have values in range [0, 1]. Eventually, we have to decide which 
% pixels are background and which are organelle - so every pixel > thresh is labeled as an organelle
thresh = 0.2;
% size of Gaussian blur; higher sigma is a stronger blur. Standard size is [1, 2] ish
sigma = 1.5;

% paths to files
orgspath = '/Users/asakalish/Desktop/Erg6-orgs.tif';
cellspath = '/Users/asakalish/Desktop/Erg6-cells.tif';


%%%% LOAD IMAGES
loadorgs = tiffread2(orgspath);
orgs = zeros(2044,2048,31);
for i=1:31
    orgs(:,:,i) = double(loadorgs(i).data);
end
loadcells = tiffread2(cellspath);
cells = double(cells.data);


%%%% SEGMENTATION OF CELLS


% use the function "b_fill_water.m" to binarize the cells
binary_cells = b_fill_water(cells);
% use Matlab's builtin function "bwboundaries()" to get coordinates of cell boundaries
cell_bounds = bwboundaries(binary_cells,4,'noholes');
disp('Segmentation Complete')



% Now we iterate thru the identified cells and get 2D cell size
% (NOTE: this code is a bit superfluous - I just like separating tasks for clarity, particularly because 
%	 these operations are very computationally inexpensive
cell_sizes = zeros(1,length(cell_bounds));
org_sizes = {};
cellAvg = {};

for i=1:length(cell_bounds)
        this_bounds = cell_bounds{i};
        if polyarea(this_bounds(:,1),this_bounds(:,2)) < minCellSize
            continue
        else
            xmin = min(this_bounds(:,2))-1; xmax = max(this_bounds(:,2))+1;
            ymin = min(this_bounds(:,1))-1; ymax = max(this_bounds(:,1))+1;
            
            if xmin<50   
                continue
            end
            if xmax>1995
                continue
            end
            if ymin<50
                continue
            end
            if ymax>1995
                continue
            end
            
            this_cells = binary_cells(ymin:ymax,xmin:xmax);
            
            if sum(this_cells(:)) > minCellSize
               cell_sizes(i) = sum(this_cells(:));
            else
                continue
            end
        end
end


% Now we iterate thru the cells and compute the size&number of their organelles

for i=1:length(cell_bounds)   
        this_bounds = cell_bounds{i};
        if cell_sizes(i) < minCellSize
            org_sizes{i} = NaN;
            continue
        else
            
            xmin = min(this_bounds(:,2)); xmax = max(this_bounds(:,2));
            ymin = min(this_bounds(:,1)); ymax = max(this_bounds(:,1));
            b_cell = zeros(ymax-ymin+1,xmax-xmin+1,framerange(2)-framerange(1)+1);
            
            this_cell = orgs(ymin:ymax,xmin:xmax,:);
            maxInCell = max(this_cell(:));
	
% 	sometimes I uncomment this if statement; other times it can help throw out noise    
            if maxInCell < minObjInt    
                org_sizes{i} = NaN;
                continue
            end
            
            for j=framerange(1):framerange(2)
                
                slice_orgs = double(orgs(:,:,j));
                this_slice = slice_orgs(ymin:ymax,xmin:xmax);
		
% 	sometimes I uncomment this if statement; other times it can help throw out noise		
                if max(this_slice(:)) < minObjInt
                    continue
                end
                
                this_slice = slice_orgs(ymin:ymax,xmin:xmax);
                filt1 = imgaussfilt(this_slice,sigma);
                laplace1 = laplace(filt1);
                binary_slice = laplace1>thresh;
              
%	you'll want to use a different thresholding method, "filtMito()" if you're analyzing tubular stuff
%	like mito (filtering is based on Frangi Vessel detection, lots of info online)
%                 binary_slice = filtMito(this_slice,thresh);
                b_cell(:,:,j-framerange(1)+1) = binary_slice;
                
            end
            
	    % matlab's function "bwconncomp" accepts labeled images and figures out how many objects there are,
	    % and what their sizes are
            image_conncomp = bwconncomp(b_cell,6);
            for j=1:image_conncomp.NumObjects
                this_org = length(image_conncomp.PixelIdxList{j});
                if (this_org < minOrgSize) || (this_org > maxOrgSize) 
                    continue
                end
                org_sizes{i,j} = length(image_conncomp.PixelIdxList{j});                
            end
            
            binary_orgs{i} = b_cell;
            clear b_cell
        end
end

% Remaining lines just organize the data. 
[rows,cols] = size(org_sizes);
for i=1:rows
    for j=1:cols
        if isempty(org_sizes{i,j})
            org_sizes{i,j} = NaN;
        end
	end
end
    
volumes = cell2mat(org_sizes);          
[M,N] = size(volumes);
[~,col1] = sort(~isnan(volumes),2,'descend');       
row1 = repmat(1:M,N,1)';
restructured_indices = sub2ind(size(volumes),row1(:),col1(:));
volumes = reshape(volumes(restructured_indices),M,N);


