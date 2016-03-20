
local cache  = require "lua.first_cache.db_redis"

local _M = {}
local _M = { _VERSION = '1.0' }

function _M.conn_cache(self)
    return cache:conn_cache()
end

function _M.get_cache(self, key)
    return cache:get_cache(key)
end

function _M.set_cache(self, key, value)
    return cache:set_cache(key, value)
end

return _M
