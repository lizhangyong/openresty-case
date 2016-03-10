
local cli_ip = ngx.var.server_addr
local mid = ngx.req.get_uri_args().mid

local red, err ＝ conn_redis()
if err then
    ngx.log(ngx.ERR, err) 
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local mysql, err = conn_mysql()
if err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

—从redis缓存中查找mid对应的ip
local cached_ip, err = get_ip_from_redis(red, mid)
if err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if cached_ip then
   return ngx.say(“cache hit: “..cached_ip)
end

－－从mysql中查找mid对应的ip
local db_ip, err = get_ip_from_mysql(mysql, mid)
if err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
if db_ip then
     update_redis(mid, db_ip)
     return ngx.say(“cache hit: “..db_ip)
end

－－如果都没找到，更新客户端的ip到mysql和redis
update_mysql(mysql, mid, cli_ip)
update_redis(red, mid，cli_ip)
ngx.log(ngx.WARN, "cache not hit!")
return ngx.say(“cache not hit!“)
