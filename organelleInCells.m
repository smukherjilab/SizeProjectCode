function resultCell = organelleInCells(orgRawImage,cellLabelMatrix)
    % NOT WORKING WITH 3D YET.
    dim = length(size(cellLabelMatrix));
    if dim~=2
        warning('WARNING: function does not support 3D matrics');        
    end
    numCells = max(cellLabelMatrix(:));
    resultCell = cell(numCells,1);
    % THE FOLLOWING PART DOES NOT WORK AS EXPECTED IN 3D    
    for i=1:numCells
        mask = (cellLabelMatrix == i);
        [row,col] = find(mask);
        xmin = min(row);
        xmax = max(row);
        ymin = min(col);
        ymax = max(col);
        window = orgRawImage(xmin:xmax,ymin:ymax);
        % window = double( window - min( window(:) ) );
        % RETURN
        orgLabelMatrix = objBinarize(window, 0, 100, 'foreground');
        orgLabelMask = orgLabelMatrix .* mask(xmin:xmax,ymin:ymax) ;
        orgLabel = labelmatrix( bwconncomp(orgLabelMask) );
        numOrg = max(orgLabel(:));
        resultVector = zeros(1,numOrg);
        for j = 1:numOrg
            resultVector(j) = length( find(orgLabel==j) );
        end
        resultCell{i} = resultVector;
    end
end
