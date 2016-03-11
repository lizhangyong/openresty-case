 local ngx_req_geturiargs = ngx.req.get_uri_args
 local args = ngx_req_geturiargs()
 for key, val in pairs(args) do
     if type(val) == "table" then
	 ngx.say(key, ": ", table.concat(val, ", "))
     else
	 ngx.say(key, ": ", val)
     end
 end

