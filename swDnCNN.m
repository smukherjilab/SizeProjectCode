%%%% PARAMETERS TO CHANGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input and output path
pathFolderIn = 'D:\Documents\Files\images\Try11_Leucine75100';
pathFolderOut = 'D:\Documents\Files\denoised\Try11_Leucine75100';
pattern = '4channel_unmixed';

% parameters for image normalization
prcLow = 3;
prcHigh = 99.9;

%%%% CODE STARTS HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

net = denoisingNetwork('DnCNN');

filesIn = filesInFolder(pathFolderIn,pattern,true);
for j = 1:length(filesIn)
    imgPath = fullfile(filesIn(j).folder, filesIn(j).name);
    [image,meta] = fileToMatrices(imgPath);
    numChannels = meta(3);
    numX = meta(1);
    numY = meta(2);
    numPixels = numX * numY;
    imgDenoised = uint16(zeros(numX, numY, numChannels)); % QUESTION: can we use a cell to do bfsave?
    for i = 1:numChannels % numChannels
        forNormal = reshape(image{i},[numPixels,1]);
        pixelMin = prctile(forNormal, prcLow);
        pixelMax = prctile(forNormal, prcHigh);
        imgDenoised(:,:,i) = uint16(65536*(image{i} - pixelMin)/(pixelMax - pixelMin));
        imgDenoised(:,:,i) = denoiseImage(imgDenoised(:,:,i), net);
    end
    % save the image to folders similar to input
    pathSubfolderOut = strrep(filesIn(j).folder, pathFolderIn, pathFolderOut);
    fileNameOut = strrep(filesIn(j).name, '.nd2', '_denoised.tiff');
    if (~exist(pathSubfolderOut, 'dir'))
        mkdir(pathSubfolderOut); 
    end % create the folder if not exist
    pathOut = fullfile(pathSubfolderOut, fileNameOut);
    bfsave(imgDenoised, pathOut, 'BigTiff', true)
end

