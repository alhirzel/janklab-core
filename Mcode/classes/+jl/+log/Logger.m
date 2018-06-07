classdef Logger
    %LOGGER Main entry point through which logging happens
    %
    % The logger class provides method calls for performing logging, and the ability
    % to look up loggers by name. This is the main entry point through which all
    % Janklab logging happens.
    %
    % Usually you don't need to interact with this class directly, but can just call
    % one of the error(), warn(), info(), debug(), or trace() functions in the jl.log
    % namespace. Those will log messages using the calling class's name as the name
    % of the logger. Also, don't call the constructor for this class. Use the static
    % getLogger() method instead.
    %
    % See also:
    % jl.log.error
    % jl.log.warn
    % jl.log.info
    % jl.log.debug
    % jl.log.trace
    
    properties (SetAccess = private)
        % The underlying SLF4J Logger object
        jLogger
    end
    
    properties (Dependent = true)
        % The name of this logger
        name
        % A list of the levels enabled on this logger
        enabledLevels
    end
    
    
    methods (Static)
        function out = getLogger(identifier)
        % Gets the named Logger
        jLogger = org.slf4j.LoggerFactory.getLogger(identifier);
        out = jl.log.Logger(jLogger);
        end
        
    end
    
    methods
        function this = Logger(jLogger)
        %LOGGER Build a new logger object around an SLF4J Logger object
        %
        % Generally, you shouldn't call this. Use jl.log.Logger.getLogger() instead.
        mustBeType(jLogger, 'org.slf4j.Logger');
        this.jLogger = jLogger;
        end
        
        function error(this, msg, varargin)
        % Log a message at the ERROR level.
        if ~this.jLogger.isErrorEnabled()
            return
        end
        this.jLogger.error(msg, varargin{:});
        end
        
        function errorf(this, format, varargin)
        % Log a message at the ERROR level, with sprintf formatting.
        if ~this.jLogger.isErrorEnabled()
            return
        end
        msg = sprintf(format, varargin{:});
        this.error(msg);
        end
        
        function warn(this, msg, varargin)
        % Log a message at the WARN level.
        if ~this.jLogger.isWarnEnabled()
            return
        end
        this.jLogger.warn(msg, varargin{:});
        end
        
        function warnf(this, format, varargin)
        % Log a message at the WARN level, with sprintf formatting.
        if ~this.jLogger.isWarnEnabled()
            return
        end
        msg = sprintf(format, varargin{:});
        this.warn(msg);
        end
        
        function info(this, msg, varargin)
        % Log a message at the INFO level.
        if ~this.jLogger.isInfoEnabled()
            return
        end
        this.jLogger.info(msg, varargin{:});
        end
        
        function infof(this, format, varargin)
        % Log a message at the INFO level, with sprintf formatting.
        if ~this.jLogger.isInfoEnabled()
            return
        end
        msg = sprintf(format, varargin{:});
        this.info(msg);
        end
        
        function debug(this, msg, varargin)
        % Log a message at the DEBUG level.
        if ~this.jLogger.isDebugEnabled()
            return
        end
        this.jLogger.debug(msg, varargin{:});
        end
        
        function debugf(this, format, varargin)
        % Log a message at the DEBUG level, with sprintf formatting.
        if ~this.jLogger.isDebugEnabled()
            return
        end
        msg = sprintf(format, varargin{:});
        this.debug(msg);
        end
        
        function trace(this, msg, varargin)
        % Log a message at the TRACE level.
        if ~this.jLogger.isTraceEnabled()
            return
        end
        this.jLogger.trace(msg, varargin{:});
        end
        
        function tracef(this, format, varargin)
        % Log a message at the TRACE level, with sprintf formatting.
        if ~this.jLogger.isTraceEnabled()
            return
        end
        msg = sprintf(format, varargin{:});
        this.trace(msg);
        end
        
        function out = isErrorEnabled(this)
        % True if ERROR level logging is enabled for this logger.
        out = this.jLogger.isErrorEnabled;
        end
        
        function out = isWarnEnabled(this)
        % True if WARN level logging is enabled for this logger.
        out = this.jLogger.isWarnEnabled;
        end
        
        function out = isInfoEnabled(this)
        % True if INFO level logging is enabled for this logger.
        out = this.jLogger.isInfoEnabled;
        end
        
        function out = isDebugEnabled(this)
        % True if DEBUG level logging is enabled for this logger.
        out = this.jLogger.isDebugEnabled;
        end
        
        function out = isTraceEnabled(this)
        % True if TRACE level logging is enabled for this logger.
        out = this.jLogger.isTraceEnabled;
        end
        
        function out = listEnabledLevels(this)
        % List the levels that are enabled for this logger.
        out = {};
        if this.isErrorEnabled
            out{end+1} = 'error';
        end
        if this.isWarnEnabled
            out{end+1} = 'warn';
        end
        if this.isInfoEnabled
            out{end+1} = 'info';
        end
        if this.isDebugEnabled
            out{end+1} = 'debug';
        end
        if this.isTraceEnabled
            out{end+1} = 'trace';
        end
        end
        
        function out = get.enabledLevels(this)
        out = this.listEnabledLevels;
        end
        
        function out = get.name(this)
        out = char(this.jLogger.getName());
        end
    end
    
end