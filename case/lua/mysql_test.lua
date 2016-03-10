local cjson = require "cjson"
local mysql = require "resty.mysql"
local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
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
    return
end

ngx.say("connected to mysql.")

res, err, errno, sqlstate =
    db:query("select ip from test where mid = '20'")
if not res then
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    return
else
    --local ip = cjson.encode(res)
    --ngx.say("res: ", ip)
    if res ~= nil and type(res) == "table" and res[1] ~=nil and  res[1]["ip"] == "10.16.1.2" then
             ngx.say("ip: ",res[1]["ip"], "  exsit")
    end
end

local ok, err = db:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end

--res, err, errno, sqlstate =
--    db:query("insert into test (mid, ip) "
--	     .. "values (\'10\',\'10.16.1.2\')")
--if not res then
--    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
--    return
--end

--ngx.say(res.affected_rows, " rows inserted into table resty_test.test ",
--	"(last insert id: ", res.insert_id, ")")

