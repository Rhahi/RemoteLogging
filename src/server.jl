function setup_host(host=IPv4(0), port=50002)
    socket = UDPSocket()
    bind(socket, host, port)
end

function setup_logger(host=IPv4(0), port=50002)
end
