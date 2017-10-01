include config.mk

stop:
	@fuser -k $(WEB_PORT)/tcp

start:
	@bundle exec puma \
		--port $(WEB_PORT) \
		--environment production \
		--pidfile $(PID_FILE) \
		--redirect-stderr /tmp/rum-errors.log \
		--daemon

develop:
	@bundle exec rerun --pattern "**/*.{rb}" -- rackup

install:
	bundle install
	./run/install

stats:
	@ssh $(SRV_USER)@$(SRV_SERVER) "goaccess ~/rum_access.log --log-format=COMBINED -a > /tmp/stats.html"
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
		$(DIST)/ \
		$(SRV_USER)@$(SRV_SERVER):$(SRV_DEST)

restart: stop start

remote-stop:
	@ssh $(SRV_USER)@$(SRV_SERVER) "cd $(SRV_DEST); make stop"

remote-start:
	@ssh $(SRV_USER)@$(SRV_SERVER) "/bin/bash --login -c 'cd $(SRV_DEST); make start'"

deploy: sync remote-stop remote-start
