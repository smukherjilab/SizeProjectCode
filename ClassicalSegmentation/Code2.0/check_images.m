
% script to check the quality of processing
% collect a random sample on the data & visualize 
% note: a figure is created for each sample

function [] = check_images(seg_raw_orgs, seg_binary_orgs,sample_size)

    samples = randi(length(seg_raw_orgs),[sample_size, 1]); % choose samples
    
    
    
    
    
    for i=1:sample_size
        figure('Name', ['Cell ' num2str(samples(i))]);
        if isempty(seg_raw_orgs{samples(i)})
            title('Empty')
        else
            Z = size(seg_raw_orgs{samples(i)},3);
            rows = floor(sqrt(Z));
            cols = ceil(Z/rows);
            
            for z=1:Z
                subplot(rows,cols,z);
                imshowpair(imadjust(uint8(seg_raw_orgs{samples(i)}(:,:,z))),...
                    seg_binary_orgs{samples(i)}(:,:,z),'montage');
                title(['Z ' num2str(z)]);
            end
        end
        
    end

end
