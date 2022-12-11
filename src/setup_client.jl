function begin_progress(host=IPv4(0), port=50022)
    global progresschan = Channel{Progress}(50)
    conn = setup_progress(progresschan, host, port)
    return conn
end

function setup_progress(chan::Channel{Progress}, host=IPv4(0), port=50020)
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

"Remote printing through TCP"
function connect_to_listener(logger=nothing;
    host=IPv4(0), port=50010, displaywidth=80
)
    conn = connect(host, port)
    dsize = (displaysize()[1], displaywidth)
    ioc = IOContext(conn, :color => true, :displaysize => dsize)
    if isnothing(logger)
        logger = TerminalLogger(ioc, LogLevel(-650))
    end
    global_logger(logger)
    return conn
end

"Remote printing through TCP"
function setup_dev(host=IPv4(0), port=50030, level=LogLevel(-1000))
    conn = connect(host, port)
    ioc = IOContext(conn, :color => true)
    logger = TerminalLogger(ioc, level)
    global_logger(logger)
    return conn
end
