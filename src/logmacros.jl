"""debug information about drawing"""
macro log_graphic(exs...)   return restore_callsite_source_position!(esc(:($Base.@logmsg LogGraphic $(exs...))), __source__,) end

"""debug information about timing"""
macro log_timer(exs...)     return restore_callsite_source_position!(esc(:($Base.@logmsg LogTimer $(exs...))), __source__,) end

"""trace execution history within a function, in a loop"""
macro log_traceloop(exs...) return restore_callsite_source_position!(esc(:($Base.@logmsg LogTraceLoop $(exs...))), __source__,) end

"""trace execution history within a function"""
macro log_trace(exs...)     return restore_callsite_source_position!(esc(:($Base.@logmsg LogTrace $(exs...))), __source__,) end

"""low level log with point of interest. Demote to other levels after debugging."""
macro log_dev(exs...)       return restore_callsite_source_position!(esc(:($Base.@logmsg LogDev $(exs...))), __source__,) end

"""trace exit of a function, usually for long-running or complex calls"""
macro log_exit(exs...)      return restore_callsite_source_position!(esc(:($Base.@logmsg LogExit $(exs...))), __source__,) end

"""trace entry of a function"""
macro log_entry(exs...)     return restore_callsite_source_position!(esc(:($Base.@logmsg LogEntry $(exs...))), __source__,) end

"""guidance logs"""
macro log_guidance(exs...)  return restore_callsite_source_position!(esc(:($Base.@logmsg LogGuidance $(exs...))), __source__,) end

"""general useful status info"""
macro log_status(exs...)    return restore_callsite_source_position!(esc(:($Base.@logmsg LogStatus $(exs...))), __source__,) end

"""status info from a module"""
macro log_module(exs...)    return restore_callsite_source_position!(esc(:($Base.@logmsg LogModule $(exs...))), __source__,) end

"""status info from operating system"""
macro log_system(exs...)    return restore_callsite_source_position!(esc(:($Base.@logmsg LogSystem $(exs...))), __source__,) end

"""mark successful results"""
macro log_ok(exs...)        return restore_callsite_source_position!(esc(:($Base.@logmsg LogOk $(exs...))), __source__,) end

"""mark important milestones"""
macro log_mark(exs...)      return restore_callsite_source_position!(esc(:($Base.@logmsg LogMark $(exs...))), __source__,) end

"""alert user for immediate action"""
macro log_attention(exs...) return restore_callsite_source_position!(esc(:($Base.@logmsg LogAttention $(exs...))), __source__,) end
