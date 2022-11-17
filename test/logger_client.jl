using RemoteLogging

conn = setup_logger()
@remotelog 1000 "hello"
@log_attention "test"
