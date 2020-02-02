FROM debian:buster
RUN apt-get update && apt-get install -y simple-cdd git-core && apt-get clean
WORKDIR /cdd
CMD [ "/bin/bash" ]
