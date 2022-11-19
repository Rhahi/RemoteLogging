using RemoteLogging

chan1 = Channel{LogMessage}(100)
chan2 = Channel{ProgressMessage}(100)
server1 = host_logger(chan1)
server2 = host_progress(chan2)
begin_logging_sink(chan1)
begin_progress_sink(chan2)
