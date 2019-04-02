function imageOut = gaussFilter(imageIn,sigma,dim)
    switch dim
        case 2
            imageOut = imgaussfilt(imageIn, sigma);
        case 3
            imageOut = imgaussfilt3(imageIn, sigma);
    end
end
