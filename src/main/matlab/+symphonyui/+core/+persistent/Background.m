classdef Background < symphonyui.core.persistent.Entity
    
    properties (SetAccess = private)
        device
    end
    
    methods
        
        function obj = Background(cobj, entityFactory)
            obj@symphonyui.core.persistent.Entity(cobj, entityFactory);
        end
        
        function d = get.device(obj)            
            d = obj.entityFactory.fromCoreEntity(obj.cobj.Device);
        end
        
        function [q, u] = getValue(obj)
            v = obj.cobj.Value;
            q = double(System.Decimal.ToDouble(v.Quantity));
            u = char(v.DisplayUnit);
        end
        
        function [q, u] = getSampleRate(obj)
            s = obj.cobj.SampleRate;
            q = double(System.Decimal.ToDouble(s.Quantity));
            u = char(s.DisplayUnit);
        end
        
    end
    
end

