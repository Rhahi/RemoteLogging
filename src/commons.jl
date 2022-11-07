struct ExtraLogLevel
    level::Int32
    name::String
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
