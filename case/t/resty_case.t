
use Test::Nginx::Socket::Lua;
use Test::Nginx::Socket 'no_plan';

$ENV{TEST_NGINX_REDIS_PORT} ||= 6379;
$ENV{TEST_NGINX_PORT} ||= 8080;

run_tests();

__DATA__

=== TEST 1: mid存在于redis中
--- config
    location /openresty-case/some.json {
        #初始化redis
        access_by_lua '
            local redis = require "resty.redis"
            local red = redis:new()

            local ok, err = red:connect("127.0.0.1", $TEST_NGINX_REDIS_PORT);
            if not ok then
                ngx.log(ngx.ERR, "failed to connect: ", err)
                return
            end

            red:set_timeout(100) -- 0.1 sec

            local data, err = red:set("173f6bbce467fbb20bd8a14343429d95", "10.16.93.17")
            if not data then
                ngx.log(ngx.ERR, "failed to set: ", err)
            end
            ngx.sleep(0.1)
            red:close()
        ';
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/some.json/?mid=173f6bbce467fbb20bd8a14343429d95

--- error_code: 200
--- no_error_log
[error]
--- response_body_like
10.16.93.17
