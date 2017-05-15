classdef (Abstract) Cache < handle
    %CACHE A simple key/Data store
    %   Detailed explanation goes here
    
    methods (Access = public)
        function obj = putIfAbsent(obj, key, data)
            if (~obj.exists(key))
                obj.put(key, data);
            end
        end
    end
    
    methods (Abstract, Access = public)
        put(obj, key, data)
        get(obj, key)
        exists(obj, key)
        evict(obj, key)
    end
    
end