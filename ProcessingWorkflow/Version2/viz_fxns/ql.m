function [] = ql(img,Z,varargin)


figure();
if length(Z) == 1
    rows = floor(sqrt(Z));
    cols = ceil(Z/rows);

    if isempty(varargin)
        for i=1:Z
            subplot(rows,cols,i);
            imshow(img(:,:,i),[]);
            title(num2str(i));
        end
    elseif contains(varargin{1},'imagesc')
        for i=1:Z
            subplot(rows,cols,i);
            imagesc(img(:,:,i)); colorbar;
            title(num2str(i));
        end
    elseif contains(varargin{1},'bkgd')
        for i=1:Z
            subplot(rows,cols,i);
            imshow(bkgd_sub(img(:,:,i),varargin{2}),[]);
            title(num2str(i));
        end
    elseif contains(varargin{1},'edge')
        for i=1:Z
            subplot(rows,cols,i);
            imshow(mylaplace(img(:,:,i),varargin{2})>.2,[]);
            title(num2str(i));
        end
    end
else
    rows = floor(sqrt(Z(2)-Z(1)+1));
    cols = ceil((Z(2)-Z(1)+1)/rows);

    if isempty(varargin)
        for i=Z(1):Z(2)
            subplot(rows,cols,i-Z(1)+1);
            imshow(img(:,:,i),[]);
            title(num2str(i));
        end
    elseif contains(varargin{1},'bkgd')
        for i=Z(1):Z(2)
            subplot(rows,cols,i-Z(1)+1);
            imshow(bkgd_sub(img(:,:,i),varargin{2}),[]);
            title(num2str(i));
        end
    elseif contains(varargin{1},'edge')
        for i=Z(1):Z(2)
            subplot(rows,cols,i-Z(1)+1);
            imshow(mylaplace(img(:,:,i),varargin{2})>.2,[]);
            title(num2str(i));
        end
    end
end
end

function [binary_img,tof2] = bkgd_sub(img,STREL_SIZE)
    tof2 = imtophat(imgaussfilt(img,3),strel('square',STREL_SIZE));
    tof2 = tof2/max(tof2(:));
    binary_img = tof2;
end