function start_progress() end
function update_progress() end
function end_progress() end

struct ProgressMessage
    id::UUID
    name::String
    progress::Float32
end
