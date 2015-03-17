classdef (Abstract) Discoverable < handle
    
    properties (Abstract, Constant)
        displayName
        version
    end
    
    properties (Transient, Hidden)
        id
    end
    
    methods
        
        function setId(obj, id)
            if ~isempty(obj.id)
                error('Id is already set');
            end
            obj.id = id;
        end
        
    end
    
end
