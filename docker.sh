#!/bin/bash

TAG_NAME="action-repo-scan:latest"

CMD=$1
shift

case $CMD in

  "build")
    echo "Building docker image ..."
    exec docker build -f ./Dockerfile -t $TAG_NAME .
    ;;

  "run")
    echo "Running docker container ..."
    exec docker run -it --rm \
      $TAG_NAME $@
    ;;

  *)
    echo "Unknown command: $CMD"
    echo "Usage: docker.sh [build|run]"
    exit 1
  ;;
esac
