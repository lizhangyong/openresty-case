
use Test::Nginx::Socket::Lua;
use Test::Nginx::Socket 'no_plan';

run_tests();

__DATA__

=== TEST 1: 测试mid参数非法的情况
--- config
    location /openresty-case/some.json {
        proxy_pass http://127.0.0.1:8080;
    }

--- request
GET /openresty-case/some.json/?mid=_%$test99

--- error_code: 400


=== TEST 2: 测试mid参数非法的情况
--- config
    location /openresty-case/some.json {
        proxy_pass http://127.0.0.1:8080;
    }

--- request
GET /openresty-case/some.json/?mid=012345678901234567890123456789abc

--- error_code: 400
~                    

