# Circlator
FROM ubuntu:20.04

ENV   BUILD_DIR=/opt/circlator
ENV   RELEASE=v1.5.5-docker4
ENV   DEBIAN_FRONTEND=noninteractive

# Install the dependancies
RUN   apt-get update && \
      apt-get --yes upgrade && \
      apt-get install --yes apt-utils && \
      apt-get install --yes   git wget unzip bzip2 xz-utils make g++ zlib1g-dev libncurses5-dev libbz2-dev \
                              liblzma-dev libcurl4-openssl-dev libpng-dev libssl-dev libboost-all-dev \
                              libstatistics-descriptive-perl libxml-parser-perl libdbi-perl default-jdk \
                              build-essential checkinstall && \
      apt-get install --yes   libreadline-gplv2-dev libncursesw5-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev

# Install Python 3.5 (required by SPAdes)
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/3.5.6/Python-3.5.6.tgz && \
    tar xzf Python-3.5.6.tgz && \
    cd Python-3.5.6 && \
    ./configure --enable-optimizations && \
    make install && \
    ln -s $PWD/python /usr/local/bin/

RUN   apt-get install -y locales && \
      sed -i -e 's/# \(en_GB\.UTF-8 .*\)/\1/' /etc/locale.gen && \
      touch /usr/share/locale/locale.alias && \
      locale-gen
ENV   LANG     en_GB.UTF-8
ENV   LANGUAGE en_GB:en
ENV   LC_ALL   en_GB.UTF-8

# BWA
ENV BWA_VER=0.7.17
RUN cd /usr/local && \
    wget https://github.com/lh3/bwa/releases/download/v${BWA_VER}/bwa-${BWA_VER}.tar.bz2 && \
    tar xvf bwa-${BWA_VER}.tar.bz2 && \
    rm bwa-${BWA_VER}.tar.bz2 && \
    cd bwa-${BWA_VER} && \
    make && \
    chmod +x bwa && \
    ln -s $PWD/bwa /usr/local/bin

# Prodigal
ENV PRODIGAL_VER=2.6.3
RUN cd /usr/local && \
    wget https://github.com/hyattpd/Prodigal/releases/download/v$PRODIGAL_VER/prodigal.linux && \
    chmod +x prodigal.linux && \
    mv prodigal.linux /usr/local/bin/prodigal && \
    prodigal -h

# Samtools
ENV SAMTOOLS_VER=1.10
RUN cd /usr/local && \
    wget https://github.com/samtools/samtools/releases/download/$SAMTOOLS_VER/samtools-$SAMTOOLS_VER.tar.bz2 && \
    tar xvf samtools-$SAMTOOLS_VER.tar.bz2 && \
    rm samtools-$SAMTOOLS_VER.tar.bz2 && \
    cd samtools-$SAMTOOLS_VER && \
    ./configure --prefix=$PWD/ && \
    make && \
    make install && \
    ln -s $PWD/samtools /usr/local/bin/

# MUMmer
ENV MUMMER_VER=4.0.0beta2
RUN cd /usr/local && \
    wget https://github.com/mummer4/mummer/releases/download/v${MUMMER_VER}/mummer-${MUMMER_VER}.tar.gz && \
    tar xxvf mummer-${MUMMER_VER}.tar.gz && \
    rm mummer-${MUMMER_VER}.tar.gz && \
    cd mummer-${MUMMER_VER} && \
    ./configure --prefix=$PWD/ && \
    make && \
    make install && \
    ln -s $PWD/bin/* /usr/local/bin/

# Canu
ENV CANU_VER=1.7.1
RUN cd /usr/local/bin/ && \
    wget https://github.com/marbl/canu/releases/download/v${CANU_VER}/canu-${CANU_VER}.Linux-amd64.tar.xz && \
    tar -xvJf canu-${CANU_VER}.Linux-amd64.tar.xz && \
    rm canu-${CANU_VER}.Linux-amd64.tar.xz && \
    ln -s canu-${CANU_VER}/Linux-amd64/bin/* /usr/local/bin/

# SPAdes
ENV SPADES_VER=3.7.1
RUN cd /usr/local/bin/ && \
    wget http://cab.spbu.ru/files/release${SPADES_VER}/SPAdes-${SPADES_VER}-Linux.tar.gz && \
    tar -xzvf SPAdes-${SPADES_VER}-Linux.tar.gz && \
    rm SPAdes-${SPADES_VER}-Linux.tar.gz && \
    ln -s SPAdes-${SPADES_VER}-Linux/bin/* /usr/local/bin/ && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    spades.py

RUN   pip3 install Cython && pip3 install circlator

RUN   circlator progcheck && circlator test /tmp/circlator-test && rm -r /tmp/circlator-test
