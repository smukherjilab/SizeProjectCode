function [D,S] = generate_data(sigma,A,dims,W,varargin)

    % script to tinker 
    % Set up some parameters.
    
%     sigma = 6;
%     W = 75.*ones([1,1]);
%     A = 2000;

    rows = dims(1);
    columns = dims(2);
    grayImage = zeros(rows, columns);
    
    if isempty(varargin)
        noiseS = 1;
    else 
        noiseS = varargin{1};
    end    
    
    g = fspecial('gaussian',W,sigma);
    randR = randi(rows-W+1, [1 1]);
    randC = randi(columns-W+1, [1 1]);

  grayImage(randR:randR+W-1, randC:randC+W-1) = ...
    grayImage(randR:randR+W-1, randC:randC+W-1) + ...
    g;
    grayImage = grayImage*A;
    noise = normrnd(0,noiseS,[rows columns]);
    noisyImage = grayImage + noise;

    figure();
    subplot(1,2,1); imshow(grayImage,[]); title('pure signal');
    subplot(1,2,2); imshow(noisyImage,[]); title('noisy signal')

    D = noisyImage(:);
    S = grayImage(:);
    
end