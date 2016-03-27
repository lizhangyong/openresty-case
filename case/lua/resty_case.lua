local common = require "lua.comm.common"

local mid = ngx.var.arg_mid

--get ip from cache
local res, err = common.get_ip_from_cache(mid)
if res then
    return ngx.say("result is: ", res)
end

if err then
    ngx.log(ngx.INFO, "cache not hit for mid: ", mid, ' err:', err)
end

--get ip from db
local res, err = common.get_ip_from_db(mid)
if res then
    common.update_ip_to_cache(mid, res)
    return ngx.say("result is: ", res)
end

if err then
    ngx.log(ngx.ERR, "query db failed: ", mid, ' err:', err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end


--new mid, update cache and db
common.update_ip_to_cache(mid, ngx.var.remote_addr)
common.update_ip_to_db(mid, ngx.var.remote_addr)

return ngx.say("no result found!")
