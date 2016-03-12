module(..., package.seeall)  --todo 最好修改成local _M = {} 的方式

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

--以下代码暂未测试，先提交
--local _M = {}
--local cache  = require "lua.first_cache.db_redis"

--function _M.conn_cache(self)
--    return cache:conn_cache()
--end

--function _M.get_cache(self, key)
--    return cache:get_cache(key)
--end

--function _M.set_cache(self, key, value)
--    return cache:set_cache(self, key, value)
--end

--return _M
