## 用户定义的网络

```
docker network create -d bridge my-net
```

其它容器在创建时，加上`--network my-net`选项即可实现容器互联。



## Nacos

nacos需要访问数据库，所以它必须要设置`-network`以通过容器名称访问MySQL：

> ```
> docker run -d -p 8848:8848 --network my-net --name nacos-2.0.4-server \
>   -e ARGS="--MYSQL-USER=root --MYSQL-PWD=123456 --MYSQL-HOST=dev-mysql --MYSQL-PORT=3306 --MYSQL-DB=nacos" jeecg-cloud-nacos:3.2.0
> ```



## MySQL

> ```
> docker run -d --name dev-mysql -p 3308:3306 --network my-net \
>  -e TZ=Asia/Shanghai -e MYSQL_ROOT_PASSWORD=123456 \
>  -e MYSQL_USER=nacos -e MYSQL_PASSWORD=nacos \
>   -v D:\docker_cmd\image_volumes\mysql:/var/lib/mysql \
>    mysql:8.0.27 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
> ```



设置时区加上如下环境变量：

```
-e TZ=Asia/Shanghai
```



使用环境变量MYSQL_ROOT_PASSWORD为root用户设置了密码，并新增了nacos用户且为该用户配置了密码。
后面的参数设置字符集为utf-8。



如果需要使用自定义配置文件，加上如下命令：

> -v /my/custom/xx.cnf:/etc/mysql/my.cnf 



## Redis

> ```
> docker run -d --name dev-redis -p 6389:6379 --network my-net \
>  -v D:\docker_cmd\image_volumes\redis\conf:/usr/local/etc/redis \
>   -v D:\docker_cmd\image_volumes\redis\data:/data \
>    redis:6.2 redis-server /usr/local/etc/redis/redis.conf
> ```

D:\docker_cmd\image_volumes\redis\conf目录下需要存放一个redis.conf配置文件。

内容为：

> requirepass  redis@qwer1234

按照上述的命令，除了需要配置文件之外，还指定了启动命令。



## RabbitMQ

> ```
> docker run -d --network my-net --hostname my-rabbit \
> --name rabbit-server \
> -p 5672:5672 -p 15672:15672 \
> -v D:\docker_cmd\image_volumes\rabbitmq:/var/lib/rabbitmq \
>  rabbitmq:3.9.20-management-alpine
> ```



默认的账号和密码是guest / guest，如果想更好默认的guest/guest，可以指定RABBITMQ_DEFAULT_USER和RABBITMQ_DEFAULT_PASS这2个环境变量。



## MongoDB

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



## Openresty

> docker run  -d --name openresty  \
>         -v /xxx/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
> 	      -v  /xxx/logs:/usr/local/openresty/nginx/logs/ \
> 	         -v /xxx/lua_scripts:/usr/local/openresty/nginx/luascripts \
>                 -e TZ=Asia/Shanghai \
>                -p 8088:8088   \
>       openresty/openresty:1.19.3.1-centos

/xxx/lua_scripts目录下面放upload.lua文件。



## Nginx

```
docker run -d --name nginx --restart=always\
   -v /some/content:/usr/share/nginx/html\
   -v /host/path/nginx.conf:/etc/nginx/nginx.conf\
   -v /some/log:/var/log/nginx \
   -p 80:80  -p 8080:8080 \
   10.153.61.36/ims/nginx:1.14.2
```

以上仅为示例，具体的端口、镜像、静态文件、配置文件都需要自行调整。

使用镜像默认配置启动为：

```
docker run -d --name nginx --restart=always \
  -p 8080:80 \
   nginx:1.20.2
```

> --restart=always本地环境最好不要加上



参考文档：

https://nginx.org/

https://hub.docker.com/_/nginx



## Busybox

使用如下命令启动：

```
docker run -it --name busybox -d busybox:1.35.0
```

进入容器后执行相应命令，默认没有`curl`命令。



## Kafka

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



## PostgreSQL

重要的环境变量：

- `POSTGRES_PASSWORD`是唯一必填的环境变量，其余都是可选的。用于设置超级用户的密码。

- `POSTGRES_USER`，设置默认超级用户，并创建一个同名的数据库。不设置的话，默认为`postgres`。

- `POSTGRES_DB`，设置默认的数据库，不设置的话使用`POSTGRES_USER`的值。

- `PGDATA`，用于定义一个子目录用于数据库文件的路径，默认值为`/var/lib/postgresql/data`。如果数据卷不能改为`postgres`用户，推荐使用子目录来包含数据

  ```
  $ docker run -d \
  	--name some-postgres \
  	-e POSTGRES_PASSWORD=mysecretpassword \
  	-e PGDATA=/var/lib/postgresql/data/pgdata \
  	-v /custom/mount:/var/lib/postgresql/data \
  	postgres
  ```



数据库配置：

postgre容器内，有`/usr/share/postgresql/postgresql.conf.sample`文件提供示例，可将其拷贝出来供参考配置。

可以在`/usr/share/postgresql/postgresql.conf.sample`查看数据库配置例子，使用配置文件或者在启动命令行上使用`-c`选项：

```
docker run -d --name some-postgres -v "$PWD/my-postgres.conf":/etc/postgresql/postgresql.conf -e POSTGRES_PASSWORD=mysecretpassword postgres -c 'config_file=/etc/postgresql/postgresql.conf'
```

或者：

```
docker run -d --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword postgres -c shared_buffers=256MB -c max_connections=200
```



数据存储：

自行设置数据路径mount到`/var/lib/postgresql/data`即可

```
docker run --name some-postgres -v /my/own/datadir:/var/lib/postgresql/data -e POSTGRES_PASSWORD=mysecretpassword -d postgres:tag
```



启动命令：

```
docker run -d --name dev-postgres -e POSTGRES_PASSWORD=123456 -v D:\docker_cmd\image_volumes\postgresql:/var/lib/postgresql/data -p 5080:5432 postgres:11.14-bullseye
```

> 本机端口为5080



## ElasticSearch

Docker镜像中，es本身的配置、 jvm配置、 日志的配置存在于/usr/share/elasticsearch/config/。
Elasticsearch loads its configuration from files under /usr/share/elasticsearch/config/。

配置文件名称分别为：elasticsearch.yml和jvm.options，还可以配置log4j2.properties

es的data和log目录存在于${ES_HOME}下的子目录，即/usr/share/elasticsearch/data和/usr/share/elasticsearch/log。



9200端口对外提供服务、9300端口用于内部节点之间通信。



在不考虑系统设置等其它设置的情况下，可以如下配置进行启动：

```
docker run -d --name es -v  full_path/custom_elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
 -v full_path/jvm.options:/usr/share/elasticsearch/config/jvm.options \
 -v full_path/log_dir:/usr/share/elasticsearch/log \
 -v full_path/data_dir:/usr/share/elasticsearch/data \
 -p 9200:9200 docker.elastic.co/elasticsearch/elasticsearch:6.3.2
```



## Gitlab-ce

官方镜像地址：https://hub.docker.com/r/gitlab/gitlab-ce/tags

官方安装文档：https://docs.gitlab.com/ee/install/docker.html

解决头像无法显示问题：

https://blog.csdn.net/xingdiango/article/details/117390196

https://blog.csdn.net/redsoft_mymuch/article/details/115654869

这个配置放在启动命令中，防止重写启动之后，配置丢失。



docker安装使用如下命令，IP配置的是公司的`纵横贝尔5G`分配的地址，固定下来了：

```
sudo docker run --detach \
  --env TZ=Asia/Shanghai \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'http://192.168.2.163:8765/'; gitlab_rails['gitlab_shell_ssh_port'] = 2345;gitlab_rails['gravatar_plain_url']='http://sdn.geekzu.org/avatar/%{hash}?s=%{size}&d=identicon'" \
  --publish 8765:8765 --publish 2345:22 \
  --name gitlab \
  --volume D:\docker_cmd\image_volumes\gitlab\config:/etc/gitlab \
  --volume D:\docker_cmd\image_volumes\gitlab\logs:/var/log/gitlab \
  --volume D:\docker_cmd\image_volumes\gitlab\data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:15.1.1-ce.0
```

> docker容器的--hostname选项，在docker-compose多个容器安装时比较有用，可用hostname互相访问。

安装会持续一段时间，使用如下命令查看日志：

```
docker logs -f gitlab
```

访问时使用root，密码通过一下命令获取：

```
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

这个密码文件会在首次再配置24小时内删除。

> umqnZfEyXVwdnLo7/KTWc1hUv0KpliPaPJqSLxi0+J0=

修改为: gitroot#$Hcc886
