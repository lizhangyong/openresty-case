
local redis = require "resty.redis_iresty"


local _M = {}


local red = redis:new()
if red == nil then
    ngx.log(ngx.ERR, "redis:new failed")
    return nil, "redis:new failed"
end

function  _M.get_cache( key )
    return red:get(key)
end


function  _M.set_cache( key, value )
    return red:set(key, value)
end


return _M
