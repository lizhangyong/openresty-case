
local config = require "lua.comm.config"
local cache_op   = require "lua.first_cache.first_cache"
local db_op = require "lua.db.db"

local cli_ip = ngx.var.server_addr
local mid = ngx.req.get_uri_args().mid

--从缓存中查找mid对应的ip
local res, err = cache_op.get_cache(mid)  --todo: 不存在于缓存时的返回值res？
if not res or err then
    ngx.log(ngx.ERR, "cache not hit for mid: ", mid)
else
   --命中缓存
   return ngx.say("result is: ", res)
end

--从数据库中查找mid对应的ip
local tb_name = config.MYSQL_TABLE  --todo： 要测试下配置文件中不存在的情况
local cmd = string.format("select ip from %s where mid = \'%s\'", tb_name, mid)                   --todo: 考虑sql注入
local res, err = db_op.do_cmd(cmd)
if not res or err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

--数据库中有结果，更新缓存
if type(res) == "table" and res[1] ~= nil and res[1]["ip"] ~= nil then
     cache_op.set_cache(mid, res[1]["ip"])
     return ngx.say("result is: ", res[1]["ip"])
else
     --如果都没找到，更新客户端的ip到mysql和redis
    local cmd = string.format("insert into %s(mid, ip) values(\'%s\', \'%s\')", tb_name, mid, cli_ip)  --todo:考虑sql注入
    db_op.do_cmd(cmd)
    cache_op.set_cache(mid, cli_ip)
    ngx.log(ngx.WARN, "no result found!")
    return ngx.say("no result found!")
end
