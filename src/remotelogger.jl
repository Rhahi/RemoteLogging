struct ProgressId
    id::UUID
    parentid::UUID
    name::String
end
ProgressId() = ProgressId(uuid4(), ProgressLogging.ROOTID, "")
ProgressId(parentid::UUID) = ProgressId(uuid4(), parentid, "")

"""Begin progress bar and return its id"""
function progress_init(parentid::UUID, name::String)
    global progresschan
    id = ProgressId(uuid4(), parentid, name)
    msg = Progress(id=id.id, parentid=parentid, name=name)
    if @isdefined progresschan
        put!(progresschan, msg)
    else
        @info msg _group=:pgbar
    end
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
    if @isdefined progresschan
        put!(progresschan, msg)
    else
        @info msg _group=:pgbar
    end
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
    if @isdefined progresschan
        put!(progresschan, msg)
    else
        @info msg _group=:pgbar
    end
    nothing
end
progress_end(id::Nothing, name=nothing) = nothing
