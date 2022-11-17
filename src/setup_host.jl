"Accept any log messages and print them"
function host_printer(host=IPv4(0), port=50010)
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
function host_data(chan::Channel{T}, host=IPv4(0), port=50020) where T <: Union{ProgressMessage, LogMessage}
    server = listen(host, port)
    @async begin
        while true
            conn = accept(server)
            println("accept new client")
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
                    println("lost connection with a client")
                    close(conn)
                end
            end
        end
    end
end
host_logger(chan::Channel{LogMessage}, host=IPv4(0), port=50021) = host_data(chan, host, port)
host_progress(chan::Channel{ProgressMessage}, host=IPv4(0), port=50022) = host_data(chan, host, port)

"Simply print without multi-connection and conversions"
function host_dev(host=IPv4(0), port=50030)
    server = listen(host, port)
    @async begin
        conn = accept(server)
        println("accept new client")
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

"Activate progress logging for this console"
function begin_progress_sink(chan::Channel{ProgressMessage})
    active = Array{UUID}()
    logger = TerminalLogger(stderr, LogLevel(-1000))
    global_logger(logger)
    while true
        p = take!(chan)
        if p.id ∉ active
            p.progress ≥ 1 && continue
            @debug Progress(p.id)
        else
            @debug Progress(p.id, p.progress)
            if p.progress ≥ 1
                @debug Progress(id, done=true)
                idx = getindex(active, id)
                deleteat!(active, idx)
            end
        end
    end
end

"Activate remote logging for this console"
function begin_logging_sink(chan::Channel{LogMessage},
    level::LogLevel=LogLevel(-1000),
    logger=TerminalLogger(stderr, level)
)
    global_logger(logger)
    @info "Sink has started logging!"
    while true
        ld = take!(chan)
        level = match_loglevel(ld.level)
        @logmsg level ld.message _group=ld.group _id=ld.id _module=ld.logmodule _file=ld.file _line=ld.line
    end
end
