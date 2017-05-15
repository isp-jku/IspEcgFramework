classdef Constants
    % Constants Library wide constants like the version number and date
    
    properties (Constant)
        Version = string('2.0.0-beta'); % Version string. This library uses semantic versioning
        VersionData = string('2017-05-15');
        MakerPointNotSpecified = int32.empty(0,0);
        NotAFeature = -1;
    end
    
    methods
    end
end