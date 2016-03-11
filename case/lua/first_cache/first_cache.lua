
local cache  = require "lua.first_cache.db_redis"

local _M = {}

function  _M.conn_cache()
    return cache.conn_cache()
end

function  _M.get_cache(key)
	return cache.get(key)
end

function  _M.set_cache(key, value)
	return cache.set(key, value)
end

return _M
