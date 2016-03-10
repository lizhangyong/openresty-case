

if not check_mid then
    ngx.log(ngx.ERR, "invalid mid")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end