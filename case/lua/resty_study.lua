
--define db connect function
local mysql_dbname = "resty_test"
local mysql_tbname = "test"

local function conn_redis()
    local redis = require "resty.redis_iresty"
    local red = redis:new()
    red:set_timeout(1000) -- 1 sec
    return red
end

local function conn_mysql()
    local mysql = require "resty.mysql"
    local db, err = mysql:new()
    if not db then
        ngx.say("failed to instantiate mysql: ", err)
        return nil
    end
    db:set_timeout(1000) -- 1 sec
    local ok, err, errno, sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "resty_test",
        user = "root",
        password = "123456",
        max_packet_size = 1024 * 1024 }
    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return nil
    end

    --ngx.say("connected to mysql.")
    return db
end

--get mid and ip from uri
local ngx_req = ngx.req.get_uri_args
local mid = nil
local ip = nil
local args = ngx_req()
for key, val in pairs(args) do
    if key == "mid" then
        if type(val) == "string" and val ~= nil then
            mid = val
        else
            break
        end
    elseif key == "ip" then
        if type(val) == "string" and val ~= nil then
            ip = val
        else
            break
        end
    else
        break
    end
end

if mid == nil or ip == nil then
    ngx.say("invalid mid or ip")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end


--check mid in redis
local red = conn_redis()
if red == nil then
    ngx.say("connect to redis faild!")
    return
end

local res, err = red:get(mid)
if res and res == ip then
    ngx.say("hit")
    return
end

--if not in redis, then check mysql
local mysql = conn_mysql()
if mysql == nil then
    ngx.say("connect to mysql failed!")
    return
end

local sqlstr = nil
res, err, errno, sqlstate = mysql:query(string.format("select * from %s where mid = \'%s\'", mysql_tbname, mid))
if res and type(res) == "table" then
    if next(res) == nil then
        sqlstr = string.format("insert into test (mid, ip) values (\'%s\',\'%s\')", mid, ip)
    else
        if res[1] ~=nil and  res[1]["ip"] ~= nil then
            local ip_val = res[1]["ip"]
            if ip_val ~= ip then
                sqlstr = string.format("update test set ip = \'%s\' where mid = \'%s\'", ip, mid)
            end
        end
    end
else
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
end

local update_mysql_flag = nil
if sqlstr ~= nil then
    res, err, errno, sqlstate = mysql:query(sqlstr)
    if not res then
        ngx.say("update mysql failed: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    else
        update_mysql_flag = "ok"
    end
end

local ok, err = mysql:set_keepalive(10000, 100)
if not ok then
     ngx.say("failed to set keepalive: ", err)
     return nil
end

if update_mysql_flag == nil then
    return
end

--if new mid or new ip, update redis
local res, err = red:set(mid, ip)
if not res then
    ngx.say("update redis failed! err: ", err)
    return
end

ngx.say("update mysql and redis")
