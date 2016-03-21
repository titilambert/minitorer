WD=$(shell pwd)
TMPDASH=dashboard_tmp.json

container_build:
	docker build -t minitorer .

container_run:
	docker run -d -p 3000:3000 -p 8086:8086 -p 8083:8083 --name minitorer minitorer
	@echo
	@echo 
	@echo '*************************************************'
	@echo '**         Go to http://127.0.0.1:3000         **'
	@echo '**                                             **'
	@echo '**               username: admin               **'
	@echo '**               password: admin               **'
	@echo '**                                             **'
	@echo '*************************************************'
	@echo 
	@echo 

container_clean:
	docker rm minitorer

telegraf_get:
	mkdir -p $(WD)/tmp
	wget http://get.influxdb.org/telegraf/telegraf-0.11.1-1_linux_amd64.tar.gz -O $(WD)/tmp/telegraf.tar.gz
	cd $(WD)/tmp && tar xf telegraf.tar.gz
	mkdir -p $(WD)/telegraf
	cp $(WD)/tmp/usr/bin/telegraf $(WD)/telegraf/
	rm -rf $(WD)/tmp
	@echo
	@echo 
	@echo '*************************************************'
	@echo '** Add your Telegraf config in "conf.d" folder **'
	@echo '*************************************************'
	@echo 
	@echo 

telegraf_run:
	telegraf/telegraf -config telegraf/telegraf.conf  -config-directory conf.d

telegraf_debug:
	telegraf/telegraf -config telegraf/telegraf.conf  -config-directory conf.d -debug

dashboard_save:
	@for dash in `curl -s http://admin:admin@127.0.0.1:3000/api/search/ | jq '.[] | {uri}' | grep ":" | awk '{print $$NF}' | tr -d '"'` ; do\
        echo $$dash ;\
        curl -s http://admin:admin@127.0.0.1:3000/api/dashboards/$$dash | jq -M '.["dashboard"]' > $(WD)/dashboards/`echo $$dash | sed 's|db/||g'`.json ;\
    done

dashboard_restore:
	@for dash in dashboards/*; do\
        if [ "$$dash" != "dashboards/empty_for_git" ]; then \
            echo $$dash ;\
            echo '{"overwrite": true, "dashboard":' > $(TMPDASH); \
            find dashboards -wholename "$$dash" -exec cat {} >> $(TMPDASH) \; ;\
            echo '}' >> $(TMPDASH) ;\
            sed -i '0,/"id": *[0-9]*,/{s/"id": *[0-9]*,/"id": null,/}' $(TMPDASH) ;\
            echo curl -H "Content-Type: application/json" -XPOST -d @$(TMPDASH) http://admin:admin@127.0.0.1:3000/api/dashboards/db/; \
            curl -H "Content-Type: application/json" -XPOST -d @$(TMPDASH) http://admin:admin@127.0.0.1:3000/api/dashboards/db/; \
            echo ; \
        fi \
    done

git_add_telegraf_config:
	git add -f conf.d/

git_add_grafana_dashboards:
	git add -f dashboards
