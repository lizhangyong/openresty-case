
local config = require "lua.comm.config"
local cache_op   = require "lua.first_cache.first_cache"
local db_op = require "lua.db.db"

local cli_ip = ngx.var.server_addr
local mid = ngx.req.get_uri_args().mid

--从缓存中查找mid对应的ip
local res, err = cache_op.get_cache(mid)  --todo: 不存在于缓存时的返回值res？
if not res or err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

--命中缓存
if res ~= ngx.null then
   return ngx.say(“cache hit: “..cached_ip)
end

--从数据库中查找mid对应的ip
local tb_name = config.MYSQL_TABLE  --todo： 要测试下配置文件中不存在的情况
local cmd = ....                    --todo: 考虑sql注入
local res, err = db_op.do_cmd(cmd)
if not res or err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

--数据库中有结果，更新缓存
if type(res) == "table" and res[1]["ip"] ~= nil then
     cache_op.set_cache(mid, res[1]["ip"])
     return ngx.say(“cache hit: “..res[1]["ip"])
else
     --如果都没找到，更新客户端的ip到mysql和redis
    local cmd = ""  --更新数据库操作
    db_op.do_cmd(cmd)
    cache_op.set_cache(mid, cli_ip)
    ngx.log(ngx.WARN, "cache not hit!")
    return ngx.say(“cache not hit!“)
end

