# Домашнее задание

## Настройка мониторинга

### Настроить дашборд с 4-мя графиками

*    память;
*    процессор;
*    диск;
*    сеть.

### Настроить на одной из систем:

*    zabbix (использовать screen (комплексный экран);
*    prometheus - grafana.

>    использование систем, примеры которых не рассматривались на занятии. Список возможных систем был приведен в презентации.
---
В качестве результата прислать скриншот экрана - дашборд должен содержать в названии имя приславшего.

---

[Стенд с vagrant-prometheus-grafana](https://github.com/viveksatasiya/vagrant-prometheus-grafana)

__nod-exporter__ - (bin)экспортер метрик Prometheus для сбора данных о состоянии сервера в среду визуализации (доступен по 9100 порту)
(Существуют разные экспортёры, например HAProxy, StatsD, Graphite).
> требуется его скачать [_скачать_](https://prometheus.io/download#node_exporter). и запустить:
```
wget https://github.com/prometheus/node_exporter/releases/download/v*/node_exporter-*.*-amd64.tar.gz

tar xvfz node_exporter-*.*-amd64.tar.gz

cd node_exporter-*.*-amd64

./node_exporter
```
метрикистанут доступны на порту 9100
185.177.95.42:9100

Добавляем хост на сервере мониторинга в файле:  
```vagrant@ubuntu-bionic:~/Prometheus/server/prometheus-2.21.0.linux-amd64$ vim prometheus.yml```

```
 - job_name: 'my_ubuntu-server'
   static_configs:
     - targets: ['185.177.95.42:9100']
```
После добавления нужно перезагрузить прометеус:
(в нашем случае это делается след. образом) - 
```
root@ubuntu-bionic:/home/vagrant/Prometheus/server/prometheus-2.21.0.linux-amd64# nohup ./prometheus > prometheus.log 2>&1 &
[1] 11134
```







---
Мелочи:

- храняться метрики в виде: 
```metric_name value```  
```metric_name {lable} value```

```
process_cpu_seconds_total 5.39
```
- фильтрация метрик:
...



