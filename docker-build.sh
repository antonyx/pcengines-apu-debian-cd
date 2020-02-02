#!/bin/sh
docker build -t cdd .
docker run --rm -v $(pwd):/cdd -ti cdd /cdd/build.sh ${1}
