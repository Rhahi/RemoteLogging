using RemoteLogging

ref = start_server(; port=50050)
clear() = clear_progress(ref[2])
wait_for_input()
