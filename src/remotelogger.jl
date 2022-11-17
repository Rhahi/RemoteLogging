struct LogMessage
    level::Int32
    message::String
    logmodule::Module
    group::Symbol
    id::Symbol
    file::String
    line::Int32
end

function package_logdata(_module, file, line, level, message, exs...)
    @nospecialize
    local _group, _id
    for ex in exs
        if ex isa Expr && ex.head === :(=)
            k, v = ex.args
            if !(k isa Symbol)
                k = Symbol(k)
            end
            if k === :_group
                _group = Symbol(v)
            elseif k === :_id
                _id = Symbol(v)
            end
        end
    end
    if !@isdefined(_group)
        _group = Symbol(default_group_code(file))
    end
    if !@isdefined(_id)
        _id = log_record_id(_module, level, message, exs)
    end
    # inspect = _group
    # println(inspect, " ", typeof(inspect))
    return LogMessage(level, message, _module, _group, _id, file, line)
end

macro remotelog(level, exs...)
    data = package_logdata((@_sourceinfo)..., level, exs...)
    :(send_logdata($data))
end

macro logdata(level, exs...)
    package_logdata((@_sourceinfo)..., level, exs...)
end

function send_logdata(data)
    global chan
    if !@isdefined chan
        @warn "logchan not set up"
    end
    put!(chan, data)
    nothing
end
send_logdata(chan, data) = put!(chan, data); nothing