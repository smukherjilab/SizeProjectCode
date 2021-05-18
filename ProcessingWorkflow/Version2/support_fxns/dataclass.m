classdef dataclass
    
    properties
        OrgPath
        OrgImage 
        CellPath
        CellImage
        AuxPath
        AuxImage
    end
    
    methods 
        % when you initialize a dataset object, it requires a path to an
        % organelle image 
        function obj = dataclass(OrgPath)
            obj.OrgPath = OrgPath;
        end
        
        % this function actually reads the path and loads the corresponding
        % array into the object
        function obj = loadOrgImage(obj)
            load = tiffread2(obj.OrgPath);
     
            for i=1:length(load)
                img(:,:,i) = double(load(i).data);
            end
            
            obj.OrgImage = img;
        end
        
        % load an image of cells into object, for segmentation
        function obj = loadCellImage(obj)
            
            if contains(obj.CellPath,'.mat')
                l = load(obj.CellPath);
                f = fieldnames(l);
                obj.CellImage = getfield(l,f{1});
                
            elseif contains(obj.CellPath,'.tif')
                l = tiffread2(obj.CellPath);

                for i=1:length(l)
                    img(:,:,i) = double(l(i).data);
                end

                obj.CellImage = img;
            end
        end
        % load an image of cells into object, for segmentation
        function obj = loadAuxImage(obj)
            
            if contains(obj.AuxPath,'.mat')
                % fill in
            elseif contains(obj.AuxPath,'.tif')
                l = tiffread2(obj.AuxPath);

                for i=1:length(l)
                    img(:,:,i) = double(l(i).data);
                end

                obj.AuxImage = img;
            end
        end
    
    end
end