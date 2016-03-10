local redis = require "resty.redis_iresty"
local red = redis:new()

local ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local ok, err = red:get("dog")
if not ok then
    ngx.say("failed to get dog: ", err)
    return
end

ngx.say("get result: ", ok)

local ok, err = red:get("cat")
if not ok then
    ngx.say("failed to get cat: ", err)
    return
end

ngx.say("get result: ", ok)
