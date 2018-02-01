下载 Elasticsearch、Logstash、Kibana
官方地址：https://www.elastic.co/cn/products
cd  /usr/local
wgethttps://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.1.tar.gz
wget https://artifacts.elastic.co/downloads/logstash/logstash-5.6.1.tar.gz
wget https://artifacts.elastic.co/downloads/kibana/kibana-5.6.1-linux-x86_64.tar.gz
tar  -zxvfelasticsearch-5.6.1.tar.gz
tar  -zxvf  logstash-5.6.1.tar.gz
tar  -zxvf  kibana-5.6.1-linux-x86_64.tar.gz

启动Elasticsearch
Elasticsearch不能使用root用户运行
useradd elk
sudo su - elk -c  "/usr/local/elasticsearch-5.6.1/bin/elasticsearch"
验证：curlhttp://localhost:9200
启动Logstash
创建配置文件logstash.conf 声明输入-input与输出-output、及文件格式定义-filter

参考：

input {
      beats {
            port => 5044
      }
}
output {
      stdout {
            codec => rubydebug
      }
      elasticsearch {
            hosts => ["192.168.12.235:9200"]
      }
}

启动：/usr/local/logstash/bin/logstash  -f  ./logstash.conf
启动Kibana
/usr/local/kibana/bin/kibana
验证：curlhttp://localhost:5601 
至此安装完毕，具体配置需要在特定的场景进行调整。
