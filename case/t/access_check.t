
use Test::Nginx::Socket::Lua;
use Test::Nginx::Socket 'no_plan';

$ENV{TEST_NGINX_PORT} ||= 8080;

run_tests();

__DATA__

=== TEST 1: 测试mid参数非法的情况--特殊字符
--- config
    location /openresty-case/some.json {
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/some.json/?mid=_%$test99

--- error_code: 400


=== TEST 2: 测试mid参数非法的情况-－超长
--- config
    location /openresty-case/some.json {
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/some.json/?mid=012345678901234567890123456789abc

--- error_code: 400
~                    

