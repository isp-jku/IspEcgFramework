classdef Settings < handle
    %SETTINGS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        settingsMap containers.Map = containers.Map('KeyType', 'string');
    end
    
    methods (Access = public)
        function obj = Settings()
            % obj.put('IspEcgFramework.io.FileCache.openIfLocked', false);
            % maybe not a too good idea anyway
        end
        
        function obj = put(obj, key, data)
            obj.settingsMap(key) = data;
        end
        
        function data = get(obj, key)
            data = obj.settingsMap(key);
        end
        
        function exists = exists(obj, key)
            exists = obj.settingsMap.isKey(key);
        end
        
        function data = remove(obj, key)
            data = obj.settingsMap(key);
            obj.settingsMap.remove(key);
        end
    end
    
end