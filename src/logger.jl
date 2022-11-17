"""filter out items to be displayed only for console"""
function filter_group(logger)
    EarlyFilteredLogger(logger) do log
        !(log.group in (:pgbar, :nolog))
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

function add_MET(sp::Spacecraft, logger)
    TransformerLogger(logger) do log
        met = format_MET(sp.system.met)
        merge(log, (; message = "$met | $(log.message)"))
    end
end
