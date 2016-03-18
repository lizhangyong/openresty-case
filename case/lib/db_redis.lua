
local redis = require "resty.redis_iresty"

local _M = {}

function _M.conn_cache(self)
    local red = redis:new()  --todo
    if red == nil then
        ngx.log(ngx.ERR, "redis:new failed")
	return nil, "redis:new failed"
    else
        ngx.log(ngx.INFO, "redis:conn_cache")
        return red, nil
    end
end

function  _M.get_cache(self, key)
    local red, err = self:conn_cache()
    if not red or err then
        return red, err
    end
    ngx.log(ngx.INFO, "redis:get_cache")
    return red:get(key)
end

function  _M.set_cache(self, key, value)
    local red, err = self:conn_cache()
    if not red or err then
        return red, err
    end
    ngx.log(ngx.INFO, "redis:set_cache")
    return red:set(key, value)
end

function  _M.del_cache(self, key)
    local red, err = self:conn_cache()
    if not red or err then
        return red, err
    end
    ngx.log(ngx.INFO, "redis:del_cache")
    return red:del(key)
end

return _M
