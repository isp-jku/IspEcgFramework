classdef FileCache < IspEcgFramework.io.Cache
    %FILECACHE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        path string = string(0);
        opened logical = false;
        index struct
    end
    
    methods (Access = public)
        function obj = FileCache(path)
            IspEcgFramework.util.Configuration.getInstance.ValidationHelper.validateNonEmptyAndTypeOfArgument(path, 'string', 'path', 'IspEcgFramework:io:FileCache:construct:invalidPathArgument');
            obj.path = char(path);
        end
        
        function obj = put(obj, key, data)
            IspEcgFramework.util.Configuration.getInstance.ValidationHelper.validateNonEmptyAndTypeOfArgument(key, 'string', 'key', 'IspEcgFramework:io:FileCache:put:invalidKeyArgument');
            obj.open();
            if(obj.index.mapping.isKey(char(key)))
                save([char(obj.path) filesep obj.index.mapping(char(key)) '.mat'], 'data');
            else
                save([char(obj.path) filesep num2str(obj.index.nextFilename) '.mat'], 'data');
                obj.index.mapping(char(key)) = num2str(obj.index.nextFilename);
                obj.index.nextFilename = obj.index.nextFilename+1;
            end
            obj.close();
        end
        
        function result = get(obj, key)
            IspEcgFramework.util.Configuration.getInstance.ValidationHelper.validateNonEmptyAndTypeOfArgument(key, 'string', 'key', 'IspEcgFramework:io:FileCache:get:invalidKeyArgument');
            obj.open();
            if (obj.index.mapping.isKey(char(key)))
                temp = load([char(obj.path) filesep obj.index.mapping(char(key)) '.mat']);
                result = temp.data;
            end
            obj.close();
        end
        
        function exists = exists(obj, key)
            IspEcgFramework.util.Configuration.getInstance.ValidationHelper.validateNonEmptyAndTypeOfArgument(key, 'string', 'key', 'IspEcgFramework:io:FileCache:exists:invalidKeyArgument');
            obj.open();
            if(obj.index.mapping.isKey(char(key)))
                exists = true;
            else
                exists = false;
            end
            obj.close();
        end
        
        function existed = evict(obj, key)
            IspEcgFramework.util.Configuration.getInstance.ValidationHelper.validateNonEmptyAndTypeOfArgument(key, 'string', 'key', 'IspEcgFramework:io:FileCache:evict:invalidKeyArgument');
            obj.open();
            if(obj.index.mapping.isKey(char(key)))
                filename = [char(obj.path) filesep obj.index.mapping(char(key)) '.mat'];
                delete(filename);
                obj.index.mapping.remove(char(key));
                existed = true;
            else
                existed = false;
            end
            obj.close();
        end
    end
    
    methods (Access = private)
        function open(obj)
            if(~obj.opened)
                if (exist([char(obj.path) filesep '.lock'], 'file') == 2)
                    throw(MException('IspEcgFramework:io:FileCache:lockFileExistsAlready', sprintf('Cache at this location is locked. The file %s exists.', [char(obj.path) filesep '.lock'])));
                end
                % check if index.mat exists (cache is initialized)
                % if index.mat exists --> try to read it
                % if index.mat does not exists --> create it
                
                % create lock file
                cachePath = [char(obj.path) filesep '.lock'];
                fileId = fopen(cachePath, 'w');
                if (fileId < 0) % check if fopen was successful
                    throw(MException('IspEcgFramework:io:FileCache:cannotCreateLockFile', sprintf('Cannot create .lock file in %s.', obj.path)));
                end
                status = fclose(fileId);
                if (status == -1) % check if fclose was successful
                    throw(MException('IspEcgFramework:io:FileCache:cannotCloseLockFile', spfintf('Cannot close file $s.', [char(obj.path) filesep '.lock'])));
                end
                if (exist([char(obj.path) filesep 'index.mat'], 'file') == 2)
                    % try to read index.mat
                    temp = load([char(obj.path) filesep 'index.mat']);
                    obj.index = temp.tempHack; % save() and load() cannot access object properties. See the FileCache#close() method for the counterpart
                else
                    obj.index = struct();
                    obj.index.nextFilename = 0; % consecutive number
                    obj.index.mapping = containers.Map('KeyType', 'string'); % contains the mapping between key and filename
                end
                obj.opened = true;
            end
        end
        
        function close(obj)
            if(obj.opened)
                tempHack = obj.index; % save() cannot process object properties directly
                save([char(obj.path) filesep 'index.mat'], 'tempHack');
                delete([char(obj.path) filesep '.lock']);
                obj.opened = false;
            else
                warning('IspEcgFramework:io:FileCache:alreadyClosed', 'The cache is already in closed state.');
            end
        end
    end
    
end