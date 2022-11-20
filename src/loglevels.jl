struct ExtraLogLevel
    level::Int32
    name::String
end

# Debug (-1000)
const LogGraphic   = ExtraLogLevel(-900, "Graphic")
const LogTimer     = ExtraLogLevel(-800, "Timer")
const LogTraceLoop = ExtraLogLevel(-700, "TraceLoop")
const LogTrace     = ExtraLogLevel(-600, "Trace")
const LogExit      = ExtraLogLevel(-400, "Exit ")
const LogEntry     = ExtraLogLevel(-300, "Entry")
const LogGuidance  = ExtraLogLevel(-200, "Guidance")
const LogDev       = ExtraLogLevel(-100, "🐞 Develop")
# Info (0)
const LogStatus    = ExtraLogLevel( 100, "Status")
const LogModule    = ExtraLogLevel( 300, "🟦 Module")
const LogSystem    = ExtraLogLevel( 400, "🟪 System")
const LogOk        = ExtraLogLevel( 600, "🟩   OK  ")
const LogMark      = ExtraLogLevel( 800, "🟧  Mark ")
# Warn (1000)
const LogAttention = ExtraLogLevel(1500, "🟨  OBS! ")
# Error (2000)

function match_loglevel(level::Integer)
    level == -900 ? LogGraphic :
    level == -800 ? LogTimer :
    level == -700 ? LogTraceLoop :
    level == -600 ? LogTrace :
    level == -400 ? LogExit :
    level == -300 ? LogEntry :
    level == -200 ? LogGuidance :
    level == -100 ? LogDev :
    level ==  100 ? LogStatus :
    level ==  300 ? LogModule :
    level ==  400 ? LogSystem :
    level ==  600 ? LogOk :
    level ==  800 ? LogMark :
    level == 1500 ? LogAttention :
    LogLevel(level)
end

function default_logcolor(level::ExtraLogLevel)
    level.level == -900 ? 0 :         # LogGraphic
    level.level == -800 ? 22 :        # LogTimer
    level.level == -700 ? 0 :         # LogTraceLoop
    level.level == -600 ? 8 :         # LogTrace
    level.level == -400 ? 23 :        # LogExit
    level.level == -300 ? 23 :        # LogEntry
    level.level == -200 ? :blue :     # LogGuidance
    level.level == -100 ? :magenta :  # LogDev
    level.level ==  100 ? :cyan :     # LogStatus
    level.level ==  300 ? :green :    # LogModule
    level.level ==  400 ? :green :    # LogSystem
    level.level ==  600 ? :green :    # LogOk
    level.level ==  800 ? 123 :       # LogMark
    level.level == 1500 ? :yellow :   # LogAttention
    TerminalLogger.default_logcolor(level)
end


Base.isless(a::ExtraLogLevel, b::LogLevel) = isless(a.level, b.level)
Base.isless(a::LogLevel, b::ExtraLogLevel) = isless(a.level, b.level)
Base.convert(::Type{LogLevel}, level::ExtraLogLevel) = LogLevel(level.level)
Base.convert(::Type{Int32}, level::ExtraLogLevel) = level.level
Logging.handle_message(logger::SimpleLogger, level::ExtraLogLevel, args...; kwargs...) = handle_message(logger, convert(LogLevel, level), args...; kwargs...)
Base.show(io::IO, level::ExtraLogLevel) = print(io, level.name)

function restore_callsite_source_position!(expr, src)
    @assert expr.head == :escape
    @assert expr.args[1].head == :macrocall
    @assert expr.args[1].args[2] isa LineNumberNode
    expr.args[1].args[2] = src
    return expr
end

function show_colors()
    for i in 0:255
        num = rpad(string(i), 3)
        printstyled("test[$num] ", bold=true, color=i)
        printstyled("test[$num] \n", bold=false, color=i)
    end
end
