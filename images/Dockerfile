ARG BASE_IMAGE=ubuntu:22.04
FROM --platform=${BUILDPLATFORM} ${BASE_IMAGE} as builder

RUN chmod +x install-tools.sh && ./install-tools.sh 

FROM alpine:3
RUN mkdir -p /host/usr/bin && mkdir -p /host/usr/lib
WORKDIR /host/
COPY --from=builder /host/usr/bin /host/usr/bin
COPY --from=builder /host/usr/lib /host/usr/lib
ADD modules .
ADD install.sh .
RUN chmod +x install.sh
ENTRYPOINT [./install.sh]