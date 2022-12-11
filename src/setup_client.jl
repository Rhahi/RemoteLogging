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
function begin_printer(logger=TerminalLogger; host=IPv4(0), port=50010, min_level=LogLevel(-1000))
    conn = connect(host, port)
    ioc = IOContext(conn, :color => true)
    logger = logger(ioc, min_level)
    global_logger(logger)
    return conn
end
setup_dev() = begin_printer(; port=50030)
