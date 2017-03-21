classdef LeadNameCriteria < IspEcgFramework.filter.LeadCriteria
    %LEADNAMECRITERIA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        AcceptedNames string = [];
        RejectedNames string = [];
        DefaultAccept logical;
    end
    
    methods
        function obj = LeadNameCriteria(rejectedNames, acceptedNames, defaultAccept)
            if nargin >= 1 && ~isstring(rejectedNames)
                throw(MException('IspEcgFramework:filter:LeadNameFilter:Constructor:invalidRejectedNames', 'rejectedNames argument is not of type string'));
            end
            if nargin >= 2 && ~isstring(acceptedNames)
                throw(MException('IspEcgFramework:filter:LeadNameFilter:Constructor:invalidAcceptedNames', 'acceptedNames argument is not of type string'));
            end
            if nargin >= 3 && (isempty(defaultAccept) || islogical(defaultAccept))
                throw(MException('IspEcgFramework:filter:LeadNameFilter:Constructor:invalidDefaultAccept', 'defaultAccept argument is not of type logcial'));
            end
            
            obj.AcceptedNames = acceptedNames;
            obj.RejectedNames = rejectedNames;
            if nargin <= 2
                obj.DefaultAccept = true;
            else
                obj.DefaultAccept = defaultAccept;
            end
        end
        
        function criteriaMet = meetCriteria(obj, recording, lead)
            if any(strcmp(strtrim(regexprep(lead.Name, char(0), '')), obj.AcceptedNames))
                criteriaMet = true;
            elseif any(strcmp(strtrim(regexprep(lead.Name, char(0), '')), obj.RejectedNames))
                criteriaMet = false;
            else
                criteriaMet = obj.DefaultAccept;
            end
        end
    end
end