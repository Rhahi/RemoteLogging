using RemoteLogging
using Logging
using TerminalLoggers

# client = activate(port=50050)
global_logger(TerminalLogger())

@info "test1"
sleep(1)
id = progress_init("test")
sleep(1)
@info "test2"
sleep(1)
progress_update(id, 0.5)
sleep(1)
@info "test3"
sleep(1)
progress_update(id, 1)
