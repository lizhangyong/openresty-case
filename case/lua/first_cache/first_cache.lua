module(..., package.seeall)

local cache  = require "lua.first_cache.db_redis"


function conn_cache()
    return cache:conn_cache()
end

function get_cache(key)
    return cache:get_cache(key)
end

function set_cache(key, value)
    return cache:set_cache(key, value)
end

