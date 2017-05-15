classdef (Sealed) Configuration < handle
    % Configuration Singelton that holds the global configuration objects
    %   Global configuration like error messages are configured in an
    %   instance of this class.
    %   This class is not thread safe.
    
    properties (Access = public)
        ValidationHelper IspEcgFramework.util.ValidationHelper = IspEcgFramework.util.DefaultValidationHelper();
        Settings IspEcgFramework.util.Settings = IspEcgFramework.util.Settings();
    end
    
    methods (Access = private)
        function obj = Configuration()
        end
    end
    
    methods (Static)
        function obj = getInstance()
            % Get the current Configuration instance.
            %   Please call this method at least once before you call it
            %   inside a parfor loop because the getInstance() method is
            %   not thread safe.
            persistent instance;
            if isempty(instance) || ~isvalid(instance)
                instance  = IspEcgFramework.util.Configuration();
            end
            obj = instance;
        end
    end
    
end