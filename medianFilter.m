function imageMedian = medianFilter(image, dim)
    switch dim
        case 2
            imageMedian = medfilt2(image,'symmetric'); % 'symmetric' cannot be used on GPUs
        case 3
            imageMedian = medfilt3(image,'symmetric');
    end
end
