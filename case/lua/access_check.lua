

local mid = ngx.var.arg_mid
if mid == nil then
    ngx.log(ngx.ERR, "invalid mid: nil")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
else
    local m = ngx.re.match(mid, "^[0-9a-zA-Z]+$", "o")
    if not m or string.len(mid) > 32 then
        ngx.log(ngx.ERR, "invalid mid: ", mid)
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
end
