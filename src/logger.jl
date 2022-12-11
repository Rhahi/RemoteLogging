function simple_console_logger(io::IO=stderr, level=LogLevel(-1))
    console = TerminalLogger(io, level) |> filter_module
    return console
end

function simple_file_logger(file_path, io::IO=stderr, level=LogLevel(-1))
    fileio = open(file_path, "a")
    console = TerminalLogger(io, level)
    spacelib = io |> FileLogger |> filter_group
    tee = TeeLogger(spacelib, console) |> filter_module
    return tee, fileio
end

"Logger with MET. Connection to Spacecraft is required."
function metlogger(sp, io::IO=stderr, level=LogLevel(-1);
    log_path=nothing, log_name="Untitled"
)
    if isnothing(log_path)
        logger = simple_console_logger(io, level)
        fileio = nothing
    else
        log_file = create_log_home(log_path, log_name)
        logger, fileio = simple_file_logger(log_file, io, level)
    end
    return add_MET(sp.ts, logger), fileio
end

"Logger with UT. Connection to KRPC is required."
function utlogger(ts, io::IO=stderr, level=LogLevel(-1);
    log_path=nothing, log_name="Untitled", use_relative=true
)
    if isnothing(log_path)
        logger = simple_console_logger(io, level)
        fileio = nothing
    else
        log_file = create_log_home(log_path, log_name)
        logger, fileio = simple_file_logger(log_file, io, level)
    end
    return add_UT(ts, logger; use_relative=use_relative), fileio
end

"""filter out items to be displayed only for console"""
function filter_group(logger)
    EarlyFilteredLogger(logger) do log
        !(log.group in (:pgbar, :nosave))
    end
end

"""Filter out log spam"""
function filter_module(logger)
    EarlyFilteredLogger(logger) do log
        !(root_module(log._module) in (:ProtoBuf,))
    end
end

function root_module(m::Module)
    gp = m
    while (gp ≠ m)
        m = parentmodule(m)
        gp = m
    end
    nameof(gp)
end

function add_MET(ts, logger)
    TransformerLogger(logger) do log
        met = format_MET(ts.met)
        merge(log, (; message = "$met | $(log.message)"))
    end
end

function add_UT(ts, logger; use_relative)
    TransformerLogger(logger) do log
        if use_relative
            time = format_MET(ts.ut - ts.offset)
        else
            time = format_UT(ts.ut)
        end
        merge(log, (; message = "$time | $(log.message)"))
    end
end

"""Create home directory for this logging session"""
function create_log_home(root::String, name::String)
    project_root = string(root, "/", name)
    mkpath(project_root)
    directory_number = -1
    for (root, dirs, files) in walkdir(project_root)
        for d in dirs
            number = tryparse(Int64, d)
            isnothing(number) && continue
            if number > directory_number
                directory_number = number
            end
        end
    end
    home = string(project_root, "/", directory_number+1)
    mkdir(home)
    home
end

"""Format MET seconds to T+#D ##:##:##[.###] format."""
function format_MET(t::Real)
    D, H, M, S, ms = decompose_time(t)
    hms = join([H, M, S], ':')
    if D ≠ "0"
        return string("T+(", D, "d)", hms, ms)
    end
    return "T+"*hms*ms
end

"""Format UT seconds to # Day ##:##:##[.###] format."""
function format_UT(t::Real)
    D, H, M, S, ms = decompose_time(t)
    hms = join([H, M, S], ':')
    return string(D, " Day ", hms, ms)
end

"""Convert number of seconds into day, hour, minute, second."""
function decompose_time(t::Int64)
    S = lpad(t % 60, 2, '0')
    M = lpad(t ÷ 60 % 60, 2, '0')
    H = lpad(t ÷ 3600 % 24, 2, '0')
    D = string(t ÷ 86400)
    D, H, M, S, ""
end

"""Convert number of seconds into day, hour, minute, second, microsecond"""
function decompose_time(t::Float64)
    milliseconds = string(round(t % 1, digits=2))[2:end]
    seconds = convert(Int64, floor(t))
    D, H, M, S, _ = decompose_time(seconds)
    D, H, M, S, rpad(milliseconds, 3, "0")
end
