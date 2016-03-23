local redis_cache  = require "lua.first_cache.db_redis"
local resty_lock = require "resty.lock"
local ngx_cache = ngx.shared.ngx_cache

local _M = {}

function _M.get_cache(self, key)
    local val, err = ngx_cache:get(key)
    if val then
        return val, err 
    end
      
    -- cache miss
    local lock = resty_lock:new("cache_lock", {timeout=0, exptime=10})
    local elapsed, err = lock:lock(key)
    if not elapsed then
        ngx.log(ngx.ERR, "cache_lock: failed to lock, ", err)
        return nil, err
    end 

    -- someone might have already put the value into the cache
    -- so we check it here again:
    val, err = ngx_cache:get(key)
    if val then
        lock:unlock()
        return val, err
    end
        
    val, err = redis_cache:get_cache(key)
    if not val then
        lock:unlock()
        return val, err
    end 

    -- update the shm cache with the newly fetched value
    ngx_cache:set(key, val, 10)
    lock:unlock()
    return val, err

end

function _M.set_cache(self, key, value)
    ngx_cache:set(key, val, 10)
    return redis_cache:set_cache(key, value)
end

function _M.del_cache(self, key)
    ngx_cache:delete(key)
    return redis_cache:del_cache(key)
end

return _M

