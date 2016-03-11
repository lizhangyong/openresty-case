
实例
====
一个初学openresty的实例

功能描述
========
   使用openresty实现一个服务端程序，接收终端的web请求，获取uri中的mid，根据mid去redis库中查找相应的ip，如果找到则返回命中，
否则从mysql中查找并更新到redis中；如果都不存在，则更新客户端的ip到redis和mysql中。  
   注：mid和ip的值以key-value的形式缓存于redis库中，并存于mysql数据库中。

参考文档
========
https://github.com/openresty/lua-resty-redis/blob/master/t/mock.t                           redis测试用例  
https://github.com/iresty/programming-openresty-zh/blob/master/testing/preparing-tests.adoc nginx的测试  
https://github.com/iresty/nginx-lua-module-zh-wiki  openresty中文wiki
