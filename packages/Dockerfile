
# docker build -t xiaoai-patch - < Dockerfile
# docker run -v $PWD:/xiaoai xiaoai-patch

FROM ubuntu:20.04

# set default for automatic tzdata package config
ENV TZ=Europe/Madrid

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt update && apt install -y \
    unzip squashfs-tools \
    build-essential wget rsync gawk bison bc xxd \
    python python3 python3-pip python3-dev python3-yaml \
    cmake autoconf autopoint autogen autoconf-archive \
    libtool libtool-bin \
    git pkg-config gettext intltool qemu-user-static \
    libgcrypt20-dev gperf libglib2.0-dev docbook-xsl \
    xsltproc libncurses-dev flex texinfo tcl \
    openjdk-11-jre openjdk-11-jdk && \
    apt-get clean && \
    pip3 install meson ninja

VOLUME /xiaoai
WORKDIR /xiaoai
CMD ./packages.sh
