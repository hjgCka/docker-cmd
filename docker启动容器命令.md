#### MySQL

> docker run --name dev-mysql -p 3308:3306 -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_USER=nacos -e MYSQL_PASSWORD=nacos -v D:\docker_cmd\image_volumes\mysql:/var/lib/mysql -d mysql:8.0.27 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci



使用环境变量MYSQL_ROOT_PASSWORD为root用户设置了密码，并新增了nacos用户且为该用户配置了密码。
后面的参数设置字符集为utf-8。



如果需要使用自定义配置文件，加上如下命令：

> -v /my/custom/xx.cnf:/etc/mysql/my.cnf 



---



#### Redis

> docker run -p 6389:6379 -v D:\docker_cmd\image_volumes\redis\conf:/usr/local/etc/redis  -v D:\docker_cmd\image_volumes\redis\data:/data --name dev-redis -d redis:6.2 redis-server /usr/local/etc/redis/redis.conf

D:\docker_cmd\image_volumes\redis\conf目录下需要存放一个redis.conf配置文件。

内容为：

> requirepass  redis@qwer1234



---



### RabbitMQ

> ```
> docker run -d --hostname my-rabbit \
>  --name rabbit \
>  -p 5672:5672 -p 15672:15672 \
>  -v /data/container_volume/rabbitmq:/var/lib/rabbitmq \
>  rabbitmq:3.8.3-management
> ```



默认的账号和密码是guest / guest，如果想更好默认的guest/guest，可以指定RABBITMQ_DEFAULT_USER和RABBITMQ_DEFAULT_PASS这2个环境变量。



---



### MongoDB

mongodb支持复制集，分片，单点等安装方式。复制集安装时，需要执行配置命令，将某个节点设置为primary。

> ```
> docker run --name mongodb-rs -d \
>    -p 27017:27017 \
>    -v /xxx/mongod.conf:/etc/mongo/mongod.conf \
>    -v /xxx/mongo:/data/db \
>     -d  mongo:4.2.1 \
>     --config /etc/mongo/mongod.conf
> ```

mongod.conf内容如下，其实是yaml格式：

> ```yaml
> security:
>   authorization: enabled
> 
> storage:
>   wiredTiger:
>     engineConfig:
>       cacheSizeGB: 1
> 
> net:
>   bindIpAll: true
> 
> # 副本集的配置
> replication:
>    oplogSizeMB: 50
>    replSetName: rs-dev
>    enableMajorityReadConcern: true
> ```

使用mongo客户端工具连接上服务器之后，还需执行命令初始化副本集。



---



### Openresty

> docker run  -d --name openresty  \
>         -v /xxx/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
> 	      -v  /xxx/logs:/usr/local/openresty/nginx/logs/ \
> 	         -v /xxx/lua_scripts:/usr/local/openresty/nginx/luascripts \
>                 -e TZ=Asia/Shanghai \
>                -p 8088:8088   \
>       openresty/openresty:1.19.3.1-centos

/xxx/lua_scripts目录下面放upload.lua文件。



---



### Kafka

> version: '3'
>
> services:
>   zookeeper:
>     image: zookeeper:3.6.2
>     ports:
>       - 2181:2181
>     environment:
>       ZOO_MY_ID: 1
>       ZOO_SERVERS: server.1=zookeeper:2888:3888;2181
>     volumes:
>       - ./zk_data:/data
>
>   kafka:
>     image: wurstmeister/kafka:2.13-2.6.0
>     ports:
>       - 9093:9092
>         environment:
>             KAFKA_BROKER_ID: 0
>             KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
>             KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://10.168.55.88:9093
>             #KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT
>             #KAFKA_INTER_BROKER_LISTENER_NAME: OUTSIDE
>             KAFKA_MESSAGE_MAX_BYTES: 2000000
>             KAFKA_CREATE_TOPICS: "test_topic:1:1"
>             KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
>         volumes:
>             - ./kafka_logs:/kafka
>             depends_on:
>                   - zookeeper

使用docker-compose启动服务，会同时启动zookeeper和kafka。
