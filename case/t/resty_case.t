
use Test::Nginx::Socket::Lua;
use Test::Nginx::Socket 'no_plan';

$ENV{TEST_NGINX_REDIS_PORT} ||= 6379;

run_tests();

__DATA__

=== TEST 1: mid存在于redis中 
--- config
    location /openresty-case/some.json {
        #初始化redis
        access_by_lua '
            local redis = require "resty.redis"
            local red = redis:new()

            local ok, err = red:connect("127.0.0.1", 6379);
            if not ok then
                ngx.say("failed to connect: ", err)
                return
            end

            red:set_timeout(100) -- 0.1 sec

            local data, err = red:set("test1", "10.16.93.178")
            if not data then
                ngx.say("failed to set: ", err)
            end
            ngx.sleep(0.1)
            red:close()
        ';
        proxy_pass http://127.0.0.1:8080;
    }

--- request
GET /openresty-case/some.json/?mid=test1

--- error_code: 200
--- respone_body_like
\s*10.16.93.178
