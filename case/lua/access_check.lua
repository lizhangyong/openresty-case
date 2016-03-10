local ngx_req = ngx.req.get_uri_args

local function check_mid(mid)
    if mid ~= nil then
        --local m = ngx.re.match(mid, "[0-9a-fA-F]+", "o")
        local m = string.match(mid, "^[a-zA-Z0-9]+$")
        if m and string.len(mid) <= 32 then
            return true
        else
            return false
        end
    else
       return false
    end
end

local function check_ip(ip)
    if ip == nil then
        return false
    end
    ---通配符^在gmatch中怎么使用？
    if string.find(ip, "^%d") then
    --if ngx.re.find(ip, "^%d", "o") then
        for i,j,k,w in string.gmatch(ip, "(%d+)%.(%d+)%.(%d+)%.(%d+)") do
        --for i,j,k,w in ngx.re.gmatch(ip, "(%d+)%.(%d+)%.(%d+)%.(%d+)", "o") do
            if tonumber(i) >0 and tonumber(i) < 256 and tonumber(j) > 0 and tonumber(j) < 256
                   and tonumber(k) > 0 and tonumber(k) < 256 and tonumber(w) > 0 and tonumber(w) < 256 then
                return true
            end
        end
    end
    return false 
end

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

if not check_mid(mid) then
    ngx.say("invalid mid")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
elseif not check_ip(ip) then
    ngx.say("invalid ip")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
else
--    ngx.say("access_check_ok")
end
