using RemoteLogging

chan = Channel{LogMessage}(100)
server = host_data(chan)
begin_logging_sink(chan)
