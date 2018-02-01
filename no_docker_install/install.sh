版本：5.4.3


1、下载
cd  /usr/local
wget        https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.4.3.tar.gz
tar  -zxvf  elasticsearch-5.4.3.tar.gz
备注：如下其他版本直接更换链接中的版本号即可

2、启动es
useradd es
sudo su - es -c  "/usr/local/elasticsearch-5.4.3/bin/elasticsearch -d"
查看进程(占用端口：9200  9300)
ps -ef |grep elastic
备注：Elasticsearch不能使用root用户运行

3、常见问题
启动失败可以查看日志
tail  -fn100  /usr/local/elasticsearch-5.4.3/logs/my-application.log
可能查看到的日志如下：
[2] bootstrap checks failed
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]
[2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

问题：[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]

解决步骤：切换到root用户，编辑limits.conf 添加类似如下内容
vi /etc/security/limits.conf 

添加如下内容:
* soft nofile 65536
* hard nofile 131072
* soft nproc 2048
* hard nproc 4096

问题：[2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
解决：切换到root用户修改配置sysctl.conf

vi /etc/sysctl.conf 
添加下面配置：
vm.max_map_count=655360
并执行命令：
sysctl -p
重启启动elastic

其他问题可以参考该链接：https://www.cnblogs.com/duanxuan/p/6473005.html

4、配置文件详解：
cat /usr/local/elasticsearch-5.4.3/config/elasticsearch.yml

cluster.name: my-application
#集群名称，同一集群该名称必须相同
node.name: node-1
#节点名称，同一集群的节点名称不能相同，如果不配置该项，系统会随机分配一个名称。
node.attr.rack: r1
#指定节点的部落属性，这是一个比集群更大的范围，一般不修改
network.host: 0.0.0.0
#设置端口监听对应的网络地址，一般设置为内网地址
http.port: 9200
#设置对外监听端口，默认9200，处于安全考虑，一般进行修改
#path.data: /path/to/data
#指定数据的存储路径  
#path.logs: /path/to/logs
#指定日志的存储路径
discovery.zen.ping.unicast.hosts: ["10.40.11.141", "[::1]"]
#节点发现设置，将集群中其他节点IP配置至此即可。默认使用tcp 9300端口通讯
action.auto_create_index: .security,.monitoring*,.watches,.triggered_watches,.watcher-history*,.*

5、数据迁移
Elasticsearch同版本数据迁移，只需将数据存储目录的文件拷贝到新集群path，重启es集群，即可自动recovery，迁移效率最快。
