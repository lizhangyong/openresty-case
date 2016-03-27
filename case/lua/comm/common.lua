local redis = require "lua.db_redis.db"
local mysql = require "lua.db_mysql.db"
local resty_lock = require "resty.lock"


local _M = {}


local function get_data_with_cache(opts, fun, ...)
    -- get from cache
    local cache_ngx = ngx.shared.ngx_cache
    local res, err = cache_ngx:get(opts.key)
    if res then
        return res, err
    end

    -- cache miss!
    local lock = resty_lock:new("cache_lock")
    local elapsed, err = lock:lock("lock_" .. opts.key)
    if not elapsed then
        ngx.log(ngx.ERR, "get data with cache not found and sleep(%ss) not found again", opts.lock_wait_time)
        return nil, string.format("get data with cache not found and sleep(%ss) not found again", opts.lock_wait_time)
    end

    -- someone might have already put the value into the cache
    -- so we check it here again:
    res, err = cache_ngx:get(opts.key)
    if res then
        lock:unlock()
        return res, err
    end

    -- get data
    local exp_time = opts.exp_time or 0 -- default 0s mean forever
    local res, err = fun(...)
    if err then
        -- use the old cache at first
        res = cache_ngx:get_stale(opts.key)
        exp_time = opts.exp_time_fail or exp_time
    else
        exp_time = opts.exp_time_succ or exp_time
    end

    --  update the shm cache with the newly fetched value
    if tonumber(exp_time) >= 0 then
        cache_ngx:set(opts.key, res, exp_time)
    end

    lock:unlock()

    return res, err
end


function _M.get_ip_from_cache(mid)
    return get_data_with_cache({key=mid, exp_time_succ=1, exp_time_fail=0.1}, redis.get_cache, mid)
end


function _M.get_ip_from_db( mid )
    local quote_mid = ngx.quote_sql_str(mid) 
    local sql = string.format("SELECT ip FROM resty_case WHERE mid = %s limit 1", quote_mid)
    local res, err = mysql.do_cmd(sql)
    if res[1] ~= nil and res[1]["ip"] ~= nil then
        return res[1]["ip"], err
    end
    return nil, err
end


function _M.update_ip_to_cache(mid, ip)
	local cache_ngx = ngx.shared.ngx_cache
	cache_ngx:set(mid, ip, 1)
	return redis.set_cache(mid, ip)
end


function _M.update_ip_to_db(mid, ip)
	local quote_mid = ngx.quote_sql_str(mid)
	local quote_ip = ngx.quote_sql_str(ip)

	local sql = string.format("INSERT IGNORE INTO resty_case(mid, ip) values(%s, %s)", quote_mid, quote_ip)
	return mysql.do_cmd(sql)
end


return _M
