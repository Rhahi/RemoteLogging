using Logging
using RemoteLogging
import SpaceLib: connect_to_timeserver

ts = connect_to_timeserver()
logger = utlogger(ts, LogLevel(-700))
ref = activate_terminal(logger; port_logger=50050)
clear() = clear_progress(ref[3])
wait_for_input()
