function activate(logger=nothing; host=IPv4(0), port=50020, displaywidth=80)
    tcp1 = connect_to_listener(logger; host=host, port=port, displaywidth=displaywidth)
    tcp2 = setup_progress(host, port+1)
    return tcp1, tcp2
end

"Remote printing through TCP"
function connect_to_listener(logger=nothing;
    host=IPv4(0), port=50020, displaywidth=80
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
