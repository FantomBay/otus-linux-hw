Стек ELK (Elasticsearch Logstash Kibana)

Elasticsearch - NoSQL БД
Logstash - сбор и обработка данных с возможностью конвеерной обработки 
Kibana - графический интерфейс для работы с БД elasticsearch



Модели реализации стека elk:

1) простая  
beats 		|->	elasticsearch	|	kibana
	---				---			->	---
logstash	|->	X-Pack (платная)|	X-Pack (платная)	

2) безопасное масштабирование  
beats		|-> Logstash		|-> elasticsearch

3) для организации очередей  
beats		|-> kafka			|-> Logstash	|->	elasticsearch

4) препроцессинг сообщений  
beats		|->	logstash		|->	Kafka		|-> logstach	|-> elasticsearch

Высоко доступный стек  
Host a
elasticserach	|-> kibana
Host b
elasticsearch	|->	kibana


Beats - data shippers
---
-поставщики данных для обработки в стеке ELK, устанавливаются на нодах где находятся основные приложения.

Список сборщиков можно посмотреть тут: https://www.elastic.co/beats/
- Filebeat - может получать данные из текстовых файлов (логов, журналов)
- Metricbeats - может отправлять метрики хостов (цпу, память и прочее)
- Packetbeat- может отправлять данные о сети, о сетевых пакетах
- Winlogbeat - для windows логов
- Auditbeat - логи аудита
- Heartbeat - работает хост или нет
- Functionbeat (only cloud systems) - lambda(AWS), CloudFunctions(Yandex), передает информацию из облачных сервисов.

Установка Filebeat:
```
yum install filebeat
```
Пример конфигурации input-date, ```/etc/filebeat/filebeat.yml```:
```yml
- type: log 						<- тип
  enabled: true						<- статус - активен
  paths:							<- путь, набор путей откуда забираются логи (можно использовать регулярки)
	  - /var/log/nginx/access.log
  fields:							<- дополнительные поля в логе
	service: nginx_access
  fields_under_root: true			<- ??? вывод без вложений ???
  scan_frequency: 5s				<- частота проверки изменений
```
Пример конфигурации output(вывода) и передачи:
```
#output.elasticsearch:
# 	hosts: ["localhost:9200"]
	#protocol: "https"
	#username: "elastic"
	#password: "changeme"

output.logstash:
	hosts: ["logstash_host:5044"]
	#ssl.certificate_authorities: ["/etc/pki/root/ca.pem"]
	#ssl.certificate: "/etc/pki/client/cert.pem"
	#ssl.key: "/etc/pki/client/cert.key"
```

Проверка конфигурации:
```
filebeat test config
```

Logstash
---

Установка logstach:
```
yum install logstach -y
```
Конфигурация входных данных [/etc/logstash/conf.d/02-beats-input.conf]
```
input {
	beats {
	port => 5044
	congestion_threshold => 25
	}
}
```
где:
* beats - тип input
* port - на каком порту слушать?
* congestion_threshold - ограничение, не более 25 сообщений в секунду (опционально)

Elasticsearch
---

Kibana
---

