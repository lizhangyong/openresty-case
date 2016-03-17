
use Test::Nginx::Socket::Lua;
use Test::Nginx::Socket 'no_plan';

$ENV{TEST_NGINX_REDIS_PORT} ||= 6379;

run_tests();

__DATA__

=== TEST 1: 初始化redis 
--- config
    location /openresty-case/init.json {
        content_by_lua '
            local redis = require "resty.redis"
            local red = redis:new()

            local ok, err = red:connect("127.0.0.1", 6379);
            if not ok then
                ngx.say("failed to connect: ", err)
                return
            end

            red:set_timeout(100) -- 0.1 sec

            local data, err = red:set("test10", "10.16.93.178")
            if not data then
                ngx.say("failed to set: ", err)
            end
            ngx.sleep(0.1)
            red:close()
        ';
    }

--- request
GET /openresty-case/init.json
--- error_code: 200

=== TEST 2: 测试mid已经在redis中的情况 
--- config
    location /openresty-case/some.json {
        access_by_lua_file  ../../lua/access_check.lua;
        content_by_lua_file ../../lua/resty_case.lua;
    }

--- request
GET /openresty-case/some.json/?mid=test10

--- error_code: 200
--- tcp_listen: 6379 
--- tcp_query eval
"*2\r
\$3\r
get\r
\$3\r
test10\r
"
--- tcp_reply eval
"\$5\r\n10.16.93.178\r\n"

