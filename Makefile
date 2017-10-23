include config.mk

stop:
	-@fuser -k $(WEB_PORT)/tcp
	-@fuser -k $(PGREST_PORT)/tcp

start:
ifeq ($(env), production)
	@echo "Starting in PRODUCTION!!!"

	@postgrest ~/rum/postgrest.conf &> /dev/null &

	@bundle exec puma \
		--port $(WEB_PORT) \
		--environment production \
		--redirect-stderr /tmp/rum-errors.log \
		--daemon

else ifeq ($(env), staging)
	@echo "Starting in staging"

	@postgrest ~/rum/postgrest.conf &> /dev/null &

	@bundle exec puma \
		--port $(WEB_PORT) \
		--environment production \
		--daemon

else
	@postgrest postgrest.conf &

	@bundle exec rerun --pattern "**/*.{rb}" -- \
		rackup --port $(WEB_PORT)
endif

install:
	bundle install
	./run/install

stats:
	@ssh $(SRV_USER)@$(SRV_SERVER) "/usr/local/bin/goaccess ~/rum_access.log --log-format=COMBINED > /tmp/stats.html"
	@rsync $(SRV_USER)@$(SRV_SERVER):/tmp/stats.html /tmp/rum-stats--$$(date +'%Y-%m-%d').html
	@$$BROWSER /tmp/rum-stats--$$(date +'%Y-%m-%d').html

sync:
	@rsync -OPr \
		--copy-links \
		--checksum \
		--exclude=$(PID_FILE) \
		--exclude=.git \
		--exclude=scripts \
		--exclude=dependencies.tsv \
		--exclude=storage \
		--delete-after \
		$(PROJECT)/ \
		$(SRV_USER)@$(SRV_SERVER):$(SRV_DEST)

restart: stop start

remote-stop:
	@ssh $(SRV_USER)@$(SRV_SERVER) "cd $(SRV_DEST); make stop env=$(env)"

remote-start:
	@ssh $(SRV_USER)@$(SRV_SERVER) "/bin/bash --login -c 'cd $(SRV_DEST); make start env=$(env)'"

deploy: sync remote-stop remote-start
