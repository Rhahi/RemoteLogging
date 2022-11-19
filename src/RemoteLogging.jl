module RemoteLogging

using UUIDs
using Sockets
using Logging
using LoggingExtras
using Serialization
using TerminalLoggers
using ProgressLogging
using ProgressLogging: Progress
import Logging: LogLevel, handle_message
import TerminalLoggers: default_logcolor
import Base: show, isless, convert
import Base.CoreLogging: default_group_code, log_record_id, @_sourceinfo


include("loglevels.jl")
include("remotelogger.jl")
include("setup_host.jl")
include("setup_client.jl")
include("loglevels_printer.jl")
include("loglevels_terminal.jl")


# RemoteLogging
export Terminal, Printer, LogMessage
export activate_printer, activate_terminal, clear_progress
export progress_init, progress_update, progress_end

# remote log macros
export @remotelog, @logdata

# SpaceLib log levels
export LogTimer, LogTraceLoop, LogTrace, LogExit, LogEntry, LogGuidance, LogDev
export LogStatus, LogModule, LogSystem, LogOk, LogMark, LogAttention

end # module RemoteLogging
