## 构建镜像

docker-compose build [options] [--build-arg key=val...] [SERVICE...]



## 启动镜像

docker-compose up [options] [--scale SERVICE=NUM...] [SERVICE...]

options一般是-d，即在后台运行服务。[SERVICE...]指定服务名。



## 示例文件

使用docker-compose时默认docker-compose.yml文件如下：

```
version: '2'
services: 
  oracle:
    image: oracleinanutshell/oracle-xe-11g
    ports:
      - 1521:1521
      - 18080:8080
    environment:
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8
      
  oraclegbk:
    restart: always
    image: oracleinanutshell/oracle-xe-11g
    ports:
      - 15210:1521
    environment:
      - TZ=Asia/Shanghai
      - LANG=en_US.GBK

  oracle19c:
    image: heartu41/oracle19c
    ports:
      - 15211:1521
    environment:
      - TZ=Asia/Shanghai
      - LANG=en_US.GBK
      
  mysql:
    image: mysql:5.7.28
    restart: always
    volumes:
      - "./mysql/db:/var/lib/mysql"
      - "./mysql/conf/my.cnf:/etc/my.cnf"
      - "./mysql/conf/mysql/mysql.conf.d/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf"
      - "./mysql/init:/docker-entrypoint-initdb.d/"
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=Passw0rd
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8
      
  redis:
    hostname: myredis
    image: redis
    ports:
      - 6379:6379
    restart: always
    volumes:
      - "/usr/local/docker/redis/data:/data"
    command:
      redis-server --appendonly yes --requirepass redis@qwer1234
    environment:
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8root@iZ8vbhxafys0ddj9k1ggahZ:/usr/local/docker#
      
  postgresql:
    image: postgres:11.14-bullseye
    ports:
      - 5080:5432
    restart: always
    volumes:
      - "/usr/local/docker/postgresql/data:/var/lib/postgresql/data"
    environment:
      - POSTGRES_PASSWORD=postgresql@qwer1234
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8
  
  jhipster:
    image: jhipster/jhipster-registry:v6.3.0
    ports:
      - 8761:8761
    restart: always
    volumes:
      - /usr/local/docker/jhipster-registry:/central-config
    environment:
      - _JAVA_OPTIONS=-Xmx512m -Xms256m
      - SPRING_PROFILES_ACTIVE=dev,swagger
      - SPRING_SECURITY_USER_PASSWORD=admin
      - JHIPSTER_REGISTRY_PASSWORD=admin
      - SPRING_CLOUD_CONFIG_SERVER_COMPOSITE_0_TYPE=native
      - SPRING_CLOUD_CONFIG_SERVER_COMPOSITE_0_SEARCH_LOCATIONS=file:./central-config/
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8
```



## ES启动文件

使用如下docker-compose.yml启动elasticsearch

```yaml
version: '2'
services:
  elasticsearch:
    container_name: myes
    image: docker.elastic.co/elasticsearch/elasticsearch:6.3.2
    environment:
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8
    ports:
      - "59200:9200"
      - "59300:9300"
    volumes:
      - ./config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      - ./config/jvm.options:/usr/share/elasticsearch/config/jvm.options
      - ./log:/usr/share/elasticsearch/log
      - ./data:/usr/share/elasticsearch/data
```

需要自己编写elasticsearch.yml和jvm.options文件

elasticsearch.yml样例如下：

```yaml
cluster.name: "docker-cluster"
network.host: 0.0.0.0

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.type: single-node
discovery.zen.minimum_master_nodes: 1
cluster.routing.allocation.disk.watermark.flood_stage: 99%

xpack.security.enabled: true

xpack.security.authc.realms:
    realm1:
        type: native
        order: 0
```

jvm.options样例如下：

```
-Xms512m -Xmx512m
```

