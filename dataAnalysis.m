% load('finally.mat')
labels = ['ER','lipid droplets','mitochondrion'];
orgNum = zeros(1,3);
orgSize = zeros(1,3);

% March 22, 2019
for i=1:3
    orgNum = length(dataCell{i,1});
    orgAll=[];
    for j=1:orgNum
        orgAll = [orgAll;length(dataCell{i,1}{j,1})];    
    end
    orgAll = sort(orgAll);
    orgAll = orgAll(1:int16(0.95*length(orgAll)));
    [~,edges] = histcounts(orgAll,15);
    orgSize = zeros(orgNum,length(edges)-1);
    for k=1:orgNum
        orgSize(k,:) = histcounts(dataCell{i,1}{k,1},edges);
    end
    subplot(1,3,i);
    heatmap(orgSize);
    h = bar3(orgSize);
    nColors  = size(get(gcf, 'colormap'), 1);
    colorInd = randi(nColors, orgNum, length(edges)-1);
    for m = 1:length(edges)-1
        c     = get(h(m), 'CData');
        color = repelem(repmat(colorInd(:, m), 1, 4), 6, 1);
        set(h(m), 'CData', color);
    end
end