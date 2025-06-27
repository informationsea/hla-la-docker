FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    bwa \
    samtools \
    bamtools \
    libboost-dev \
    libboost-random-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-serialization-dev \
    picard-tools \
    libbamtools-dev \
    bwa  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN mkdir -p HLA-LA HLA-LA/bin HLA-LA/src HLA-LA/obj HLA-LA/temp HLA-LA/working HLA-LA/graphs && \
    cd HLA-LA/src; git clone https://github.com/DiltheyLab/HLA-LA.git .
WORKDIR /opt/HLA-LA/src
RUN git checkout tags/v1.0.4 && \
    make all BAMTOOLS_PATH=/usr BOOST_PATH=/usr && \
    ../bin/HLA-LA --action testBinary
COPY paths.ini /opt/HLA-LA/src/paths.ini
ENV PATH="/opt/HLA-LA/bin:/opt/HLA-LA/src:${PATH}"
