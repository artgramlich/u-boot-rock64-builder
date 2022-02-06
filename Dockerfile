FROM ubuntu:focal-20220105 as builder
ARG UBOOT_VERSION=2022.01
ARG ATF_VERSION=2.6
ARG MAKE_JOBS=10

RUN apt-get -y update && apt-get install -y \
    build-essential \
    gcc-aarch64-linux-gnu \
    git wget bison flex libssl-dev bc \
    python3-dev python3-distutils \
    swig device-tree-compiler

RUN mkdir -p /build /build/artifacts /build/sources /build/out

RUN cd /build/sources \
    && wget https://ftp.denx.de/pub/u-boot/u-boot-${UBOOT_VERSION}.tar.bz2 \
    && wget https://github.com/ARM-software/arm-trusted-firmware/archive/refs/tags/v${ATF_VERSION}.tar.gz

RUN cd /build \
    && tar xvf sources/v${ATF_VERSION}.tar.gz \
    && cd arm-trusted-firmware-${ATF_VERSION} \
    && make CROSS_COMPILE=aarch64-linux-gnu- PLAT=rk3328 \
    && cp build/rk3328/release/bl31/bl31.elf /build/artifacts/ \
    && cd / && rm -rf /build/arm-trusted-firmware-${ATF_VERSION}

RUN cd /build \
    && tar xvf sources/u-boot-${UBOOT_VERSION}.tar.bz2 \
    && mv u-boot-${UBOOT_VERSION} u-boot \
    && cd u-boot \
    && make rock64-rk3328_defconfig \
    && make -j ${MAKE_JOBS} CROSS_COMPILE=aarch64-linux-gnu- BL31=/build/artifacts/bl31.elf \
    && cp u-boot-rockchip.bin /build/out \
    && cd / && rm -rf /build/u-boot

FROM scratch
COPY --from=builder /build/out/ /

