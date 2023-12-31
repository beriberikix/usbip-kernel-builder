FROM ubuntu:latest

# Sources for ubuntu

RUN \
  echo 'deb-src http://archive.ubuntu.com/ubuntu jammy main' >> /etc/apt/sources.list \
  && echo 'deb-src http://archive.ubuntu.com/ubuntu jammy-updates main' >> /etc/apt/sources.list

# Set TZ to UTC

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Main deps, from https://askubuntu.com/a/1435592

RUN \
  apt-get -y update \
  && apt-get -y build-dep --no-install-recommends \
  linux \
  linux-image-generic \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Additional deps

RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  libncurses-dev \
  gawk \
  flex \
  bison \
  openssl \
  dkms \
  libelf-dev \
  libudev-dev \
  libpci-dev \
  libiberty-dev \
  autoconf \
  llvm \
  build-essential \
  libncurses5-dev \
  gcc \
  bc \
  dwarves \
  && apt-get clean \
  && rm -rf /var/lib/lists/*

# Get source

RUN \
  cd /root \
  && apt-get source linux-image-unsigned-$(uname -r)

# Build module

RUN \
  cd /root/linux* \
  && cp /boot/config-* .config \
  && chmod a+x debian/scripts/* \
  && chmod a+x -R ./scripts \
  && make olddefconfig \
  && make modules_prepare \
  # && make M=drivers/usb/usbip modules -j2
  && make modules -j2

# on the host:
#
# docker cp {container}:/root/linux-5.15.0/drivers/usb/usbip/ /lib/modules/kernel/drivers/usb/
# depmod
# modprobe usbip-core
# modprobe vhci-hcd

# On Docker guest
# depmod
# modprobe usbip-core
# modprobe vhci-hcd
# apt install linux-tools-generic hwdata usbutils
# usbip list -r {{IP addr}}