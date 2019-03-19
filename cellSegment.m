function [binaryField,cellBounds] = cellSegment(cellImage)
    dim = length(size(cellImage));
    switch dim
        case 2
            connectivity = 4;
        case 3
            connectivity = 8;
        otherwise
            error('ERROR: Wrong dimension for input to cellSegment()')
    end
    binaryField = imbinarize(cellImage,'global');
    binaryField = imfill(binaryField,connectivity,'holes');
    cellBounds = bwboundaries(binaryField,connectivity,'noholes');
end