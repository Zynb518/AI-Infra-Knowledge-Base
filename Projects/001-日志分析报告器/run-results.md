# 运行结果

## 正常日志

执行命令：

~~~bash
bash log-analyzer.sh sample.log
~~~

标准输出：

~~~text
log_count=6
log_service:
      3 api
      1 database
      2 worker
log_status:
      4 200
      1 500
      1 503
log_error:
      2 ERROR
~~~

标准错误：无

退出状态：0

## 缺少参数

执行命令：

~~~bash
bash log-analyzer.sh
~~~

标准错误：

~~~text
至少需要提供一个路径参数
~~~

退出状态：1

## 日志文件不存在

执行命令：

~~~bash
bash log-analyzer.sh /tmp/log-analyzer-missing.log
~~~

标准错误：

~~~text
参数1不是合法的日志路径
~~~

退出状态：2
