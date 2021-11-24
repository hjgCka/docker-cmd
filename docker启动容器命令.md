#### MySQL



> docker run --name dev-mysql -p 3308:3306 -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_USER=nacos -e MYSQL_PASSWORD=nacos -v D:\docker_cmd\image_volumes\mysql:/var/lib/mysql -d mysql:8.0.27 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci



使用环境变量MYSQL_ROOT_PASSWORD为root用户设置了密码，并新增了nacos用户且为该用户配置了密码。
后面的参数设置字符集为utf-8。



如果需要使用自定义配置文件，加上如下命令：

> -v /my/custom/xx.cnf:/etc/mysql/my.cnf 



#### Redis

> docker run -p 6389:6379 -v D:\docker_cmd\image_volumes\redis\conf:/usr/local/etc/redis  -v D:\docker_cmd\image_volumes\redis\data:/data --name dev-redis -d redis:6.2 redis-server /usr/local/etc/redis/redis.conf

D:\docker_cmd\image_volumes\redis\conf目录下需要存放一个redis.conf配置文件。

内容为：

requirepass  redis@qwer1234

