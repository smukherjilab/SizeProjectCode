%%%%    DOCUMENT    %%%%
% INPUT:  image,   a 2D matrix of pixels
% RETURN: volumes, a M*N matrix of volumes of an organelle 
% all file manipulations should be dealt with by other functions.

function volumes = organelleAnalysis2D(image,minSize,maxSize)
    object_sizes = {};
    % [x,y] = size(image);
    filtSlice = imgaussfilt(image,2); % may need more blurring here
    binary_slice = laplace(filtSlice) > 0.1;
    image_conncomp = bwconncomp(binary_slice,6);  % define objects within matrix
    for i=1:image_conncomp.NumObjects
        organelle_size = length(image_conncomp.PixelIdxList{i});
        if organelle_size > minSize-1 && organelle_size < maxSize+1
            object_sizes{i}=organelle_size;
        end
    end
    [rows,cols] = size(object_sizes);
    for i=1:rows
        for j=1:cols
            if isempty(object_sizes{i,j})
                object_sizes{i,j} = NaN;
            end
        end
    end
    volumes = cell2mat(object_sizes);
    [M,N] = size(volumes);
    [~,col1] = sort(~isnan(volumes),2,'descend');
    row1 = repmat(1:M,N,1);
    restructured_indices = sub2ind(size(volumes),row1(:),col1(:));
    volumes = reshape(volumes(restructured_indices),M,N);
end