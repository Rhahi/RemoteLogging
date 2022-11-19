module RemoteLogging

using UUIDs
using Sockets
using Logging
using LoggingExtras
using Serialization
using TerminalLoggers
using ProgressLogging
import Logging: LogLevel, handle_message
import TerminalLoggers: default_logcolor
import Base: show, isless, convert
import Base.CoreLogging: default_group_code, log_record_id, @_sourceinfo


include("loglevels.jl")
include("loglevels_native.jl")
include("loglevels_remote.jl")
include("remotelogger.jl")
include("remoteprogress.jl")
include("setup_host.jl")
include("setup_client.jl")


# RemoteLogging
export Terminal, Printer, LogMessage, ProgressMessage
export host_printer, host_data, host_logger, host_progress, host_dev
export begin_logging_sink, begin_progress_sink

# remote log macros
export @remotelog, @logdata

# SpaceLib log levels
export LogTimer, LogTraceLoop, LogTrace, LogExit, LogEntry, LogGuidance, LogDev
export LogStatus, LogModule, LogSystem, LogOk, LogMark, LogAttention
export @dev_json

end # module RemoteLogging
