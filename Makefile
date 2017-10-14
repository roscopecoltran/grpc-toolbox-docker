####################################
# Build GOLANG based executables
####################################

### PLATFORM ########################################################################################################
ifeq (Darwin, $(findstring Darwin, $(shell uname -a)))
  PLATFORM := OSX
  OS := darwin
else
  PLATFORM := Linux
  OS := linux
endif

### ARCH ############################################################################################################
ARCH := amd64

### DOCKER_COMPOSE ##################################################################################################
.PHONY: compose-dev
compose-dev:
	@docker-compose up letmegrpc_dev jrpc_dev

.PHONY: compose-letmegrpc-dev
compose-letmegrpc-dev:
	@docker-compose up letmegrpc_dev

.PHONY: compose-alpine
compose-letmegrpc-alpine:
	@docker-compose up letmegrpc_alpine

.PHONY: compose-ubuntu
compose-letmegrpc-ubuntu:
	@docker-compose up letmegrpc_ubuntu

# to clean and check later... ^^
### CRANE ###########################################################################################################
.PHONY: crane
crane:
	@crane lift

.PHONY: crane-dev
crane-dev:
	@crane lift dev

.PHONY: crane-alpine
crane-alpine:
	@crane lift alpine

.PHONY: crane-ubuntu
crane-ubuntu:
	@crane lift ubuntu
