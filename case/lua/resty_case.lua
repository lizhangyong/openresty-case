
local config = require "lua.comm.config"
local cache_op   = require "lua.first_cache.first_cache"
local db_op = require "lua.db.db"

local cli_ip = ngx.var.remote_addr
--local mid = ngx.req.get_uri_args().mid
local mid = ngx.var.arg_mid

--从缓存中查找mid对应的ip
local res, err = cache_op:get_cache(mid)
if not res or err then
    ngx.log(ngx.ERR, "cache not hit for mid: ", mid, ' err:', err)
else
   --命中缓存
   return ngx.say("result is: ", res)
end

--从数据库中查找mid对应的ip
local tb_name = "resty_case"  --set default 
if config.MYSQL_TABLE then
    tb_name = config.MYSQL_TABLE
end
                 
local quote_mid = ngx.quote_sql_str(mid) 
--local cmd = [[select ip from ]] .. tb_name .. [[ where mid=]] .. quote_mid .. [[ limit 1;]] 
local cmd = string.format("select ip from %s where mid = %s limit 1", tb_name, quote_mid)  
local res, err = db_op:do_cmd(cmd)
if not res or err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

--数据库中有结果，更新缓存
if type(res) == "table" and res[1] ~= nil and res[1]["ip"] ~= nil then
     cache_op:set_cache(quote_mid, res[1]["ip"])
     return ngx.say("result is: ", res[1]["ip"])
else
     --如果都没找到，更新客户端的ip到mysql和redis 
    local cmd = string.format("insert into %s(mid, ip) values(%s, \'%s\')", tb_name, quote_mid, cli_ip)  
    db_op:do_cmd(cmd)
    cache_op:set_cache(quote_mid, cli_ip)
    ngx.log(ngx.WARN, "no result found!")
    return ngx.say("no result found!")
end
