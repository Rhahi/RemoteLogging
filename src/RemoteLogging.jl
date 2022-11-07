module RemoteLogging

using Sockets
using Logging

include("spacelib_loglevels.jl")
include("commons.jl")
include("server.jl")

# RemoteLogging
export setup_host, setup_logger

# SpaceLib log levels
export @log_timer, @log_traceloop, @log_trace, @log_exit, @log_entry, @log_dev, @log_guidance
export @log_status, @log_module, @log_system, @log_ok, @log_mark, @log_attention, @asyncx
export LogTimer, LogTraceLoop, LogTrace, LogExit, LogEntry, LogGuidance, LogDev
export LogStatus, LogModule, LogSystem, LogOk, LogMark, LogAttention

end # module RemoteLogging
