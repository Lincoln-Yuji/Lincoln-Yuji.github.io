#!/usr/bin/env bash

DOCKER_IMG_NAME='chirpy-jekyll-blogs'
DOCKER_PWD='/usr/src/app'

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    build)
      if [[ -n "$(docker image ls | grep ${DOCKER_IMG_NAME})" ]]; then
        docker container rm "$DOCKER_IMG_NAME" 2> /dev/null
        docker image rm "$DOCKER_IMG_NAME" 2> /dev/null
      fi
      docker build -t "$DOCKER_IMG_NAME" .
      shift
    ;;
    run)
      # docker run --rm -it -v "${PWD}:${DOCKER_PWD}" -p '4000:4000' "$DOCKER_IMG_NAME"
      docker run --rm -it -p '4000:4000' "$DOCKER_IMG_NAME"
      shift
    ;;
    update)
      echo "[WORK IN PROGRES] Not implemented yet..."
      shift
    ;;
    *)
      printf 'Invalid command: %s\n' "$1"
      exit 1
    ;;
  esac
done
