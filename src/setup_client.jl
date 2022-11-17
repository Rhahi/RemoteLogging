"Remote logging via TCP. Does not supprot keyword arguments (ignored)"
function begin_logger(host=IPv4(0), port=50021)
    global chan = Channel{LogMessage}(50)
    conn = setup_data(chan, host, port)
    return conn
end

function begin_progress(host=IPv4(0), port=50022)
    global chan = Channel{ProgressMessage}(50)
    conn = setup_data(chan, host, port)
    return conn
end

function setup_data(chan::Channel{T}, host=IPv4(0), port=50020) where T <: Union{ProgressMessage, LogMessage}
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