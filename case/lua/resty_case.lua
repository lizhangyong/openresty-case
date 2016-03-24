
local config = require "lua.comm.config"
local cache_op   = require "lua.first_cache.first_cache"
local db_op = require "lua.db.db"

local cli_ip = ngx.var.remote_addr
local mid = ngx.var.arg_mid

--从缓存中查找mid对应的ip
local res, err = cache_op:get_cache(mid)
if err then
    ngx.log(ngx.WARN, "cache not hit for mid: ", mid, ' err:', err)
end
if nil ~= res then
   --命中缓存
   return ngx.say("result is: ", res)
end

--从数据库中查找mid对应的ip
local quote_mid = ngx.quote_sql_str(ngx.var.arg_mid) 
local sql = string.format("SELECT ip FROM resty_case WHERE mid = %s limit 1", quote_mid)
local res, err = db_op:do_cmd(sql)
if not res or err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

--数据库中有结果，更新缓存
if type(res) == "table" and res[1] ~= nil and res[1]["ip"] ~= nil then
     cache_op:set_cache(mid, res[1]["ip"])
     return ngx.say("result is: ", res[1]["ip"])
end

--如果都没找到，更新客户端的ip到mysql和redis 
local quote_ip = ngx.quote_sql_str(cli_ip)
sql = string.format("INSERT IGNORE INTO resty_case(mid, ip) values(%s, %s)", quote_mid, quote_ip)
db_op:do_cmd(sql)
cache_op:set_cache(mid, cli_ip)
ngx.log(ngx.INFO, "no result found!")

return ngx.say("no result found!")

