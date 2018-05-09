FROM debian:9

RUN DEBIAN_FRONTEND=noninteractive apt -qq update \
 && apt install -yqq \
 	gcc \
 	g++ \
 	git \
 	vim-tiny \
 	make \
 	libudev-dev \
 	libmicrohttpd-dev \
 && apt -yqq clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone --depth 1 https://github.com/OpenZWave/open-zwave.git \
 && cd open-zwave \
 && make \
 && make install

# disable mac os x compilation and enable linux
RUN git clone --depth 1 https://github.com/OpenZWave/open-zwave-control-panel.git \
 && cd open-zwave-control-panel \
 && sed -i 's@#LIBZWAVE := $(wildcard $(OPENZWAVE)/*.a)@LIBZWAVE := $(wildcard $(OPENZWAVE)/*.a)@' Makefile \
 && sed -i 's@#LIBUSB := -ludev@LIBUSB := -ludev@' Makefile \
 && sed -i 's@#LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) -lresolv@LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) -lresolv@' Makefile \
 && sed -i 's@LIBUSB := -framework IOKit -framework CoreFoundation@#LIBUSB := -framework IOKit -framework CoreFoundation@' Makefile \
 && sed -i 's@LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) $(ARCH) -lresolv@#LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) $(ARCH) -lresolv@' Makefile \
 && make

WORKDIR /opt/open-zwave-control-panel
EXPOSE 80
CMD ["./ozwcp", "-p", "80"]

LABEL maintainer="Alexandre Buisine <alexandrejabuisine@gmail.com>" version="1.0.0"