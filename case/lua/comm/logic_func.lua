local redis = require "lua.db_redis.db"
local mysql = require "lua.db_mysql.db"
local resty_lock = require "resty.lock"


local _M = {}


local function get_ip_from_db( mid )
    local quote_mid = ngx.quote_sql_str(mid) 
    local sql = string.format("SELECT ip FROM resty_case WHERE mid = %s limit 1", quote_mid)
    local res, err = mysql.do_cmd(sql)
    if res[1] ~= nil and res[1]["ip"] ~= nil then
        return res[1]["ip"], err
    end
    return nil, err
end


local function update_ip_to_db(mid, ip)
    local quote_mid = ngx.quote_sql_str(mid)
    local quote_ip = ngx.quote_sql_str(ip)

    local sql = string.format("INSERT IGNORE INTO resty_case(mid, ip) values(%s, %s)", quote_mid, quote_ip)
    return mysql.do_cmd(sql)
end


function _M.get_ip_by_mid(mid, remote_ip)
    local cache_ngx = ngx.shared.ngx_cache
    local exp_time = 1

    --step1 get from lua_shared_dict
    local res, err = cache_ngx:get(mid)
    if res then
        return res, err
    end

    --step2 get from redis
    res, err = redis.get_cache(mid)
    if res then
        cache_ngx:set(mid, res, exp_time)
        return res, err
    end

    --cache miss!
    local lock = resty_lock:new("cache_lock")
    local elapsed, err = lock:lock("lock_" .. mid)
    if not elapsed then
        ngx.log(ngx.ERR, "cache not found and lock failed: ", err)
        return nil, err
    end

    -- someone might have already put the value into the cache
    -- so we check it here again:
    res, err = cache_ngx:get(mid)
    if res then
        lock:unlock()
        return res, err
    end

    --step3 get from db 
    local res, err = get_ip_from_db(mid)
    if res then
        lock:unlock()
        cache_ngx:set(mid, res, exp_time)
        redis.set_cache(mid, res)
        return res, err
    end

    if err then
        lock:unlock()
        ngx.log(ngx.ERR, "query db failed: ", err)
        return nil, err
    end

    lock:unlock()
    
    --new mid, update cache and db
    update_ip_to_db(mid, remote_ip)
    cache_ngx:set(mid, remote_ip, exp_time)
    redis.set_cache(mid, remote_ip)

    return nil, nil
end


return _M
