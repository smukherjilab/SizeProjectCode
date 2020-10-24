
function [maxOrgs, meanSizesByN] = sn(volumes,varargin)

    % get max orgs of population
    maxOrgs = 0;
    for i=1:size(volumes,1)
        thisCell = volumes(i,:);            % grab cell
        thisCell = thisCell(thisCell>0);        % filter out 0s/NaNs
        
        if length(thisCell) > maxOrgs
            maxOrgs = length(thisCell);
        end
    end
    
    % bin the avg intracellular sizes by number 
    meanSizesByN = cell(maxOrgs,1);
    for i=1:size(volumes,1)
        thisCell = volumes(i,:);     
        thisCell = thisCell(thisCell > 0);        
        thisN = length(thisCell);
        
        if thisN < 1            % if row is empty, skip
            continue
        end
        meanSizesByN{thisN} = [meanSizesByN{thisN} mean(thisCell)];
    end

    
    % plot
    if isempty(varargin)
        figure(); title('Number vs. Average Intracellular Size')
    else
    end
    xlabel('Number of Organelles')
    ylabel('Avg Intracellular Size')
    hold on;
    for i=1:maxOrgs
        scatter(ones(length(meanSizesByN{i}),1)*i, meanSizesByN{i},'green')
        scatter(i, mean(meanSizesByN{i}), 50, 'blue','filled')
    end
    
end