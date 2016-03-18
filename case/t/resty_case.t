
use Test::Nginx::Socket::Lua;
use Test::Nginx::Socket 'no_plan';
use Cwd qw(cwd);

$ENV{TEST_NGINX_REDIS_PORT} ||= 6379;
$ENV{TEST_NGINX_PORT} ||= 8080;

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
    lua_package_cpath "/usr/local/openresty/lualib/?.so;/usr/local/openresty/lualib/?.so;;";
};

run_tests();

__DATA__

=== TEST 1: mid存在于redis中
--- http_config eval: $::HttpConfig
--- config
    location /openresty-case/some.json {
        #初始化redis
        access_by_lua '
            local redis_op = require "db_redis"
            local res, err = redis_op:set_cache("173f6bbce467fbb20bd8a14343429d95", "10.16.93.17")
            if not res then
               ngx.log(ngx.ERR, "set cache failed, ", " err:", err)
            end
            ngx.sleep(0.1)
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
