

%% script where i run the analysis for allometry

%% first, wt golgi
tic;
po = {'/Volumes/Asa Physarum Backup/Size Control/Images for Paper/Golgi Camera/golgifilter29.tif',...
    '/Volumes/Asa Physarum Backup/Size Control/Images for Paper/Golgi Camera/golgifilter37.tif',...
    '/Volumes/Asa Physarum Backup/Size Control/Images for Paper/Golgi Camera/golgifilter50.tif',...
    '/Volumes/Asa Physarum Backup/Size Control/Images for Paper/Golgi Camera/golgifilter55.tif'};
pm = {'/Volumes/Asa Physarum Backup/Size Control/Images for Paper/Golgi Camera/Sec7mKO2_YFPfromATPFRET029-cells_bw.mat',...
    '/Volumes/Asa Physarum Backup/Size Control/Images for Paper/Golgi Camera/Sec7mKO2_YFPfromATPFRET037-cells_bw.mat',...
    '/Volumes/Asa Physarum Backup/Size Control/Images for Paper/Golgi Camera/Sec7mKO2_YFPfromATPFRET050-cells_bw.mat',...
    '/Volumes/Asa Physarum Backup/Size Control/Images for Paper/Golgi Camera/Sec7mKO2_YFPfromATPFRET055-cells_bw.mat'};
% Z = {[14 28], [6 20], [4 18], [5 19]};
Z = {[13 29], [5 21], [3 19], [4 20]};
MIN_SAMPLE = 10;
T_range = 3;%2.5:0.5:3.5;
S_range = 1;
STREL_SIZE = 5;%[3,5,7];
MIN_ORG_SIZE_range = 40;%20:10:40;
CC = 6;
num_sets = length(T_range)*length(S_range)*length(MIN_ORG_SIZE_range)*length(STREL_SIZE);
golgi29_load = bfopen(po{1});
golgi29_orgs = zeros([size(golgi29_load{1,1}{1,1}), length(golgi29_load{1,1})]);
for z=1:length(golgi29_load{1,1})
    golgi29_orgs(:,:,z) = double(golgi29_load{1,1}{z,1});
end
golgi29_dist = sweep_process(T_range, S_range, MIN_ORG_SIZE_range,...
    golgi29_orgs, pm{1}, Z{1}, CC, STREL_SIZE,'min_cell_size',1000, 'max_org_size',800);
%%%%
golgi37_load = bfopen(po{2});
golgi37_orgs = zeros([size(golgi37_load{1,1}{1,1}), length(golgi37_load{1,1})]);
for z=1:length(golgi37_load{1,1})
    golgi37_orgs(:,:,z) = double(golgi37_load{1,1}{z,1});
end
golgi37_dist = sweep_process(T_range, S_range, MIN_ORG_SIZE_range,...
    golgi37_orgs, pm{2}, Z{2}, CC,STREL_SIZE, 'min_cell_size',1000, 'max_org_size',800);
%%%%
golgi50_load = bfopen(po{3});
golgi50_orgs = zeros([size(golgi50_load{1,1}{1,1}), length(golgi50_load{1,1})]);
for z=1:length(golgi50_load{1,1})
    golgi50_orgs(:,:,z) = double(golgi50_load{1,1}{z,1});
end
golgi50_dist = sweep_process(T_range, S_range, MIN_ORG_SIZE_range,...
    golgi50_orgs, pm{3}, Z{3}, CC, STREL_SIZE,'min_cell_size',1000, 'max_org_size',800);
%%%%
golgi55_load = bfopen(po{4});
golgi55_orgs = zeros([size(golgi55_load{1,1}{1,1}), length(golgi55_load{1,1})]);
for z=1:length(golgi55_load{1,1})
    golgi55_orgs(:,:,z) = double(golgi55_load{1,1}{z,1});
end
golgi55_dist = sweep_process(T_range, S_range, MIN_ORG_SIZE_range,...
    golgi55_orgs, pm{4}, Z{4}, CC, STREL_SIZE,'min_cell_size',1000, 'max_org_size',800);

% merge
for i=1:num_sets
    golgi_dist.data{i,1} = CatStructFields(golgi29_dist.data{i,1},golgi37_dist.data{i,1},1);
    golgi_dist.data{i,1} = CatStructFields(golgi_dist.data{i,1},golgi50_dist.data{i,1},1);
    golgi_dist.data{i,1} = CatStructFields(golgi_dist.data{i,1},golgi55_dist.data{i,1},1);
end
golgi_volumes = get_volumes(golgi29_dist,golgi37_dist,golgi50_dist,golgi55_dist);
golgi_cell_sizes = get_cellsizes(golgi29_dist,golgi37_dist,golgi50_dist,golgi55_dist);

toc

%% check data


%% prep data to plot

rows = floor(sqrt(length(golgi_volumes)));
cols = ceil(length(golgi_volumes)/rows);
% N vs S
x_n = cell([length(golgi_volumes), 1]);
y_n = cell([length(golgi_volumes), 1]);

% org size vs CV
x_cv = cell([length(golgi_volumes), 1]);
y_cv = cell([length(golgi_volumes), 1]);

% cell size vs total V
x_c = cell([length(golgi_volumes), 1]);
y_c = cell([length(golgi_volumes), 1]);

max_orgs = zeros([length(golgi_volumes),1]);
for i=1:length(golgi_volumes)
    
    this_v = golgi_volumes{i};
    this_c = golgi_cell_sizes{i};
    
    max_org = 0;
    % get x-values for N vs S
    for j=1:size(this_v,1)
        if isnan(this_v(j,1))
            continue
        else
            this_cell = this_v(j,:); this_cell = this_cell(this_cell>0);
            x_n{i} = [x_n{i} length(this_cell)];
            y_n{i} = [y_n{i} mean(this_cell)];
            
            x_c{i} = [x_c{i} this_c(j)];
            y_c{i} = [y_c{i} sum(this_cell)];
            
            if length(this_cell) > max_org
                max_org = length(this_cell);
            end

        end
    end
    
    % get x-values for N vs S
    num_bins = cell([max_org,1]);
    cv_bins = cell([max_org,1]);
    for j=1:size(this_v,1)
        if isnan(this_v(j,1))
            continue
        else
            this_cell = this_v(j,:); this_cell = this_cell(this_cell>0);

            num_bins{length(this_cell)} = [num_bins{length(this_cell)} mean(this_cell)];
            cv_bins{length(this_cell)} = [cv_bins{length(this_cell)} std(this_cell)/mean(this_cell)];
            
            
        end
    end
    
    for j=1:max_org
        x_cv{i} = [x_cv{i} mean(num_bins{j})];
        y_cv{i} = [y_cv{i} mean(cv_bins{j})];
    end
    max_orgs(i) = max_org;
end

% go back and get sample sizes
counts = cell([length(golgi_volumes),1]);
for i=1:length(counts)
    counts{i} = zeros([max_orgs(i),1]);
end
for i=1:length(counts)
    this_v = golgi_volumes{i};
    this_c = golgi_cell_sizes{i};
    
    % get x-values for N vs S
    for j=1:size(this_v,1)
        if isnan(this_v(j,1))
            continue
        else
            this_cell = this_v(j,:);
            this_cell = this_cell(this_cell>0);
            counts{i}(length(this_cell),1) = counts{i}(length(this_cell),1)+ 1;
        end
    end
end

%% now visualize
colors = parula(length(golgi_volumes));

figure('Name', 'N vs S'); 
hold on;
for i=1:length(golgi_volumes)
    plot(x_n{i},y_n{i},'Color',colors(i,:));
end

figure('Name', 'Cell size vs TotVolume'); 
hold on;
for i=1:length(golgi_volumes) 
    scatter(x_c{i},y_c{i},35,'filled','MarkerFaceColor',colors(i,:),'MarkerEdgeColor',colors(i,:));
end

%% visualize dist for N v <S>
num_iters = length(T_range)*length(S_range)*length(MIN_ORG_SIZE_range);

figure('Name', 'N vs <S>');
params = zeros([num_iters,4]);
n = 0;
for T=1:length(T_range)
    for S=1:length(S_range)
        for M=1:length(MIN_ORG_SIZE_range)
            for SE=1:length(STREL_SIZE)
                n = n + 1;
                params(n,:) = [T_range(T), S_range(S), MIN_ORG_SIZE_range(M) STREL_SIZE(SE)];
            end
        end
    end
end


for i=1:size(params,1)
    subplot(rows,cols,i); hold on;
    
    this_x = x_n{i};
    this_y = y_n{i};
    scatter(this_x,this_y);
    for j=1:max(x_n{i})
        
        scatter(j,mean(this_y(this_x==j)),20,'filled','MarkerFaceColor','k');
    end
    title(['T=',num2str(params(i,1)),...
        ' S=',num2str(params(i,2)),...
        ' M=',num2str(params(i,3)),...
        ' SE=',num2str(params(i,4))]);
    xlabel('Number of orgs'); ylabel('intracellular <S>')
end

%% visualize dist for <S> vs CV
figure('Name', '<S> vs CV'); 

for i=1:size(params,1)
    clear this_x this_y
    subplot(rows,cols,i); 
%     plot(x_n{i},y_n{i});
    these_samples = counts{i} > MIN_SAMPLE;

    this_x = x_cv{i}.*these_samples;
    this_y = y_cv{i}.*these_samples;
    
    scatter(this_x(2:end),this_y(2:end));
    title(['T=',num2str(params(i,1)),...
        ' S=',num2str(params(i,2)),...
        ' M=',num2str(params(i,3)),...
        ' SE=',num2str(params(i,4))]);
    ylim([0 2]);
    xlabel('intracellular <S>'); ylabel('intracellular CV')
end

%% visualize dist for cell size vs biomass
figure('Name', 'cell size vs biomass'); 

for i=1:size(params,1)
    subplot(rows,cols,i); 
%     plot(x_n{i},y_n{i});
    this_x = x_c{i};
    this_y = y_c{i};
    scatter(this_x(this_x>0),this_y(this_x>0));
    title(['T=',num2str(params(i,1)),...
        ' S=',num2str(params(i,2)),...
        ' M=',num2str(params(i,3))]);
    xlabel('cell size (2d)'); ylabel('tot organelle biomass');
    m_x = max(x_c{i});
    m_y = max(y_c{i});
    xlim([0 m_x+1000]); ylim([0 m_y+1000])
    xlim([0 6000]); ylim([0 6000])
end

