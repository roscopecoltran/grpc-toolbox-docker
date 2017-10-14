#!/bin/sh

set -e

# shared dirs
mkdir -p /data/build/dev
mkdir -p /data/build/lib
mkdir -p /data/build/dist
mkdir -p /data/build/playground

APP_WORKDIR=${APP_WORKDIR:-"/nodejs/src/github.com/mozilla-services/react-jsonschema-form"}
CONTAINER_BUILD_DIR=${CONTAINER_BUILD_DIR:-"/data/build"}

function build_all() {

	# workdir
	cd ${APP_WORKDIR}

	# deps
	npm i -g npm to update
	npm install

	# playground
	npm run build:playground
	rm -fR ${CONTAINER_BUILD_DIR}/playground/*
	cp -Rf ${APP_WORKDIR}/build/* ${CONTAINER_BUILD_DIR}/playground

	# lib
	npm run build:lib
	rm -fR ${CONTAINER_BUILD_DIR}/lib/*
	cp -Rf ${APP_WORKDIR}/lib/* ${CONTAINER_BUILD_DIR}/lib/

	# dist
	npm run build:dist
	rm -fR ${CONTAINER_BUILD_DIR}/dist/*
	cp -Rf ${APP_WORKDIR}/dist/* ${CONTAINER_BUILD_DIR}/dist

}

case "$1" in
  	'rebuild-all')
		build_all
		npm run start
	;;
  	'build-all-bash')
		build_all
	  	exec /bin/bash $@
	;;
  	'sh')
	  	exec /bin/sh $@
	;;
  	'bash')
	  	exec /bin/bash $@
	;;
  	*)
		npm run start
	;;
esac