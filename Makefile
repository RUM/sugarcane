# default.mk
#
# PROJECT = $(shell pwd)
#
# SRV_USER   =
# SRV_SERVER =
#
# PGREST_PORT =
#
# ifeq ($(env), production)
# SRV_DEST =
# WEB_PORT =
# else
# SRV_DEST =
# WEB_PORT =
# endif

include default.mk

stop:
	-@lsof -t -i :$(WEB_PORT) | xargs kill

ifneq ($(env), staging)
	-@lsof -t -i :$(PGREST_PORT) | xargs kill
endif

start:
ifeq ($(env), production)
	@echo "Starting in PRODUCTION!!!"

	@postgrest postgrest.conf &> /dev/null &

	@bundle exec puma \
		--port $(WEB_PORT) \
		--environment production \
		--redirect-stderr /tmp/rum-errors.log \
		--daemon

else ifeq ($(env), staging)
	@echo "Starting in staging"

	@bundle exec puma \
		--port $(WEB_PORT) \
		--environment production \
		--redirect-stderr /tmp/rum-staging-errors.log \
		--daemon

else
	@postgrest postgrest-dev.conf &> /tmp/postgrest-dev.log &

	@bundle exec rerun --pattern "**/*.{rb}" -- \
		rackup --host 0.0.0.0 --port $(WEB_PORT)
endif

install:
	bundle install
	./run/install

sync:
	@git rev-parse --short HEAD > $(PROJECT)/.latest-commit

	rsync -OPr \
		-e "ssh -p $(SSH_PORT)" \
		--copy-links \
		--checksum \
		--exclude=.git \
		--exclude=scripts \
		--exclude=dependencies.tsv \
		--exclude=storage \
		--exclude=access.log \
		--delete-after \
		$(PROJECT)/ \
		$(SRV_USER)@$(SRV_SERVER):$(SRV_DEST)

fetch-storage:
	rsync -Pvr \
		-e "ssh -p $(SSH_PORT)" \
		--size-only \
		--exclude=lost+found \
		--exclude=garbage \
		$(SRV_USER)@$(SRV_SERVER):/storage/ \
		./public/storage

remote-stop:
ifdef env
	@ssh -p $(SSH_PORT) $(SRV_USER)@$(SRV_SERVER) "cd $(SRV_DEST); make stop env=$(env)"
else
	@echo "remote-stop: No env defined!"
endif

remote-start:
ifdef env
	@ssh -p $(SSH_PORT) $(SRV_USER)@$(SRV_SERVER) "/bin/bash --login -c 'cd $(SRV_DEST); make start env=$(env)'"
else
	@echo "remote-start: No env defined!"
endif

deploy: sync remote-stop remote-start
