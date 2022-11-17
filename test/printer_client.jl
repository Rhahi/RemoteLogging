using RemoteLogging
using RemoteLogging.NativeLogLevels

client = begin_printer()

@info "test"
