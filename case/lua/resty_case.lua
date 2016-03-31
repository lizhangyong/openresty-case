local common = require "lua.comm.common"
local logic_func = require "lua.comm.logic_func"


local res = {}
local val, err = logic_func.get_ip_by_mid(ngx.var.arg_mid, ngx.var.remote_addr)
if val then
	res.ip = val
    return ngx.say(common.json_encode(res))
end

if err then
    ngx.log(ngx.ERR, "get ip failed: ", err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR) 
end

res.ip = "Not Found"
return ngx.say(common.json_encode(res))
