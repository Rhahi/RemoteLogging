using RemoteLogging

ref = activate_terminal(; port_logger=50050)
clear() = clear_progress(ref[3])
wait_for_input()
