function [maxOrgs, meanSizesByN, cvByN] = sc(volumes,varargin)
    
    if isempty(varargin)
        figure();
        color ='black';
    elseif length(varargin) == 1
%         figure();
%         color = varargin{1};
    else
%         color = varargin{1};
        hold on;
    end
    % get max orgs of population
    maxOrgs = 0;
    volumes = volumes/max(volumes(:));
    for i=1:size(volumes,1)
        thisCell = volumes(i,:);            % grab cell
        thisCell = thisCell(thisCell>0);        % filter out 0s/NaNs
        if length(thisCell) > maxOrgs
            maxOrgs = length(thisCell);
        end
    end

    % bin the avg intracellular sizes by number 
    meanSizesByN = cell(maxOrgs,1);
    cvByN = cell(maxOrgs,1);
    for i=1:size(volumes,1)
        thisCell = volumes(i,:);     
        thisCell = thisCell(thisCell > 0);        
        thisN = length(thisCell);
        
        if thisN < 1            % if row is empty, skip
            continue
        end
        meanSizesByN{thisN} = [meanSizesByN{thisN} mean(thisCell)];
        cvByN{thisN} = [cvByN{thisN} std(thisCell)/mean(thisCell)];
    end
    
    title('Avg Intracellular Size vs. Avg Intracellular CV, binned by N')
    xlabel('Avg Intracellular Size')
    ylabel('Avg Intracellular CV')
    hold on;
    maxMean = 0;
    maxCV = 0;
    mean_plot = zeros(maxOrgs-1,1);
    cv_plot = zeros(maxOrgs-1,1);
%     
%     red = [0,0.1,0]; pink = [255, 192, 203]/255; 
%     l = maxOrgs;
%     colors_p = [linspace(red(1),pink(1),l)', linspace(red(2),pink(2),l)', linspace(red(3),pink(3),l)'];
    colors_p = jet(maxOrgs);
    for i=2:maxOrgs
        
        scatter(mean(meanSizesByN{i}), mean(cvByN{i}), 50, 'filled', 'MarkerFaceColor',colors_p(i,:));
        errorbar(mean(meanSizesByN{i}), mean(cvByN{i}),...
            std(cvByN{i})/sqrt(length(cvByN{i})),'Color','black')
        
%         errorbar(mean(meanSizesByN{i}), mean(cvByN{i}),...
%             std(meanSizesByN{i})/sqrt(length(meanSizesByN{i})),'horizontal','Color','red')
        
        mean_plot(i-1) = mean(meanSizesByN{i}); 
        cv_plot(i-1) = mean(cvByN{i});
        
        if mean(meanSizesByN{i}) > maxMean
            maxMean = mean(meanSizesByN{i});
        end
        if mean(cvByN{i}) > maxCV
            maxCV = mean(cvByN{i});
        end
    end
%     plot(mean_plot, cv_plot,'LineWidth',1.5,'Color',color)
    
    xlim([0, (0.5)])
    ylim([0, (1.5)])
    colorbar
    
end