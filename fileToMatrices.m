function [imgCells, mata] = fileToMatrices(path)
    % requires bfopen.m
    % INPUT:  path:     the file path (not the folder path)
    % OUTPUT: imgCells: a cell of length (numChannels) 2-dimensional (x,y) matrix of (various) type
    %                   We use cell rather than matrix to distinguish channels with z-stack
    imgRead = bfopen(path);
    numChannels = length(imgRead{1,1});
    numX = length(imgRead{1,1}{1,1});
    numY = length(imgRead{1,1}{1,1}(1,:));
    imgCells = cell(numChannels,1);
    for i = 1:numChannels
        imgCells{i} = double(imgRead{1,1}{i,1}); % QUESTION: do we really need the type conversion?
    end
    mata = [numX,numY,numChannels]; % may need to change to XYZCT in the future.
end 