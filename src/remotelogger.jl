struct LogMessage
    level::Int32
    message::String
    logmodule::Symbol
    group::Symbol
    id::Symbol
    file::String
    line::Int32
end
function LogMessage(level, message, logmodule::Module, args...)
    LogMessage(level, message, Symbol(logmodule), args...)
end
struct ProgressId
    id::UUID
    parentid::UUID
    name::String
end
ProgressId() = ProgressId(uuid4(), ProgressLogging.ROOTID, "")
ProgressId(parentid::UUID) = ProgressId(uuid4(), parentid, "")

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
    return LogMessage(level, message, _module, _group, _id, file, line)
end

"""client: generic remote logging macro"""
macro remotelog(level, exs...)
    quote
        data = package_logdata(($(@_sourceinfo))..., $level, $(esc(exs...)))
        send_logdata(data)
    end
end

"""get log obejct instead of sending them immdiately"""
macro logdata(level, exs...)
    package_logdata((@_sourceinfo)..., level, exs...)
end

"""send log data remotely"""
function send_logdata(ld)
    global loggingchan
    if !@isdefined loggingchan
        @logmsg 2000 ld.message _group=ld.group _id=ld.id _module=ld.logmodule _file=ld.file _line=ld.line
        return
    end
    put!(loggingchan, ld)
    nothing
end
send_logdata(loggingchan, data) = put!(loggingchan, data); nothing

"""Begin progress bar and return its id"""
function progress_init(parentid::UUID, name::String)
    global progresschan
    id = ProgressId(uuid4(), parentid, name)
    put!(progresschan, Progress(id=id.id, parentid=parentid, name=name))
    return id
end
progress_init(parentid::ProgressId, name::String) = progress_init(parentid.id, name)
progress_init(name::String="") = progress_init(ProgressLogging.ROOTID, name)
progress_init(parentid::Nothing, name::String) = progress_init(ProgressLogging.ROOTID, name)
progress_init(parentid, name::Nothing) = nothing
progress_init(name::Nothing) = nothing
progress_subinit(parentid::Nothing, name::String) = nothing
progress_subinit(parentid::Union{ProgressId, UUID}, name::String) = progress_init(parentid, "↱"*name)
progress_subinit(parentid::Union{ProgressId, UUID}, name::Nothing) = progress_init(parentid, "↱")

"""Update progress bar. Implicitly end when reaching 1."""
function progress_update(id::ProgressId, fraction, name=nothing)
    global progresschan
    done = false
    if fraction ≥ 1
        done = true
    end
    if isnothing(name)
        name = id.name
    end
    msg = Progress(id.id, id.parentid, clamp(fraction, 0, 1), name, done)
    put!(progresschan, msg)
    nothing
end
progress_update(id::Nothing, fraction, name=nothing) = nothing

"""Explicitly end progress bar"""
function progress_end(id::ProgressId, name=nothing)
    global progresschan
    if isnothing(name)
        name = id.name
    end
    msg = Progress(id.id, id.parentid, nothing, name, true)
    put!(progresschan, msg)
    nothing
end
progress_end(id::Nothing, name=nothing) = nothing

Base.fullname(s::Symbol) = (s,)
