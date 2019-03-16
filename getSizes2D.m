function [cell_sizes,volumes,binary_orgs] = getSizes2D(cell_bounds,binary_cells,orgs,organelleType)
    % binary_cells, orgs are all 2D matrices.
    % organelleType: 'globular' or 'tubular'
    minBounds = 75; % actually this is a parameter
    numCells = 0;
    for i=1:length(cell_bounds)
        if length(cell_bounds{i}) > minBounds
            numCells = numCells + 1;
        else
            continue
        end
    end
    cell_sizes = zeros(1,length(cell_bounds));
    org_sizes = {};
    
  
    for i=1:length(cell_bounds)
        this_bounds = cell_bounds{i};
        if length(this_bounds) < minBounds
            continue
        else
            xmin = min(this_bounds(:,2))-1; xmax = max(this_bounds(:,2))+1;
            ymin = min(this_bounds(:,1))-1; ymax = max(this_bounds(:,1))+1;
            
            if xmin<20
                continue
            end
            if xmax>2020
                continue
            end
            if ymin<20
                continue
            end
            if ymax>2020
                continue
            end
            this_cells = binary_cells(ymin:ymax,xmin:xmax);            
            cell_sizes(i) = sum(this_cells(:));
        end
    end
    big1 = 0;
    big2 = 0;
    binary_orgs = {};
%     slice_binaries = {};
%     for i=framerange(1):framerange(2)
%         slice_orgs = double(orgs{i});
%         filt1 = imgaussfilt(slice_orgs,2);
%         lap1 = laplace(filt1);
%         filt2 = imgaussfilt(lap1,2);
%         lap2 = laplace(filt2);
%         slice_binaries{i-framerange(1)+1} = lap2 > 0.18;
%     end

	c = 0;
    for i=1:length(cell_bounds)   %!!!!!!!!!!!!!!!!!!!!!!!!
        this_bounds = cell_bounds{i};
        c = c + 1;
        if cell_sizes(i) < 400
            org_sizes{i} = NaN;
            continue
        else
            
            xmin = min(this_bounds(:,2)); xmax = max(this_bounds(:,2));
            ymin = min(this_bounds(:,1)); ymax = max(this_bounds(:,1));
            b_cell = zeros(ymax-ymin+1,xmax-xmin+1);
            
%             maxInCell = 0;
%             for j=framerange(1):framerange(2)
%                 slice_orgs = double(orgs{j}); 
%                 this_slice = slice_orgs(ymin:ymax,xmin:xmax);
%                 
%                 thisMax = max(this_slice(:));
%                 if thisMax>maxInCell
%                     maxInCell = thisMax;
%                 end
%             end
%             if maxInCell < 26   %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                 org_sizes{i} = NaN;
%                 continue
%             end
            
            slice_orgs = double(orgs{1});

            if max(slice_orgs(:)) < 23
                continue
            end

            this_slice = slice_orgs(ymin:ymax,xmin:xmax);
            if var(this_slice(:)) < 1
                continue
            end
            h = histogram(this_slice,20);
            totalPixels = numel(this_slice);
            if sum(h.Values(10:20)) >= totalPixels/2.2
                continue
            end
            if contains(organelleType,"globular",'IgnoreCase',true)


                filt1 = imgaussfilt(this_slice,2);
                [laplace1,~] = laplace(filt1);

                filt2 = imgaussfilt(laplace1,2);
                [laplace2,~] = laplace(filt2);
                binary_slice = laplace2 > 0.1;

            elseif contains(organelleType,"tubular",'IgnoreCase',true)
                binary_slice = filtMito(this_slice); % where is this function?
            else
                error('incorrect morphology input')
            end

            b_cell(:,:) = binary_slice;  

%             for r=1:((framerange(2)-framerange(1))+1)
%                 b_cell(:,:,r) = slice_binaries{r}(ymin:ymax,xmin:xmax);
%             end
            
            % b_cell = conncompStack(b_cell);
            
            isEmpty = 0;
            
            thisFrame(:,:) = b_cell(:,:);
            totalObjectPixels = sum(thisFrame(:));

            clear thisFrame
            if totalObjectPixels < 15
                isEmpty = isEmpty + 1;
            else
                continue
            end
                             
            if isEmpty > ((framerange(2)-framerange(1)+1)-4)
                org_sizes{i} = NaN;
                continue % too many empty frames
            end
            image_conncomp = bwconncomp(b_cell,4);
            for j=1:image_conncomp.NumObjects
                this_org = length(image_conncomp.PixelIdxList{j});
                if (this_org < 25) || (this_org > 1000)
                    continue
                end
                org_sizes{i,j} = length(image_conncomp.PixelIdxList{j});                
            end
            
            binary_orgs{i} = b_cell;
            clear b_cell
        end
    end
    
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
end


