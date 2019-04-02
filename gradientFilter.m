function imgGradient = gradientFilter(image,dim)
    switch dim
        case 2
            imgGradient = imgradient(image);
        case 3
            imgGradient = imgradient3(image);
    end
end