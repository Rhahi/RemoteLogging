"Serializable object to be passed to create a progress bar"
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
    msg = Progress(id.id, parentid, 0, name, false)
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

"Setup a client connection that will send progress messages over TCP."
function setup_progress(chan::Channel{Progress}, host=IPv4(0), port=50021)
    conn = connect(host, port)
    @async begin
        try
            while true
                serialize(conn, take!(chan))
            end
        catch e
            @warn e
        finally
            close(conn)
        end
    end
    return conn
end
function setup_progress(host=IPv4(0), port=50021)
    global progresschan = Channel{Progress}(50)
    conn = setup_progress(progresschan, host, port)
    return conn
end

"Accept progress data, deserialize and pass them to sink"
function host_progress(chan::Channel{T}, host=IPv4(0), port=50011) where T <: Progress
    server = listen(host, port)
    @info "Hosting $T at $port"
    @async begin
        while true
            conn = accept(server)
            @info "New client accepted"
            @async begin
                try
                    while true
                        data = deserialize(conn)
                        put!(chan, data)
                        eof(conn) && break
                    end
                catch e
                    @warn e
                finally
                    @info "Lost connection with a client"
                    close(conn)
                end
            end
        end
    end
    return server
end

"Activate progress logging for this console"
function begin_progress_sink(chan::Channel{Progress}, active::Vector{UUID})
    @info "Progress sink activated!"
    while true
        progress = take!(chan)
        @info progress
        if progress.id ∉ active
            push!(active, progress.id)
        else
            if progress.done || isnothing(progress.fraction) || progress.fraction ≥ 1
                idx = findfirst(x->x==progress.id, active)
                deleteat!(active, idx)
            end
        end
    end
end
