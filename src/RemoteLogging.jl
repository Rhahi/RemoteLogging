module RemoteLogging

using UUIDs
using Sockets
using Dates
using Logging
using LoggingExtras
using Serialization
using TerminalLoggers
using ProgressLogging
using ProgressLogging: Progress
import Logging: LogLevel, handle_message
import TerminalLoggers: default_logcolor
import Base: show, isless, convert, fullname
import Base.CoreLogging: default_group_code, log_record_id, @_sourceinfo

macro asyncx(ex)
    quote
        Threads.@spawn try
            $(esc(ex))
        catch e
            @error "Exception in task" exception=(e, catch_backtrace())
        end
    end
end

include("loglevels.jl")
include("remotelogger.jl")
include("setup_host.jl")
include("setup_client.jl")
include("loglevels_native.jl")
include("loglevels_terminal.jl")
include("logger.jl")

global parked_logger = global_logger()

# RemoteLogging
export Terminal, Printer
export activate_printer, activate_terminal, clear_progress
export progress_init, progress_update, progress_end
export spacelogger, wait_for_input, restore
export format_MET, format_UT

# remote log macros
export @remotelog, @logdata

# SpaceLib log levels
export LogTimer, LogTraceLoop, LogTrace, LogExit, LogEntry, LogGuidance, LogDev
export LogStatus, LogModule, LogSystem, LogOk, LogMark, LogAttention

end # module RemoteLogging
