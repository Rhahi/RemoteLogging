"Begin terminal logger and progress logger"
function activate_terminal(logger=TerminalLogger(stderr, LogLevel(-999)))
    global_logger(logger)
    chan1 = Channel{LogMessage}(100)
    chan2 = Channel{Progress}(100)
    server1 = host_logger(chan1)
    server2 = host_progress(chan2)
    active = Vector{UUID}()
    @async begin_logging_sink(chan1)
    @async begin_progress_sink(chan2, active)
    @info("Terminal activated. Press enter to return...")
    readline(stdin)
    clear_progress(active)
    return server1, server2, active
end


"Accept any log messages and print them"
function activate_printer(host=IPv4(0), port=50010)
    server = listen(host, port)
    atmoic_print = Base.Semaphore(1)
    while true
        conn = accept(server)
        println("accept new client")
        @async begin
            try
                while true
                    data = String(readline(conn))
                    Base.acquire(atmoic_print) do
                        println(data)
                    end
                    eof(conn) && break
                end
            catch e
                @warn e
            finally
                println("lost connection with a client")
                close(conn)
            end
        end
    end
end

"Accept arbitrary data, deserialize and display them (display sold separately)"
function host_data(chan::Channel{T}, host=IPv4(0), port=50020) where T <: Union{Progress, LogMessage}
    server = listen(host, port)
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
                    @warn "Lost connection with" conn
                    close(conn)
                end
            end
        end
    end
end
host_logger(chan::Channel{LogMessage}, host=IPv4(0), port=50021) = host_data(chan, host, port)
host_progress(chan::Channel{Progress}, host=IPv4(0), port=50022) = host_data(chan, host, port)

"Simply print without multi-connection and conversions"
function host_dev(host=IPv4(0), port=50030)
    server = listen(host, port)
    @async begin
        conn = accept(server)
        println("New client accepted")
        try
            while true
                data = readline(conn)
                println(data)
                eof(conn) && break
            end
        catch e
            @warn e
        finally
            println("lost connection with a client")
            close(conn)
        end
    end
    return server
end

function begin_debug_logger()
    logger = TerminalLogger(stderr, LogLevel(-1000))
    global_logger(logger)
    nothing
end

"Activate progress logging for this console"
function begin_progress_sink(chan::Channel{Progress}, active::Vector{UUID})
    @info "Progress sink activated!"
    while true
        progress = take!(chan)
        @info progress _group=:pgbar
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

"Activate remote logging for this console"
function begin_logging_sink(chan::Channel{LogMessage})
    @info "Terminal sink activated!"
    while true
        ld = take!(chan)
        level = match_loglevel(ld.level)
        @logmsg level ld.message _group=ld.group _id=ld.id _module=ld.logmodule _file=ld.file _line=ld.line
    end
end

"Clear all progress bars"
function clear_progress(active::Vector{UUID})
    while length(active) > 0
        id = popfirst!(active)
        @info Progress(id, done=true) _group=:pgbar
    end
end
