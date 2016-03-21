
local mid = ngx.var.arg_mid
if mid == nil or not ngx.re.match(mid, "^[0-9a-zA-Z]{32}$", "o") then
    ngx.log(ngx.INFO, "invalid mid: ", mid)
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

