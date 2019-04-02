function objLabelMatrix = objBinarize(imageIn,rMin,rMax,flagGround)
    % SANITY CHECK
    if strcmp(flagGround,'foreground')||strcmp(flagGround,'background') % do nothing
    else
        error('ERROR: wrong option for object recognizing method'); 
    end
    
    dim = length(size(imageIn));
    if dim>3; error('ERROR: cellSegment() receives inputs w/ too many dimensions'); end
    if isscalar(imageIn); error('ERROR: cellSegment receives a scallar as input'); end
    
    % OPTIONAL ARGUMENT PARSING

    % PARAMETERS
    rClose = max(0.8*rMin,2); % 0.8 is a PARAMETER
    volumeMax = 3 * pi * rMax^dim; % 3 is a PARAMETER

    % PROCESS
    if strcmp(flagGround,'foreground')
        objLabelMatrix = objSegForeground(imageIn, dim, rClose);
    elseif strcmp(flagGround,'background')
        objLabelMatrix = objSegBackground(imageIn, dim, rClose, volumeMax);
    end
end

function objLabelMatrix = objSegForeground(imageIn, dim, rClose)
    % used for images where cells are filled, not outlined
    % INPUT - cellImage:       2d or 3d image matrix
    % INPUT - rMin:            radius of the smallest cell (NOT DIAMETER!)
    % INPUT - rMax:            radius of the largest cell  (NOT DIAMETER!)
    % OUTPUT - objLabelMatrix: label matrix of the detected objects

    % March 27, 2019
    image1 = locallapfilt(int16(imageIn), 0.4, 0.5); % sigma = 0.4; alpha = 0.5
    image2 = imbinarize(image1);
    se0 = strel('diamond',1);
    image3 = imopen(image2,se0);
    objLabelMatrix = imclearborder(image3,8);
    
%     % Step 1: Apply open-reconstruction and close-reconstruction to the gray scale cell image
%     switch dim
%         case 2
%             se1 = strel('disk',rClose);
%         case 3
%             se1 = strel('sphere',rClose);
%     end
%     image2 = medianFilter(imageIn, dim);
%     % start binarize
%     threshold = multithresh(image2);
%     image21 = imquantize(image2,threshold);
%     image3 = image21>1;
%     % end binarize
%     image4 = imopen(image3,se1);
%     % start watershed
%     
end

function objLabelMatrix = objSegBackground(imageIn, dim, rClose, volumeMax)
    % segment cells where they are surrounded by bright dye.
    % INPUT - cellImage: 2d or 3d image matrix
    % INPUT - rMin:      The radius of the smallest cell (NOT DIAMETER!) to
    %                    set the radius of the close filter.
    % INPUT - rMax:      The radius of the largest cell (NOT DIAMETER!) to
    %                    deicide the maximum of accepted cell area/volume
    % FUTHRE OUTPUT - indexField: 2d or 3d binary image matrix
    
    % SANITY CHECK
    
    % PROCESS
    % binarize by thresholding
    threshold = multithresh(imageIn,3); % 3 IS A PARAMETER. 
    image1 = imquantize(imageIn,threshold);
    image2 = image1>1; % 1 IS A PARAMETER
    % close filter with radius rClose
    switch dim
        case 2
            structElem = strel('disk',rClose);
        case 3
            structElem = strel('sphere',rClose);
    end
    image3 = imclose( image2, structElem );
    % exclude far background (false potisive cells with areas too large)
    % MAYBE use axial length rather than volume to exclude.
    image4 = ~image3;
    image5 = labelmatrix( bwconncomp(image4) ); % could add parameter conn
    numRegions = max(image5(:));
    for i = 1:numRegions
        if sum(image5(:)==i) > volumeMax
            image5(image5==i) = 0;
        end
    end
    image5 = logical(image5);
    % RETURN
    objLabelMatrix = imclearborder(image5,8);

end
