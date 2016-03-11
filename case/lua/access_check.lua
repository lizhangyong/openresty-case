
local mid  = ngx.req.get_uri_args().mid

local function check_mid(mid)
    if mid == nil then
        return false
    end 
    
    local m = ngx.re.match(mid, "^[0-9a-zA-Z]+$", "o")
    if m and string.len(mid) <= 32 then
        return true
    end
    return false
end

if not check_mid(mid) then
    ngx.log(ngx.ERR, "invalid mid: ", mid)
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end
