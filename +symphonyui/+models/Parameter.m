classdef Parameter < hgsetget
    
    properties
        name
        type
        value
        units
        category
        displayName
        description
        isReadOnly = false
        isDependent = false
        isValid = true
    end
    
    methods
        
        function obj = Parameter(name, value, varargin)
            obj.name = name;
            obj.value = value;
            
            if nargin > 2
                obj.set(varargin{:});
            end
        end
        
    end
    
end

