local json   = require(require("ffi").os=="Windows" and "resty.dkjson" or "cjson")

local _M = {}


function _M.json_decode( str )
    local json_value = nil
    pcall(function (str) json_value = json.decode(str) end, str)
    return json_value
end


function _M.json_encode( data )
    pcall(function (data) json_value = json.encode(data) end, data)
    return json_value
end


return _M
