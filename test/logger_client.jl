using RemoteLogging.Terminal

logging, progress = activate()

@remotelog 1000 "hello"

id = progress_init("Test")
sleep(0.5)
progress_update(id, 0.5)
sleep(0.5)
progress_update(id, 0.9, "Test name")
sleep(0.5)
progress_end(id, name="ending")
id2 = progress_init("Test2")
progress_update(id2, 0.9)
sleep(0.5)
progress_update(id2, 1.1)

@log_attention "test"

progress_init("Unfinished 1")
id3 = progress_init("Unfinished 2")
id3 = progress_update(id3, 0.5)
