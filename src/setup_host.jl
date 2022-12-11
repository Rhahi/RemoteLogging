"Begin terminal logger and progress logger"
function start_server(logger=TerminalLogger(); host=IPv4(0), port=50020)
    global parked_logger = logger
    global_logger(logger)
    chan = Channel{Progress}(100)
    server = host_progress(chan, host, port+1)
    progress_list = Vector{UUID}()
    @asyncx activate_printer(host, port)
    @asyncx begin_progress_sink(chan, progress_list)
    return server, progress_list
end

function wait_for_input()
    @info("Waiting for user input...")
    readline(stdin)
    isinteractive() && @warn("Logger may have been changed")
end
function wait_for_input(active)
    wait_for_input(silence)
    clear_progress(active)
end

"Accept any print messages and print them"
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

"Clear all progress bars"
function clear_progress(active::Vector{UUID})
    while length(active) > 0
        id = popfirst!(active)
        @info Progress(id, done=true)
    end
end

function restore()
    global parked_logger
    global_logger(parked_logger)
    nothing
end
