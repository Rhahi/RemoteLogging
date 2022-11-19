module Terminal

using RemoteLogging
using RemoteLogging: restore_callsite_source_position!, progress_init, progress_update, progress_end
using Sockets

function activate(host=IPv4(0), base_port=50021)
    logger = RemoteLogging.begin_logger(host, base_port)
    progress = RemoteLogging.begin_progress(host, base_port+1)
    return logger, progress
end

export activate, @remotelog, progress_init, progress_update, progress_end
export @log_timer, @log_traceloop, @log_trace, @log_exit, @log_entry, @log_dev, @log_guidance
export @log_status, @log_module, @log_system, @log_ok, @log_mark, @log_attention, @asyncx

"""debug information about drawing"""
macro log_graphic(exs...)   return restore_callsite_source_position!(esc(:(@remotelog $(LogGraphic.level) $(exs...))), __source__,) end

"""debug information about timing"""
macro log_timer(exs...)     return restore_callsite_source_position!(esc(:(@remotelog $(LogTimer.level) $(exs...))), __source__,) end

"""trace execution history within a function, in a loop"""
macro log_traceloop(exs...) return restore_callsite_source_position!(esc(:(@remotelog $(LogTraceLoop.level) $(exs...))), __source__,) end

"""trace execution history within a function"""
macro log_trace(exs...)     return restore_callsite_source_position!(esc(:(@remotelog $(LogTrace.level) $(exs...))), __source__,) end

"""low level log with point of interest. Demote to other levels after debugging."""
macro log_dev(exs...)       return restore_callsite_source_position!(esc(:(@remotelog $(LogDev.level) $(exs...))), __source__,) end

"""trace exit of a function, usually for long-running or complex calls"""
macro log_exit(exs...)      return restore_callsite_source_position!(esc(:(@remotelog $(LogExit.level) $(exs...))), __source__,) end

"""trace entry of a function"""
macro log_entry(exs...)     return restore_callsite_source_position!(esc(:(@remotelog $(LogEntry.level) $(exs...))), __source__,) end

"""guidance logs"""
macro log_guidance(exs...)  return restore_callsite_source_position!(esc(:(@remotelog $(LogGuidance.level) $(exs...))), __source__,) end

"""general useful status info"""
macro log_status(exs...)    return restore_callsite_source_position!(esc(:(@remotelog $(LogStatus.level) $(exs...))), __source__,) end

"""status info from a module"""
macro log_module(exs...)    return restore_callsite_source_position!(esc(:(@remotelog $(LogModule.level) $(exs...))), __source__,) end

"""status info from operating system"""
macro log_system(exs...)    return restore_callsite_source_position!(esc(:(@remotelog $(LogSystem.level) $(exs...))), __source__,) end

"""mark successful results"""
macro log_ok(exs...)        return restore_callsite_source_position!(esc(:(@remotelog $(LogOk.level) $(exs...))), __source__,) end

"""mark important milestones"""
macro log_mark(exs...)      return restore_callsite_source_position!(esc(:(@remotelog $(LogMark.level) $(exs...))), __source__,) end

"""alert user for immediate action"""
macro log_attention(exs...) return restore_callsite_source_position!(esc(:(@remotelog $(LogAttention.level) $(exs...))), __source__,) end

end