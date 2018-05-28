classdef Configurator
    % A configurator for log4j
    %
    % This class configures the logging setup for Janklab/Matlab logging. It
    % configures the log4j library that Janklab logging sits on top of. (We use
    % log4j because it ships with Matlab.)
    %
    % This class is provided as a convenience. You can also configure Janklab
    % logging by directly configuring log4j using its normal Java interface.
    %
    % Janklab automatically configures log4j to do basic logging to the console.
    % If you want other logging configurations, you need to set them up
    % yourself.
    
    methods (Static)
        function configureDefaultLogging
        % Configures log4j with Janklab's default logging setup
        %
        % This method is safe to run multiple times per session; it checks to
        % avoid doing redundant work.
        
        % If there's an appender already present on the root logger, assume that
        % logging has already been configured, and punt
        rootLogger = org.apache.log4j.Logger.getRootLogger();
        apps = rootLogger.getAllAppenders();
        if apps.hasMoreElements()
            return
        end
        jl.log.Configurator.configureBasicConsoleLogging();
        end
        
        function configureBasicConsoleLogging
        % Configures log4j to do basic logging to the console
        %
        % This sets up a basic log4j configuration, with log output going to the
        % console, and the root logger set to the INFO level.
        %
        % Don't call this or other configureXxx methods more than once per session;
        % that could cause wonky logging output. This method is not idempotent.
        org.apache.log4j.BasicConfigurator.configure();
        rootLogger = org.apache.log4j.Logger.getRootLogger();
        rootLogger.setLevel(org.apache.log4j.Level.INFO);
        rootAppender = rootLogger.getAllAppenders().nextElement();
        % Use \n instead of %n because the Matlab console wants Unix-style line
        % endings, even on Windows.
        pattern = ['%d{HH:mm:ss.SSS} %-5p %c %x - %m' sprintf('\n')]; %#ok<SPRINTFN>
        myLayout = org.apache.log4j.PatternLayout(pattern);
        rootAppender.setLayout(myLayout);
        end
        
        function out = getLog4jLevel(levelName)
        % Gets the log4j Level enum for a named level
        validLevels = {'OFF' 'FATAL' 'ERROR' 'WARN' 'INFO' 'DEBUG' 'TRACE' 'ALL'};
        levelName = upper(levelName);
        if ~ismember(levelName, validLevels)
            error('Invalid levelName: ''%s''', levelName);
        end
        out = eval(['org.apache.log4j.Level.' levelName]);
        end
        
        function setLevels(levels)
        % Set the logging levels for multiple loggers
        %
        % jl.log.Configurator.setLevels(levels)
        %
        % This is a convenience method for setting the logging levels for multiple
        % loggers.
        %
        % The levels input is an n-by-2 cellstr with logger names in column 1 and
        % level names in column 2.
        for i = 1:size(levels, 1)
            [logName,levelName] = levels{i,:};
            if isequal(logName, 'root')
                logger = org.apache.log4j.LogManager.getRootLogger();
            else
                logger = org.apache.log4j.LogManager.getLogger(logName);
            end
            level = jl.log.Configurator.getLog4jLevel(levelName);
            logger.setLevel(level);
        end
        end
        
        function out = getEffectiveLevel(loggerName)
        % Get the current logging level for a named logger
        logger = org.apache.log4j.LogManager.getLogger(loggerName);
        out = char(logger.getEffectiveLevel().toString());
        end
        
        function prettyPrintLogConfiguration(verbose)
        % Displays the current log configuration to the console
        
        if nargin < 1 || isempty(verbose);  verbose = false;  end
        
            function out = getLevelName(lgr)        
                level = lgr.getLevel();
                if isempty(level)
                    out = '';
                else
                    out = char(level.toString());
                end
            end
        
        % Get all names first so we can display in sorted order
        loggers = org.apache.log4j.LogManager.getCurrentLoggers();
        loggerNames = {};
        while loggers.hasMoreElements()
            logger = loggers.nextElement();
            loggerNames{end+1} = char(logger.getName()); %#ok<AGROW>
        end
        loggerNames = sort(loggerNames);
        % Now get the loggers back, adding the rootLogger, which is not included
        % in getCurrentLoggers()
        loggers = cell(numel(loggerNames)+1, 1);
        loggers{1} = org.apache.log4j.LogManager.getRootLogger();
        for i = 1:numel(loggerNames)
            loggers{i+1} = org.apache.log4j.LogManager.getLogger(loggerNames{i});
        end
        loggerNames = [{'root'} loggerNames];
        
        % Display the hierarchy
        c = {};
        for i = 1:numel(loggers)
            logger = loggers{i};
            appenders = logger.getAllAppenders();
            appenderStrs = {};
            while appenders.hasMoreElements
                appender = appenders.nextElement();
                if isa(appender, 'org.apache.log4j.varia.NullAppender')
                    appenderStr = 'NullAppender';
                else
                    appenderStr = sprintf('%s (%s)', char(appender.toString()), ...
                        char(appender.getName()));
                end
                appenderStrs{end+1} = ['appender: ' appenderStr]; %#ok<AGROW>
            end
            appenderList = strjoin(appenderStrs, ' ');
            
            if ~verbose
                if isempty(logger.getLevel()) && isempty(appenderList) ...
                        && logger.getAdditivity()
                    continue
                end
            end
            additivityStr = '';
            if ~logger.getAdditivity()
                additivityStr = sprintf('additivity=%d', logger.getAdditivity());
            end
            c = [c; { loggerNames{i} getLevelName(logger) appenderList ...
                additivityStr }]; %#ok<AGROW>
        end
        tbl = cell2table(c, 'VariableNames',{'Name','Level','Appenders',...
            'Additivity'});
        prettyprint(relation(tbl));
        end
    end
    
end