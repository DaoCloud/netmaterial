ARG UBUNTU_2204_BASE_IMAGE=ubuntu:22.04
ARG UBUNTU_2004_BASE_IMAGE=ubuntu:20.04
ARG UBUNTU_1804_BASE_IMAGE=ubuntu:18.04
ARG CENTOS8_BASE_IMAGE=centos:8
ARG CENTOS9_BASE_IMAGE=centos:9

FROM --platform=${BUILDPLATFORM} ${UBUNTU_2204_BASE_IMAGE} as ubuntu2204_builder
ADD install-tools.sh .
RUN chmod +x install-tools.sh && ./install-tools.sh 

FROM --platform=${BUILDPLATFORM} ${UBUNTU_2004_BASE_IMAGE} as ubuntu2004_builder
ADD install-tools.sh .
RUN chmod +x install-tools.sh && ./install-tools.sh

FROM --platform=${BUILDPLATFORM} ${UBUNTU_1804_BASE_IMAGE} as ubuntu1804_builder
ADD install-tools.sh .
RUN chmod +x install-tools.sh && ./install-tools.sh 

FROM --platform=${BUILDPLATFORM} ${CENTOS8_BASE_IMAGE} as centos8_builder
ADD install-tools.sh .
RUN chmod +x install-tools.sh && ./install-tools.sh 

FROM --platform=${BUILDPLATFORM} ${CENTOS9_BASE_IMAGE} as centos9_builder
ADD install-tools.sh .
RUN chmod +x install-tools.sh && ./install-tools.sh 

FROM alpine:3
RUN mkdir -p /host/ubuntu2204/usr/bin && mkdir -p /host/ubuntu2204/usr/lib && \
    mkdir -p /host/ubuntu2004/usr/bin && mkdir -p /host/ubuntu2004/usr/lib && \
    mkdir -p /host/ubuntu1804/usr/bin && mkdir -p /host/ubuntu1804/usr/lib && \
    mkdir -p /host/centos8/usr/bin && mkdir -p /host/centos8/usr/lib && \
    mkdir -p /host/centos9/usr/bin && mkdir -p /host/centos9/usr/lib 
WORKDIR /host/

COPY --from=ubuntu2204_builder /host/ubuntu2204/usr/bin /host/ubuntu2204/usr/bin
COPY --from=ubuntu2004_builder /host/ubuntu2004/usr/bin /host/ubuntu2004/usr/bin
COPY --from=ubuntu1804_builder /host/ubuntu1804/usr/bin /host/ubuntu1804/usr/bin
COPY --from=centos8_builder /host/centos8/usr/bin /host/centos8/usr/bin
COPY --from=centos9_builder /host/centos8/usr/lib /host/centos8/usr/lib

ADD modules /host/modules
ADD install.sh /host/modules
ADD INFOS /host
RUN chmod +x /host/install.sh

ENTRYPOINT [./host/install.sh]