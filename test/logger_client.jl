using RemoteLogging.Terminal

logging, progress = activate(port_logger=50050)

@remotelog 100 "hello"
sleep(1)

id = progress_init("Test")
sleep(0.5)
progress_update(id, 0.5)
sleep(0.5)
progress_update(id, 0.9, "Test name")
sleep(0.5)
progress_end(id, "ending")
id2 = progress_init("Test2")
progress_update(id2, 0.9)
sleep(0.5)
progress_update(id2, 1.1)

@log_debug "test"
@log_dev "test"

progress_init("Unfinished 1")
@info "print here"
id3 = progress_init("Unfinished 2")
id3 = progress_update(id3, 0.5)
