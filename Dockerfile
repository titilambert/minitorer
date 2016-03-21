FROM debian:sid

# Update
RUN apt-get update && apt-get install -y wget

# GRAFANA
RUN wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.6.0_amd64.deb
RUN apt-get install -y adduser libfontconfig
RUN dpkg -i grafana_2.6.0_amd64.deb

# INFLUX
RUN wget https://s3.amazonaws.com/influxdb/influxdb_0.11.0-0.rc1_amd64.deb
RUN dpkg -i influxdb_0.11.0-0.rc1_amd64.deb

# Configure Grafana
RUN apt-get update &&apt-get install -y sqlite3 procps
RUN (grafana-server -homepath=/usr/share/grafana/ -config=/etc/grafana/grafana.ini &) && sleep 5 && pkill grafana
RUN ls /usr/share/grafana/
RUN sqlite3 /usr/share/grafana/data/grafana.db "INSERT INTO \"data_source\" VALUES(1,1,0,'influxdb','minitorer','proxy','http://127.0.0.1:8086','minitorer','minitorer','minitorer',0,'','',1,'{}','2016-03-17 18:57:11','2016-03-17 18:57:13',0);"

# Configure Influx
RUN (influxd -config /etc/influxdb/influxdb.conf &) && sleep 5 && (echo "CREATE DATABASE monitorer;" | influx) && sleep 1 && pkill influxd
RUN (influxd -config /etc/influxdb/influxdb.conf &) && sleep 5 && (echo "CREATE USER monitorer WITH PASSWORD 'monitorer' WITH ALL PRIVILEGES;" | influx) && sleep 1 && pkill influxd

# PORT
EXPOSE 8083
EXPOSE 8086
EXPOSE 3000

# Command
CMD (influxd -config /etc/influxdb/influxdb.conf &) && grafana-server -homepath=/usr/share/grafana/ -config=/etc/grafana/grafana.ini
