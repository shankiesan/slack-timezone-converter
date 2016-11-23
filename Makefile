# Apologies for some redundant code in here, taken from another makefile that I haven't had time to clean up yet.

name := slack-timezone-converter
image_name := $(name)
# FLAGS = -v $(PWD)/sandbox:/source \
        --name $(name)

FLAGS = --name $(name)

DOCKER := docker
DOCKER_TASK := $(DOCKER) run --rm -ti -p 80:80 -p 443:443
DOCKER_PROC := $(DOCKER) run -d -ti

build:
	@$(DOCKER) build -t $(image_name) .
.PHONY: build

push:
	@$(DOCKER) push $(image_name)
.PHONY: push

shell:
	@$(call task,--entrypoint=bash,)
.PHONY: shell

run:
	@$(call task,,browsersync)
.PHONY: run

###############################################################################
# Test                                                                        #
###############################################################################
test-clean:
	$(DOCKER) rm -vf $(name)
.PHONY: clean

test-proxy: test-app
	$(call proc,start --proxy=testapp:8000 --files="*.css")
.PHONY: test-proxy

test-server:
	$(DOCKER_PROC) $(FLAGS) \
                 -p 3000:3000 \
                 -p 3001:3001 \
                 $(image_name) \
                 $1 start --server --files "*.css"
.PHONY: test-server


test-proxy-polling: test-app
	@$(call proc,start --config proxy_polling.js)
.PHONY: test-proxy-polling

test-proxy-fsevents: test-app
	@$(call proc,start --config proxy_fsevents.js)
.PHONY: test-proxy-fsevents

test-polling:
	@$(call proc,start --config polling.js)
.PHONY: test-polling

test-fsevents:
	@$(call proc,start --config fsevents.js)
.PHONY: test-fsevents


###############################################################################
# Helpers                                                                     #
###############################################################################

define task
  $(DOCKER_TASK) $(FLAGS) \
                 $1 \
                 $(image_name) \
                 $2
endef

define proc
  $(DOCKER_PROC) $(FLAGS) \
                 $(image_name) \
                 $1
endef
