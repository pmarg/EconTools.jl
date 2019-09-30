using Logging


const _min_enabled_level = Base.CoreLogging._min_enabled_level
const current_logger_for_env = Base.CoreLogging.current_logger_for_env
const shouldlog = Base.CoreLogging.shouldlog
const handle_message = Base.CoreLogging.handle_message
const logging_error = Base.CoreLogging.logging_error

const Calibration = LogLevel(500)
macro calibration(exs...) Base.CoreLogging.logmsg_code((Base.CoreLogging.@_sourceinfo)..., :Calibration, exs...) end
const Simulation = LogLevel(501)
macro simulation(exs...) Base.CoreLogging.logmsg_code((Base.CoreLogging.@_sourceinfo)..., :Simulation, exs...) end

function Base.show(io::IO, level::LogLevel)
    if     level == Logging.BelowMinLevel  print(io, "BelowMinLevel")
    elseif level == Logging.Debug          print(io, "Debug")
    elseif level == Logging.Info           print(io, "Info")
    elseif level == Logging.Warn           print(io, "Warn")
    elseif level == Logging.Error          print(io, "Error")
    elseif level == Logging.AboveMaxLevel  print(io, "AboveMaxLevel")
    elseif level == Calibration            print(io, "Calibration")
    elseif level == Simulation             print(io, "Simulation")
    else                           print(io, "LogLevel($(level.level))")
    end
end
