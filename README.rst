#########
Minitorer
#########


Minitorer is a small project to get a quick and, kind of, dirty 
Telegraf, InfluxDB and Grafana metering system.


Installation
############

.. note:: You need `git`, `jq`, `curl` and `make` binaries

::

    git clone git@github.com:titilambert/minitorer.git
    cd minitorer
    make container_build
    make telgraf_get


Start InfluxDB and Grafana
##########################

::

    make container_run


Configure your Telegraf
#######################

You need to add your Telegraf configuration in `conf.d` folder.
See Telegraf documentation here: https://docs.influxdata.com/telegraf/

.. note:: A basic Telegraf configuration is done in `telegraf` folder
          You just need to add configuration for input plugins

Run Telegraf
############

Once you have configured Telegraf, you can launch it with::

    make telegraf_run

.. note:: Use Ctrl-C to stop telegraf binary


Dashboards
##########

When all is started, you just need to create your own dashboards in Grafana.
See Grafana documentation here: http://docs.grafana.org/

Save your Grafana dashboards
############################

You can save your Grafana dashboards with the following command::

    make dashboard_save

You can see your Grafana dashboard saves in dashboards folder

Restore your Grafana dashboard
##############################

You can restore your Grafana dashboards with the following command::

    make dashboard_restore

