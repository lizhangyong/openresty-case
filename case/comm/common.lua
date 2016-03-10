module("lua.comm.common", package.seeall)

-- to prevent use of casual module global variables
getmetatable(lua.comm.common).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end
