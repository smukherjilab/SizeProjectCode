
function [maxOrgs, meanSizesByN,coeff] = sn(volumes,varargin)

    % get max orgs of population
    maxOrgs = 0;
    for i=1:size(volumes,1)
        thisCell = volumes(i,:);            % grab cell
        thisCell = thisCell(thisCell>0);        % filter out 0s/NaNs
        
        if length(thisCell) > maxOrgs
            maxOrgs = length(thisCell);
        end
    end
    coeff=0;
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
        xlabel('Number of Organelles')
        ylabel('Avg Intracellular Size')
        hold on;
        for i=1:maxOrgs
            scatter(ones(length(meanSizesByN{i}),1)*i, meanSizesByN{i},'green')
            scatter(i, mean(meanSizesByN{i}), 50, 'blue','filled')
        end
    else
%         color = varargin{1};
%         xlabel('Number of Organelles')
%         ylabel('Avg Intracellular Size')
        if contains(varargin{1},'nograph')
            all_means = [];
            for i=1:maxOrgs
    %             scatter(ones(length(meanSizesByN{i}),1)*i, meanSizesByN{i},'green')
%                 scatter(i, mean(meanSizesByN{i}), 100, 'blue','filled')
                all_means  = [all_means mean(meanSizesByN{i})];
            end

            idx = ~isnan(all_means);
            x = 1:maxOrgs;
            coeff = polyfit(x(idx),all_means(idx),1);
        else 
            hold on;
            all_means = [];
            for i=1:maxOrgs
    %             scatter(ones(length(meanSizesByN{i}),1)*i, meanSizesByN{i},'green')
                scatter(i, mean(meanSizesByN{i}), 100, 'blue','filled')
                all_means  = [all_means mean(meanSizesByN{i})];
            end

            idx = ~isnan(all_means);
            x = 1:maxOrgs;

            coeff = polyfit(x(idx),all_means(idx),1);
            xFit = linspace(1,maxOrgs,1000);
            yFit = polyval(coeff, xFit);
            hold on;
%             plot(xFit,yFit,'r-','LineWidth',5);
%             text(xFit(floor(maxOrgs/2))+2,yFit(floor(maxOrgs/2))+10,num2str(coeff),'Color','red');
        end
    end
    
end