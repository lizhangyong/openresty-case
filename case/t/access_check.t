
use Test::Nginx::Socket::Lua;
use Test::Nginx::Socket 'no_plan';

run_tests();

__DATA__

=== TEST 1: 无效的mid参数 
--- config
    location /unit_test {
        access_by_lua_file ../../lua/access_check.lua;
        content_by_lua '
          ngx.say("<p>testcase1 ok</p>")
        ';
    }
--- request
GET /unit_test/?mid=_abc*&
--- error_code: 400
--- error_log: invalid mid:

=== TEST 2: 有效参数
--- config
    location /unit_test {
        access_by_lua_file ../../lua/access_check.lua;
        content_by_lua '
          ngx.say("<p>testcase2 ok</p>")
        ';
    }
--- request
GET /unit_test/?mid=173f6bbce467fbb20bd8a14343429d95
--- error_code: 200
