module Terminal

using RemoteLogging
using RemoteLogging: progress_init, progress_update, progress_end, wait_for_input
using Sockets
import RemoteLogging: restore_callsite_source_position! as rcsp!

function activate(host=IPv4(0); port_logger=50020, port_progress=port_logger+1)
    logger = RemoteLogging.begin_logger(host, port_logger)
    progress = RemoteLogging.begin_progress(host, port_progress)
    return logger, progress
end

export activate, @remotelog, progress_init, progress_subinit, progress_update, progress_end, wait_for_input
export @log_debug, @log_timer, @log_traceloop, @log_trace, @log_exit, @log_entry, @log_dev, @log_guidance
export @log_info, @log_status, @log_module, @log_system, @log_ok, @log_mark
export @log_warn, @log_attention
export @log_error

"""general information"""
macro log_debug(exs...)     return rcsp!(esc(:(@remotelog -1000 $(exs...))), __source__,) end

"""debug information about drawing"""
macro log_graphic(exs...)   return rcsp!(esc(:(@remotelog $(LogGraphic.level) $(exs...))), __source__,) end

"""debug information about timing"""
macro log_timer(exs...)     return rcsp!(esc(:(@remotelog $(LogTimer.level) $(exs...))), __source__,) end

"""trace execution history within a function, in a loop"""
macro log_traceloop(exs...) return rcsp!(esc(:(@remotelog $(LogTraceLoop.level) $(exs...))), __source__,) end

"""trace execution history within a function"""
macro log_trace(exs...)     return rcsp!(esc(:(@remotelog $(LogTrace.level) $(exs...))), __source__,) end

"""low level log with point of interest. Demote to other levels after debugging."""
macro log_dev(exs...)       return rcsp!(esc(:(@remotelog $(LogDev.level) $(exs...))), __source__,) end

"""trace exit of a function, usually for long-running or complex calls"""
macro log_exit(exs...)      return rcsp!(esc(:(@remotelog $(LogExit.level) $(exs...))), __source__,) end

"""trace entry of a function"""
macro log_entry(exs...)     return rcsp!(esc(:(@remotelog $(LogEntry.level) $(exs...))), __source__,) end

"""guidance logs"""
macro log_guidance(exs...)  return rcsp!(esc(:(@remotelog $(LogGuidance.level) $(exs...))), __source__,) end

"""general information"""
macro log_info(exs...)      return rcsp!(esc(:(@remotelog 0 $(exs...))), __source__,) end

"""general useful status info"""
macro log_status(exs...)    return rcsp!(esc(:(@remotelog $(LogStatus.level) $(exs...))), __source__,) end

"""status info from a module"""
macro log_module(exs...)    return rcsp!(esc(:(@remotelog $(LogModule.level) $(exs...))), __source__,) end

"""status info from operating system"""
macro log_system(exs...)    return rcsp!(esc(:(@remotelog $(LogSystem.level) $(exs...))), __source__,) end

"""mark successful results"""
macro log_ok(exs...)        return rcsp!(esc(:(@remotelog $(LogOk.level) $(exs...))), __source__,) end

"""mark important milestones"""
macro log_mark(exs...)      return rcsp!(esc(:(@remotelog $(LogMark.level) $(exs...))), __source__,) end

"""generic warning"""
macro log_warn(exs...)      return rcsp!(esc(:(@remotelog 1000 $(exs...))), __source__,) end

"""alert user for immediate action"""
macro log_attention(exs...) return rcsp!(esc(:(@remotelog $(LogAttention.level) $(exs...))), __source__,) end

"""generic error"""
macro log_error(exs...)     return rcsp!(esc(:(@remotelog 2000 $(exs...))), __source__,) end

end