
测试环境
========
虚拟机 4核cpu 8G内存  

测试方法
========
使用wrk工具进行测试  
wrk安装:
　　mac OS X系统下，建议使用brew安装，自动解决包依赖问题。  
　　brew安装： ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"  
　　wrk安装：  brew install wrk

测试命令:  
　　wrk -c50 -d60 -t6 -s wrk_test.lua http://10.16.93.178:8080/  
　　wrk_test.lua说明: 预生成1000个mid, 每次随机取其中一个作为参数进行请求。

测试结果
========
qps: 约60000(并发数为60情况下)

资源占用情况:  
　　ID 　USER　PR　NI　　VIRT　RES　　　SHR　S　%CPU　%MEM　TIME+　COMMAND  
16713 nobody　　20　0　191040   5000　1964 R　78.0　0.1　0:08.99　nginx: worker process  
16716 nobody　　20　0　191400   5304　1980 R　77.0　0.1　0:09.53　nginx: worker process  
16715 nobody　　20　0　190876   4792　1948 S　76.0　0.1　0:08.83　nginx: worker process  
16714 nobody　　20　0　190748   4620　1932 R　74.0　0.1　0:08.44　nginx: worker process  

详细结果:  
wrk -c50 -d60 -t6 -s wrk_test.lua http://10.16.93.178:8080/  
　Running 1m test @ http://10.16.93.178:8080/  
　6 threads and 50 connections  
　Thread Stats   Avg      Stdev     Max   +/- Stdev  
　Latency   826.28us    1.57ms  71.44ms   98.16%  
　Req/Sec    10.08k     1.84k   13.12k    79.47%  
　3613504 requests in 1.00m, 671.81MB read  
　Requests/sec:  60170.48  
　Transfer/sec:     11.19MB


