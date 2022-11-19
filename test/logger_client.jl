using RemoteLogging.Terminal

logging, progress = activate()

@remotelog 1000 "hello"
@log_attention "test"
