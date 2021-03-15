function grayImage = place_gaussian(grayImage,W,sigma,A,numberOfGaussians,varargin)

if isempty(varargin)
    [rows,columns]=size(grayImage);

    for k = 1 : numberOfGaussians
        g = fspecial('gaussian',W(k),sigma(k));
        randR = randi(rows-W(k)+1, [1 numberOfGaussians]);
        randC = randi(columns-W(k)+1, [1 numberOfGaussians]);

      grayImage(randR(k):randR(k)+W(k)-1, randC(k):randC(k)+W(k)-1) = ...
        grayImage(randR(k):randR(k)+W(k)-1, randC(k):randC(k)+W(k)-1) + ...
        g;
    end
elseif contains(varargin{1},'flat')
    [rows,columns]=size(grayImage);
    if sigma <= 0
        sigma = 0.1;
        disp('forced sigma');
    end
    for k = 1 : numberOfGaussians
        g = fspecial('gaussian',W(k),sigma(k));
        randR = randi(rows-W(k)+1, [1 numberOfGaussians]);
        randC = randi(columns-W(k)+1, [1 numberOfGaussians]);

      grayImage(randR(k):randR(k)+W(k)-1, randC(k):randC(k)+W(k)-1) = ...
        grayImage(randR(k):randR(k)+W(k)-1, randC(k):randC(k)+W(k)-1) + ...
        g;
    end
    grayImage = grayImage(:);
elseif contains(varargin{1},'mc')
    allImages = zeros([numel(grayImage),varargin{2}]);
    [rows,columns]=size(grayImage);
    for r=1:varargin{2}
        
        g = fspecial('gaussian',W,sigma(r));
        randR = randi(rows-W+1, [1 1]);
        randC = randi(columns-W+1, [1 1]);

      grayImage(randR:randR+W-1, randC:randC+W-1) = ...
        grayImage(randR:randR+W-1, randC:randC+W-1) + ...
        g;
        img = grayImage(:);
        allImages(:,r) = A(r)*img;
    end
    grayImage = allImages;
end

end