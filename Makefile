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
	@docker-compose up dev

.PHONY: compose-alpine
compose-alpine:
	@docker-compose up server_alpine

.PHONY: compose-ubuntu
compose-ubuntu:
	@docker-compose up server_ubuntu

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
