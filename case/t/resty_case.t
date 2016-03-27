
use Test::Nginx::Socket::Lua;
use Test::Nginx::Socket 'no_plan';
use Cwd qw(cwd);

$ENV{TEST_NGINX_REDIS_PORT} ||= 6379;
$ENV{TEST_NGINX_PORT} ||= 8080;
$ENV{TEST_NGINX_NO_SHUFFLE} ||= 1;

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
    lua_package_cpath "/usr/local/openresty/lualib/?.so;/usr/local/openresty/lualib/?.so;;";
};

no_shuffle();
run_tests();

__DATA__

=== TEST 1: 测试mid参数非法的情况--特殊字符
--- config
    location /openresty-case/api-test {
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/api-test/?mid=_%$test99

--- error_code: 400


=== TEST 2: 测试mid参数边界值(长度刚超过32)
--- config
    location /openresty-case/api-test {
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/api-test/?mid=012345678901234567890123456789abc

--- error_code: 400

=== TEST 3: 测试mid参数为空
--- config
    location /openresty-case/api-test {
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/api-test/?mid=

--- error_code: 400

=== TEST 4: 测试mid不存在
--- config
    location /openresty-case/api-test {
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/api-test/?some=123

--- error_code: 400

=== TEST 5: 测试有多余的参数
--- config
    location /openresty-case/api-test {
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/api-test/?mid=273f6bbce467fbb20bd8a14343429d95&some=123

--- error_code: 200

=== TEST 6: 测试有多余的参数
--- config
    location /openresty-case/api-test {
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
    }

--- request
GET /openresty-case/api-test/?mid=273f6bbce467fbb20bd8a14343429d95&some=123

--- error_code: 200

=== TEST 7: mid存在于redis中
--- http_config eval: $::HttpConfig
--- config
    location /openresty-case/api-test {
        #初始化redis
        access_by_lua '
            local cache = require "db_redis"
            local res, err = cache:set_cache(ngx.var.arg_mid, "10.16.93.16")
            if not res then
               ngx.log(ngx.ERR, "set cache failed, ", " err:", err)
            end
            ngx.sleep(1)
        ';
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
        #清理redis
        log_by_lua '
            local function clear_data(premature, mid)
                local cache = require "db_redis"
                local res, err = cache:del_cache(mid)
                if not res then
                   ngx.log(ngx.WARN, "del cache failed, ", " err:", err)
                end
            end
            local ok, err = ngx.timer.at(0, clear_data, ngx.var.arg_mid)
            if not ok then
                 ngx.log(ngx.WARN, "failed to create timer: ", err)
             end
        ';
    }

--- request
GET /openresty-case/api-test/?mid=273f6bbce467fbb20bd8a14343429d95

--- error_code: 200
--- no_error_log
[error]
--- response_body_like
.+10.16.93.16$

=== TEST 8: mid存在于mysql中, 不在redis中
--- http_config eval: $::HttpConfig
--- config
    location /openresty-case/api-test {
        #初始化redis
        access_by_lua '
            local cache = require "db_redis"
            local res, err = cache:del_cache(ngx.var.arg_mid)
            if not res then
               ngx.log(ngx.ERR, "init redis failed, ", " err:", err)
            end
            local mysql_op = require "db_mysql"
            local sql = string.format("replace into resty_case(mid, ip) values(\'%s\', \'10.16.93.18\')", ngx.var.arg_mid)
            res, err = mysql_op:do_cmd(sql)
            if err then
               ngx.log(ngx.ERR, "init mysql failed, ", " err:", err)
            end
            ngx.sleep(1)
        ';
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
        #清理redis
        log_by_lua '
            local function check_data(premature, mid)
                local cache = require "db_redis"
                local res, err = cache:get_cache(mid)
                if not res then
                   ngx.log(ngx.ERR, "update cache failed, ", " err:", err)
                end
                cache:del_cache(mid)
                local mysql_op = require "db_mysql"
                mysql_op:do_cmd(string.format("delete from resty_case where mid = \'%s\'", mid))
            end
            local ok, err = ngx.timer.at(0, check_data, ngx.var.arg_mid)
            if not ok then
                 ngx.log(ngx.WARN, "failed to create timer: ", err)
             end
        ';
    }

--- request
GET /openresty-case/api-test/?mid=273f6bbce467fbb20bd8a14343429d95

--- error_code: 200
--- no_error_log
[error]
--- response_body_like
.+10.16.93.18$

=== TEST 9: mid既不在mysql，也不在redis
--- http_config eval: $::HttpConfig
--- config
    location /openresty-case/api-test {
        #初始化redis
        access_by_lua '
            local cache = require "db_redis"
            local res, err = cache:del_cache(ngx.var.arg_mid)
            if not res then
               ngx.log(ngx.ERR, "init redis failed, ", " err:", err)
            end
            local mysql_op = require "db_mysql"
            res, err = mysql_op:do_cmd(string.format("delete from resty_case where mid = \'%s\'", ngx.var.arg_mid))
            if err then
               ngx.log(ngx.ERR, "init mysql failed, ", " err:", err)
            end
            ngx.sleep(1)
        ';
        proxy_pass http://127.0.0.1:$TEST_NGINX_PORT;
        #清理redis
        log_by_lua '
            local function check_data(premature, mid)
                local cache = require "db_redis"
                local res, err = cache:get_cache(mid)
                if not res or res ~= "127.0.0.1" then
                   ngx.log(ngx.ERR, "update cache failed, ", " err:", err)
                end
                cache:del_cache(mid)
                local mysql_op = require "db_mysql"
                mysql_op:do_cmd(string.format("delete from resty_case where mid = \'%s\'", mid))
            end
            local ok, err = ngx.timer.at(0, check_data, ngx.var.arg_mid)
            if not ok then
                 ngx.log(ngx.WARN, "failed to create timer: ", err)
             end
        ';
    }

--- request
GET /openresty-case/api-test/?mid=273f6bbce467fbb20bd8a14343429d95

--- error_code: 200
--- no_error_log
[error]
--- response_body
no result found!
