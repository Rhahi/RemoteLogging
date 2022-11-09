function host_tcp(host=IPv4(0), port=50002)
    server = listen(host, port)
    atmoic_print = Base.Semaphore(1)
    @async begin
        while true
            conn = accept(server)
            println("accept new client")
            @async begin
                try
                    while true
                        data = String(readline(conn))
                        isopen(conn) || break
                        Base.acquire(atmoic_print) do
                            println(data)
                        end
                    end
                finally
                    println("lost connection with a client")
                    close(conn)
                end
            end
        end
    end
    return server
end

function setup_tcp_logger(logger=ConsoleLogger; host=IPv4(0), port=50002, min_level=LogLevel(-1000))
    conn = connect(host, port)
    ioc = IOContext(conn, :color => true)
    logger = logger(ioc, min_level)
    global_logger(logger)
    return conn
end
