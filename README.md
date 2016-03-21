
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
https://moonbingbing.gitbooks.io/openresty-best-practices/content/ngx/nginx_brief.html  最佳实践

性能测试
========
环境: 虚拟机 4核cpu 8G内存  

工具: ab -k -c 50 -n 500000 -r <url>  

结果: qps约为29000  

具体测试数据:  
 
	ab -k -c 50 -n 500000 -r "http://10.16.93.178:8080/openresty-case/some.json?mid=273f6bbce467fbb20bd8a14343429d95"
	This is ApacheBench, Version 2.3 <$Revision: 1663405 $>
	Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
	Licensed to The Apache Software Foundation, http://www.apache.org/

	Benchmarking 10.16.93.178 (be patient)
	Completed 50000 requests
	Completed 100000 requests
	Completed 150000 requests
	Completed 200000 requests
	Completed 250000 requests
	Completed 300000 requests
	Completed 350000 requests
	Completed 400000 requests
	Completed 450000 requests
	Completed 500000 requests
	Finished 500000 requests
        
	Server Software:        openresty/1.9.7.3
	Server Hostname:        10.16.93.178
	Server Port:            8080

	Document Path:          /openresty-case/some.json?mid=273f6bbce467fbb20bd8a14343429d95
	Document Length:        21 bytes

	Concurrency Level:      100
	Time taken for tests:   34.041 seconds
	Complete requests:      1000000
	Failed requests:        0
	Keep-Alive requests:    990046
	Total transferred:      172950230 bytes
	HTML transferred:       21000000 bytes
	Requests per second:    29376.30 [#/sec] (mean)
	Time per request:       3.404 [ms] (mean)
	Time per request:       0.034 [ms] (mean, across all concurrent requests)
	Transfer rate:          4961.56 [Kbytes/sec] received
