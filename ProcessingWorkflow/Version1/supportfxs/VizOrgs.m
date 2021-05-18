function [] = VizOrgs(stack,Tinit,varargin)


    f = figure;
    ax = axes('Parent',f,'position',[0.13 0.39  0.77 0.54]);
    h = VoxelPlotter(stack > Tinit);
    
    if isempty(varargin)
        xlim([0 size(stack,1)]); ylim([0 size(stack,2)]); zlim([0 size(stack,3)]);
    else
        xlim([0 varargin{1}]); ylim([0 varargin{2}]); zlim([varargin{3} varargin{4}]);
    end

    bgcolor = f.Color;
    b = uicontrol('Parent',f,'Style','slider','Position',[81,54,419,23],...
                  'value',Tinit, 'min',0, 'max',1);

    bl1 = uicontrol('Parent',f,'Style','text','Position',[50,54,23,23],...
                    'String','0','BackgroundColor',bgcolor);
    bl2 = uicontrol('Parent',f,'Style','text','Position',[500,54,23,23],...
                    'String','1','BackgroundColor',bgcolor);
    bl3 = uicontrol('Parent',f,'Style','text','Position',[240,25,100,23],...
                    'String','Threshold','BackgroundColor',bgcolor);

    b.Callback = @(es,ed) updateSystem(h,VoxelPlotter(stack>es.Value,1));
end