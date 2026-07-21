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
    curl \
    libbamtools-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN mkdir -p HLA-LA HLA-LA/bin HLA-LA/src HLA-LA/obj HLA-LA/temp HLA-LA/working HLA-LA/graphs && \
    cd HLA-LA/src; git clone https://github.com/DiltheyLab/HLA-LA.git .
WORKDIR /opt/HLA-LA/src
RUN git checkout tags/v1.0.4 && \
    make all BAMTOOLS_PATH=/usr BOOST_PATH=/usr && \
    ../bin/HLA-LA --action testBinary
WORKDIR /opt/HLA-LA/graphs
RUN curl --fail-early -OL http://www.well.ox.ac.uk/downloads/PRG_MHC_GRCh38_withIMGT.tar.gz && \
    echo "525a8aa0c7f357bf29fe2c75ef1d477d  PRG_MHC_GRCh38_withIMGT.tar.gz" > md5sum.txt && \
    md5sum -c md5sum.txt && \
    tar xzf PRG_MHC_GRCh38_withIMGT.tar.gz && \
    rm PRG_MHC_GRCh38_withIMGT.tar.gz
WORKDIR /opt/HLA-LA/src
RUN echo "picard_sam2fastq_bin=/usr/share/java/picard.jar\nsamtools_bin=/usr/bin/samtools\nbwa_bin=/usr/bin/bwa\nnucmer_bin=\ndnadiff_bin=\nminimap2_bin=\nworkingDir=$HLA-LA-DIR/../working/\nworkingDir_HLA_ASM=$HLA-LA-DIR/output_HLA_ASM/" > paths.ini

ENV PATH="/opt/HLA-LA/bin:/opt/HLA-LA/src:${PATH}"
